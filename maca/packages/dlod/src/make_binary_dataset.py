"""
This module constructs a binary classification data set.
The output will be an LMDB data set suitable for use with the Caffe deep
learning framework.  One can then train a classifier from the command line.

Requires anaconda (or any other reasonably complete python package), the
Python LMDB interface and the Python Caffe interface all be installed
on the local system.  You'll also need the Python HDF5 library.

REFERENCES:
    o Caffe: http://caffe.berkeleyvision.org/
"""

__author__ = "mjp"
__copyright__ = "Copyright 2015, JHU/APL"
__license__ = "Apache 2.0"


import sys
import os
import argparse
import time
import itertools
import pdb

from functools import partial
import numpy as np
import lmdb
import h5py

import skimage, skimage.io, skimage.transform

import caffe  # make sure PyCaffe is in your PYTHONPATH




def get_args():
    """Defines command line arguments for this script.
    """
    def nonnegative_int(x):
        x = int(x)
        if x < 0: 
            raise argparse.ArgumentTypeError('%s not a non-negative integer')
        return x

    def odd_nonnegative_int(x):
        x = nonnegative_int(x)
        if np.mod(x, 2) == 0:
            raise argparse.ArgumentTypeError('%s must be odd')
        return x

    def nonnegative_float(x):
        x = float(x)
        if x < 0.0: 
            raise argparse.ArgumentTypeError('%s not a non-negative float')
        return x


    parser = argparse.ArgumentParser(description="Create a binary classification cell detection problem.")

    #----------------------------------------
    # Parameters related to the raw image inputs.
    #----------------------------------------
    parser.add_argument('--train-dir', type=str, nargs="+",
                        dest="trainDirs", required=True,
                        help="One or more directories, each containing training images (annotated .png)");
            
    parser.add_argument('--test-dir', type=str, nargs="+",
                        dest="testDir", required=True,
                        help="One or more directories, each containing testing images (annotated .png)");

    #----------------------------------------
    # Parameters related to the output 
    #----------------------------------------
    parser.add_argument('--out-dir', type=str,
                        required=True, dest="outDir",
                        help="output directory")

    #----------------------------------------
    # Data processing parameters
    #----------------------------------------
    parser.add_argument('--tile-size', type=odd_nonnegative_int,
                        default=65, dest="tileSize",
                        help="Size (width, in pixels) of images used in classification problem.  Must be an odd integer > 0.")

    parser.add_argument('--n-samp', type=nonnegative_int,
                        default=1000, dest="nSamp",
                        help="number of examples to sample from each image")

    parser.add_argument('--synthetic-examples', action='store_true',
                        default=False, dest="syntheticExamples",
                        help="Use synthetic data generation")


    return parser.parse_args()



def _interpolate_missing_data(X, val=255):
    """Replaces all pixels whose value is val with a weighted 
    average of neighboring pixels.
    """
    assert(X.ndim==2)
    Xout = np.array(X, copy=True)
    rows, cols = np.nonzero(Xout==val)

    for ii in range(len(rows)):
        row = rows[ii];   col = cols[ii]

        net = 0.0;  n = 0
        if row > 0:
            net += X[row-1,col]
            n += 1
        if row < X.shape[0] - 1:
            net += X[row+1,col]
            n += 1
        if col > 0:
            net += X[row,col-1]
            n += 1
        if col < X.shape[1] - 1:
            net += X[row,col+1]
            n += 1

        Xout[row,col] = 1.0*net / n

    return Xout



def _load_h5_examples(dirName):
    """Generator that returns image/label pairs X/Y.
    """
    for fn in os.listdir(dirName):
        if fn.endswith('.mat'): 
            with h5py.File(os.path.join(dirName, fn), 'r') as f:
                Y = f['Y'].value
                X = f['X'].value

                X = _interpolate_missing_data(X, val=255)
                Y = Y - 1  # map {0,1,2} -> {-1,0,1}
                yield X, Y, fn



