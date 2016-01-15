# Data
This directory contains 30 annotated images of cell bodies.  All files are grayscale .png format; the (approximate) centers of the cell bodies are annotated with a white dot (value of 255).  These cell body annotations were provided by an external expert.

The original files have been partitioned into train and test sets based on morphological properties.  There was some attempt made to ensure examples of cell fields of various densities are reprsented in both training and test.  This partitioning was performed by a non-expert; if this default partition is deemed suboptimal it can be changed by moving files between the "train" and "test" subdirectories and re-running the preprocessing scripts.

(We technically should create a separate validation data set, so that we do not tune Caffe parameters using test data; however, since this is more a proof-of-concept, we'll defer this for now).
