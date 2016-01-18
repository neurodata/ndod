"""
Applies a (previously trained) Caffe classification model to new image data.

This code takes a brute-force approach to generating per-pixel predictions; 
it simply extracts a tile around every pixel (that is sufficiently far away
from the image border) and runs each tile through Caffe.
This entails many repeated calculations and is not computationally efficient.  
More sophisticated approaches for dense predictions exist and could
be considered in the future (e.g. see second reference below).  

Alternatively, you can change this code to evaluate only a subset of the 
pixels and then inpaint the remainder.


REFERENCES:
    o http://caffe.berkeleyvision.org/
    o Long et. al. "Fully convolutional networks for semantic segmentation" 
      http://arxiv.org/pdf/1411.4038.pdf
"""

__author__ = "mjp"
__copyright__ = "Copyright 2015, JHU/APL"
__license__ = "Apache 2.0"


import os
import argparse
import time
import numpy as np
import lmdb
import pdb

import skimage, skimage.io, skimage.transform

import caffe  # make sure PyCaffe is in your PYTHONPATH




def get_args():
    """Defines command line arguments for this script.
    """
    parser = argparse.ArgumentParser(description="Deploy a classifier.")

    parser.add_argument('--input', type=str, 
                        dest="inputFile", required=True,
                        help="Input file to process (a .png)")

    parser.add_argument('--network', type=str, 
                        dest="netFile", required=True,
                        help="Caffe CNN network file")

    parser.add_argument('--weights', type=str, 
                        dest="weightFile", required=True,
                        help="Caffe parameters associated with network")

    parser.add_argument('--gpu', type=int, 
                        dest="gpuId", default=-1,
                        help="Which GPU to use (or -1 for CPU)")

    parser.add_argument('--output-layer', type=str, 
                        dest="outputLayer", default="pred",
                        help="Name of the CNN output layer to use for predictions")
            
    return parser.parse_args()




def init_caffe_network(netFile, weightFile, gpuId):
    """Creates a caffe network object.
    """
    # set CPU or GPU mode
    if gpuId >= 0:
        caffe.set_mode_gpu()
	caffe.set_device(gpuId)
    else:
        caffe.set_mode_cpu()

    # instantiate the Caffe model
    #
    # Note: PyCaffe also offers a different interface via caffe.Classifier;
    #       however, this does things behinds the scenes to data 
    #       (and also seems slower).  So for this application, we'll stick 
    #       with the somewhat lower-level interface provided by caffe.Net.
    net = caffe.Net(netFile, weightFile, 1)

    return net



def _interior_pixel_generator(X, tileDim, batchSize, mask=None):
    """An iterator over pixel indices that lie in the interior of an image.

    Warning: this is fairly memory intensive (pre-computes the entire 
    list of indices).

    Note: could potentially speed up the process of extracting subtiles by
    creating a more efficient implementation; however, the bulk of the
    runtime is usually associated with Caffe forward passes.

    Parameters:
      X          := a (width x height) image 
      tileDim    := the width/height of each square tile to extract
      batchSize  := number of tiles to extract each iteration
                    (dictated by Caffe model) 
      mask       := a boolean matrix the same size as X; elements that are
                    true are eligible to be used as tile centers.
                    If None, there is no restriction on which pixels 
                    to evaluate.
    """
    m,n = X.shape

    assert(np.mod(tileDim,2) == 1) # tile size must be odd
    tileRadius = int(np.floor(tileDim/2.0))
    nChannels = 1

    Xmb = np.zeros((batchSize, nChannels, tileDim, tileDim), dtype=np.uint8)

    # Used to restrict the set of pixels under consideration.
    bitMask = np.ones(X.shape, dtype=bool)

    # by default, we do not evaluate pixels that are too close to 
    # the border of the image.
    bitMask[0:tileRadius, :] = 0
    bitMask[(m-tileRadius):m, :] = 0
    bitMask[:, 0:tileRadius] = 0
    bitMask[:, (n-tileRadius):n] = 0
    
    if mask is not None:
        bitMask = bitMask & mask

    # return indices and tiles in subsets of size batchSize
    Idx = np.column_stack(np.nonzero(bitMask))

    for ii in range(0, Idx.shape[0], batchSize):
        nRet = min(batchSize, Idx.shape[0] - ii)

        # creates the next "mini-batch"
        for jj in range(nRet):
            a = Idx[ii+jj,0] - tileRadius 
            b = Idx[ii+jj,0] + tileRadius + 1 
            c = Idx[ii+jj,1] - tileRadius 
            d = Idx[ii+jj,1] + tileRadius + 1 
            Xmb[jj, 0, :, :] = X[a:b, c:d]

        yield Xmb, Idx[ii:(ii+nRet),:]



