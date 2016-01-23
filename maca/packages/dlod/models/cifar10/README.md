This directory contains a modified version of the CIFAR-10 CNN provided as an example with Caffe.  It has been modified to operate on data from the binary cell "detection" problem.

There is no claim that this is a particularly good CNN to use for this problem; this is merely a demonstration of how one might use Caffe on this data.  In practice, there would be (a) a more careful definition of the binary classification problem and (b) some hyper-parameter selection that drives the choice of CNN architecture and layer settings.

These models and scripts provide the means to train a Caffe CNN from scratch using representative data.  Another reasonable alternative is to start with a pre-existing model (e.g. perhaps trained using natural images, such as in the imagenet challenge problem) and fine tune the model using this data set.  