def _load_npy_examples(dirName):
    """Generator that returns image/label pairs X/Y.
    """
    for fn in os.listdir(dirName):
        if fn.endswith('.npy'): 
            Z = np.load(os.path.join(dirName, fn))
            X = _interpolate_missing_data(Z[:,:,0], val=255)
            Y = Z[:,:,1] - 1
            yield X, Y, fn


#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------


def _extract_tiles(X, rowIdx, colIdx, tileSize):
    """Extracts tiles from an image X provided the tile lies completely 
    within the boundary of X (i.e. tiles that fall partially outside of
    the image domain are omitted).

    The candidate tile centers are specified by rowIdx and colIdx.

    Returns a list of tiles (numpy arrays), where each tile has dimensions:
        (1, height/#rows, width/#cols).
    This makes it easy to stack the tiles into a tensor.
    """
    tiles = []
    r = np.floor(tileSize/2)  # tile "radius"; assumes tileSize is odd
    for row, col in zip(rowIdx, colIdx): 
        if row > r and row < X.shape[0] - r and col > r and col < X.shape[1] - r: 
            tile = X[row-r:row+r+1, col-r:col+r+1]
            tile = tile[np.newaxis,...]  # expand to a tensor
            tiles.append(tile)
    return tiles




def _load_dataset(dirList, tileSize, load_func, nSamp):
    """Loads all tiles from a list of directories.
    """
    x = []   # a list of feature images
    y = []   # a list of class labels
    r = np.floor(tileSize/2)  # tile "radius"; assumes tileSize is odd

    for dirName in dirList:
        for Xi, Yi, fn in load_func(dirName):
            print('[info]: processing file: %s' % fn)
            print('[info]:    has class labels %s' % np.unique(Yi))

            # Mask out pixels too close to the image border
            Yi[0:r+1, :] = -1
            Yi[-(r+1):, :] = -1
            Yi[:, 0:r+1] = -1
            Yi[:, -(r+1):] = -1

            #----------------------------------------
            # Extract cell body examples (y=1).
            # Downsample if necessary
            #----------------------------------------
            rowPos, colPos = np.nonzero(Yi==1)
            if len(rowPos) > nSamp:
                idx = np.random.choice(np.arange(len(rowPos)), nSamp, replace=False)
                rowPos = rowPos[idx]
                colPos = colPos[idx]
                del idx

            tiles = _extract_tiles(Xi, rowPos, colPos, tileSize)
            x.extend(tiles)
            y.extend([1 for ii in range(len(tiles))])

            #----------------------------------------
            # Extract non-cell body examples (y=0)
            #----------------------------------------
            rowNeg, colNeg = np.nonzero(Yi==0)
            
            if len(rowNeg) > min(nSamp, len(rowPos)):
                nNeg = min(nSamp, len(rowPos))
                idx = np.random.choice(np.arange(len(rowNeg)), nNeg, replace=False)
                rowNeg = rowNeg[idx]
                colNeg = colNeg[idx]
                del idx

            tiles = _extract_tiles(Xi, rowNeg, colNeg, tileSize)
            x.extend(tiles)
            y.extend([0 for ii in range(len(tiles))])

            print('[info]:    file had %d pos. and %d neg. examples (after downsampling)' % (len(rowPos), len(rowNeg)))


    if len(x) == 0:
        raise RuntimeError('no files found in %s' % str(dirList))

    # convert lists to numpy arrays 
    return np.concatenate(x, axis=0), np.array(y)




