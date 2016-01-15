"""
This script combines a feature data image (denoted X) with a ground
truth label image (denoted Y) into a single numpy tensor.  The resulting
tensor will be saved to file and used later by the make_binary_dataset.py
script.
"""

__author__ = "mjp"
__copyright__ = "Copyright 2015, JHU/APL"
__license__ = "Apache 2.0"


import argparse
import numpy as np
import skimage.io



def get_args():
    parser = argparse.ArgumentParser(description="Merges feature and truth images.")

    parser.add_argument('--X', type=str, 
                        dest="fileX", required=True,
                        help="The feature image file name")
    
    parser.add_argument('--Y', type=str, 
                        dest="fileY", required=True,
                        help="The truth image file name")
    
    parser.add_argument('--output', type=str, 
                        dest="outFile", required=True,
                        help="Output file name")

    return parser.parse_args()



if __name__ == "__main__":
    args = get_args()
    print args

    X = skimage.io.imread(args.fileX)
    Y = skimage.io.imread(args.fileY)

    # X will have 1 color channel while Y should have 3
    assert(X.shape[0] == Y.shape[0])
    assert(X.shape[1] == Y.shape[1])

    # WARNING: There may be hand-annotated class labels in X (i.e. pixels
    #          with value 255 that were manually added).
    #          These could be interpolated away here; however, for now
    #          we'll let the make_binary_dataset.py script handle this.

    # Assume positive labels in channel 0 and negative labels in channel 1.
    # This was just the way I happened to color the pixels.
    Yp = np.squeeze(Y[:,:,0])
    Yp[Yp==255] = 1
    assert(len(np.unique(Yp)) == 2)
    
    Yn = np.squeeze(Y[:,:,1])
    Yn[Yn==255] = 1
    assert(len(np.unique(Yn)) == 2)

    # make sure class labels are disjoint
    assert(np.max(Yp+Yn) == 1)

    # package X and Y together into a single tensor
    #  0 := uplabeled pixel
    #  1 := negative class label
    #  2 := positive class label
    Z = np.ones((X.shape[0], X.shape[1], 2), dtype=np.uint8)
    Z[:,:,0] = X
    Z[:,:,1] = Yn + 2*Yp

    np.save(args.outFile, Z)