def predict_tiles(X, net, outputLayer):
    """Given an example generator whose features correspond to images,
    produces a new stream of examples where X is now caffe features.
    """
    assert(X.ndim == 2)   # currently assumes a single channel image

    Prob = np.zeros(X.shape, dtype=np.float32)

    # make sure the desired feature layers exists in the network
    if outputLayer not in net.blobs: 
        raise RuntimeError('could not find layer %s in model' % outputLayer)

    # assumes the data layer is called "data"
    if "data" not in net.blobs: 
        raise RuntimeError('could not find data layer in model - did you call it something other than "data"?')

    nMiniBatch, nChannels, rows, cols = net.blobs['data'].data.shape
    assert(rows == cols)
    tileDim = rows
    assert(nChannels == 1) # we assume this for now

    #----------------------------------------
    # process each mini-batch and save results
    #----------------------------------------
    lastChatter = -1
    tic = time.time()

    for Xmb, idx in _interior_pixel_generator(X, tileDim, nMiniBatch):
        net.set_input_arrays(Xmb.astype(np.float32), 
                             np.zeros((Xmb.shape[0],), dtype=np.float32))
        net.forward()

        # Extract predictions (for class 1) from network.
        # For a multi-class problem, you would want to extract predictions
        # for all classes.
        output = net.blobs[outputLayer].data
        pred = np.squeeze(output[0:idx.shape[0], 1])
        for kk in range(idx.shape[0]):
            Prob[idx[kk,0], idx[kk,1]] = pred[kk]

        # report progress periodically
        runtimeMin = np.floor((time.time() - tic)/60.)
        if runtimeMin > lastChatter:
            print('[info]: last pixel processed was (%d,%d); runtime=%d min' % (idx[-1,0], idx[-1,1], runtimeMin))
            print('[info]:   last batch min/max/mean prediction: %0.2f / %0.2f / %0.2f' % (np.min(pred), np.max(pred), np.mean(pred)))
            lastChatter = runtimeMin

    return Prob



if __name__ == "__main__":
    args = get_args()
    print args

    # create caffe model
    net = init_caffe_network(args.netFile, 
                             args.weightFile, 
                             args.gpuId)

    X = skimage.io.imread(args.inputFile)
    print('[info]: Proccessing image with dimensions %s and type %s' % (str(X.shape), X.dtype))
    print('[info]: X min / max / mean: %0.2f / %0.2f / %0.2f' % (np.min(X), np.max(X), np.mean(X)))
    assert(X.dtype == np.uint8)

    # run caffe
    # Note: these probabilities may not be properly calibrated (if we
    #       trained on a balanced data set and are deploying on a 
    #       data set with class imbalance).  If calibrated probabilities
    #       are needed, you will want to do some additional postprocessing.
    Prob1 = predict_tiles(X, net, args.outputLayer)

    # Save results
    outFile = args.inputFile + ".Yhat"
    np.save(outFile+".npy", Prob1)
    skimage.io.imsave(outFile+".tiff", Prob1)

    print('[info]: Wrote results to "%s.XXX"' % outFile)

 
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