def square_symmetries():
    """Returns functions to calculate all 8 symmetries
    of the square (for synthetic data augmentation).

    Will return a list of functions; each function expects as input
    a single image with dimensions:
       (height x width)
    or
       (nChannels x height x width)

    Having # channels as the first dimension may seem a little backwards
    (e.g. relative to what pylab.imshow() would expect) but this is the
    Caffe convention.
    """

    def R0(X):
        return X  # this is the identity map

    def M1(X):
        if X.ndim == 3: 
            return X[:,::-1,:]
        else:
            return X[::-1,:]

    def M2(X): 
        if X.ndim == 3: 
            return X[:,:,::-1]
        else:
            return X[:,::-1]

    def D1(X):
        if X.ndim == 3: 
            return np.transpose(X, [0, 2, 1])
        else:
            return np.transpose(X, [1, 0])

    def R1(X):
        return D1(M2(X))   # = rot90 on the last two dimensions

    def R2(X):
        return M2(M1(X))

    def R3(X): 
        return D2(M2(X))

    def D2(X):
        return R1(M1(X))


    symmetries = [R0, R1, R2, R3, M1, M2, D1, D2]
    return symmetries





def _write_lmdb(outDir, X, y, synGenFuncs=[lambda x: x]):
    """Writes a classification data set to a Caffe-compatible
    LMDB database.  Performs synthetic data augmentation along
    the way.

       outDir : The name of the directory that will contain the 
                LMDB database.  Will be created if does not 
                already exist

       X : A numpy tensor of objects with dimension 
           (# examples, height, width)
           or
           (# examples, # channels, height, width)

       y : A numpy vector of class labels, one for each
           object in X. 
    """

    if os.path.exists(outDir):
        raise RuntimeError('Directory %s already exists - please rename or move out of the way' % outDir)
    os.makedirs(outDir)

    # make sure data types are as expected
    X = X.astype(np.uint8)
    assert(np.min(y) == 0)

    # add in a channel
    if X.ndim == 3:
        X = X[:, np.newaxis, :, :]

    # initialize database 
    # Not sure if map size includes the 8 byte label - we'll include it
    # to be safe.
    szOneItem = X[0,0,...].nbytes + y[0].nbytes + 8
    szOneItem = 4 * int(np.ceil(szOneItem / 4.0))
    # the extra factor of 2 is just some extra margin.
    sz = 2 * len(synGenFuncs) * len(y) * szOneItem
    env = lmdb.open(outDir, map_size=sz)

    # Write (augmented) examples to database.
    # Note that we loop first over the augmentation functions.
    # This is to avoid introducing small blocks of examples all with
    # the same label (resulting from taking N augmentations of a single
    # example).  Also, this code shuffles the example order after
    # each new augmentation function.
    idx = 0
    with env.begin(write=True) as txn:
        for fIdx, f_syn in enumerate(synGenFuncs):

            # shuffle examples for this pass
            tmp = np.random.permutation(y.size) 
            X = X[tmp,...];  y = y[tmp];
            del tmp

            for ii in range(y.size): 
                Xi = f_syn(X[ii,...]) 
                yi = y[ii]

                datum = caffe.proto.caffe_pb2.Datum()
                datum.channels = 1
                datum.height = Xi.shape[1]
                datum.width = Xi.shape[2]
                datum.label = int(yi)
                datum.data = Xi.tostring()
                strId = '{:08}'.format(idx)

                txn.put(strId.encode('ascii'), datum.SerializeToString())
                idx += 1

                if np.mod(ii, 1000) == 0:
                    print('[info]: Wrote %d of %d examples to LMDB (pass %d)...' % (ii, y.size, fIdx))

    return idx



def _write_mean_file(Xbar, fn):
    """ Creates a mean value file for use in Caffe.
    """
    if Xbar.ndim == 2: 
        Xbar = Xbar[np.newaxis,...]  # add channel dimension
    else:
        assert(Xbar.ndim == 3)
        assert(Xbar.shape[0] == 1) # expect a single channel

    blob = caffe.proto.caffe_pb2.BlobProto()
    blob.channels, blob.height, blob.width = Xbar.shape
    blob.num = 1
    blob.data.extend(Xbar.astype(float).flat)
    with open(fn, 'wb') as f:
        f.write(blob.SerializeToString())



