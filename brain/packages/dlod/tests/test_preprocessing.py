"""
"""

__author__ = "mjp"
__copyright__ = "Copyright 2015, JHU/APL"
__license__ = "Apache 2.0"



import os 
import unittest
from StringIO import StringIO
import pdb
import numpy as np


import make_binary_dataset as mbc



class TestMBC(unittest.TestCase):

    def test_interpolate(self):
        X = np.random.randint(0, 254, size=(300,300))
        X[0,0] = 255
        X[10,10] = 255
        X[299,299] = 255

        # before interpolation, there are missing values
        idx = np.ravel(np.nonzero(X==255))
        self.assertEqual(len(idx), 6)

        # afterwards, there should be no missing values
        Xi = mbc._interpolate_missing_data(X, 255)
        idx = np.ravel(np.nonzero(Xi==255))
        self.assertEqual(len(idx), 0)


 
if __name__ == "__main__":
    unittest.main()

# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