def _read_lmdb(inDir):
    """Reads in a LMDB data set (for debugging)
    """

    X = [];  y = [];
    datum = caffe.proto.caffe_pb2.Datum()
    env = lmdb.open(inDir, readonly=True)
    with env.begin() as txn:
        cursor = txn.cursor()
        for key, value in cursor:
            datum.ParseFromString(value)
            xv = np.fromstring(datum.data, dtype=np.uint8)
            xv = xv.reshape(datum.channels, datum.height, datum.width)
            xv = xv[np.newaxis, ...]  # add the example index dimension
            X.append(xv)
            y.append(datum.label)
    env.close()

    return np.concatenate(X, axis=0), np.array(y)




def _make_dataset(args):
    if not os.path.exists(args.outDir):
        os.makedirs(args.outDir)


    trainOutDir = os.path.join(args.outDir, 'train')
    testOutDir = os.path.join(args.outDir, 'test')
    if os.path.exists(trainOutDir):
        raise RuntimeError('Directory "%s" exists; please move or rename it first' % trainOutDir)
    if os.path.exists(testOutDir):
        raise RuntimeError('Directory "%s" exists; please move or rename it first' % testOutDir)

    #load_func = _load_npy_examples
    load_func = _load_h5_examples

    #----------------------------------------
    # Process training data
    #----------------------------------------
    print('[info]: PROCESSING TRAINING DATA')
    tic = time.time()
    X,y = _load_dataset(args.trainDirs, args.tileSize, load_func, args.nSamp)
    toc = (time.time() - tic) / 60.
    print('[info]: took %0.2f min. to load training data set' % toc)

    tic = time.time()
    if args.syntheticExamples: 
        cnt = _write_lmdb(trainOutDir, X, y, synGenFuncs=square_symmetries())
    else:
        cnt = _write_lmdb(trainOutDir, X, y)
    toc = (time.time() - tic) / 60.

    #Xbar = np.mean(X,axis=0)
    #np.save(os.path.join(args.outDir, 'mean'), Xbar[:,:,np.newaxis])
    #_write_mean_file(Xbar, os.path.join(args.outDir, 'mean.binaryproto'))
    print('[info]: took %0.2f min. to write training data set' % toc)

    #----------------------------------------
    # Process test data
    #----------------------------------------
    print('[info]: PROCESSING TEST DATA')
    tic = time.time()
    X,y = _load_dataset(args.testDir, args.tileSize, load_func, args.nSamp)
    toc = (time.time() - tic) / 60.
    print('[info]: took %0.2f min. to load test data set' % toc)

    tic = time.time()
    cnt = _write_lmdb(testOutDir, X, y)
    toc = (time.time() - tic) / 60.
    print('[info]: took %0.2f min. to write test data set' % toc)

    return trainOutDir, testOutDir



if __name__ == "__main__":
    args = get_args()
    print args

    trainOutDir, testOutDir = _make_dataset(args)


    X,y = _read_lmdb(trainOutDir)
    print('[info]: for training data in: %s' % trainOutDir)
    print('[info]:     type(x)=%s' % X.dtype)
    print('[info]:     x_min=%0.2f, x_max=%0.2f, x_mean=%0.2f' % (np.min(X), np.max(X), np.mean(X)))
    print('[info]:     type(y)=%s' % y.dtype)
    print('[info]:     unique(y)=%s' % str(np.unique(y)))
    print('[info]:     #pos=%d, #neg=%d' % (np.sum(y==1), np.sum(y==0)))


    X,y = _read_lmdb(testOutDir)
    print('[info]: for test data in:     %s' % testOutDir)
    print('[info]:     type(x)=%s' % X.dtype)
    print('[info]:     x_min=%0.2f, x_max=%0.2f, x_mean=%0.2f' % (np.min(X), np.max(X), np.mean(X)))
    print('[info]:     type(y)=%s' % y.dtype)
    print('[info]:     unique(y)=%s' % str(np.unique(y)))
    print('[info]:     #pos=%d, #neg=%d' % (np.sum(y==1), np.sum(y==0)))





 
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
