#-------------------------------------------------------------------------------
# This makefile provides an example of how to set up a binary classification
# problem using the provided cell body data set.  
# 
# The steps are as follows:
# 
#   1.  Run "make lmdb" to create the LMDB data set that the caffe models
#       are expecting.  If for any reason you would like to re-create
#       this database, first run "make clean" to delete any pre-existing
#       version.
#
#   2.  Train the classifier by calling "make train-gpu".  Feel free to
#       change the GPU id as needed for your system.  You can also remove
#       the --gpu argument to train using a CPU; however, this will be
#       substantially slower.
#
#       Note that, for your problem of interest, you'll most likely need
#       to tune the Caffe model and/or hyperparameters for best performance.
#
#   3.  Evaluate the trained classifier on new data.  Calling 
#       "make deploy-gpu" provides an example.  Change the --input argument
#       to evaluate a different image.
#       
#       Note that this takes a fairly brute-force approach to generating
#       predictions; see the deploy_classifier.py script for some notes
#       about speeding this up.
#
#-------------------------------------------------------------------------------


# Assumes caffe is in your search path.
# If this is not the case, then update the CAFFE macro accordingly.
CAFFE=caffe

# Update this based on your local python installation
PY=PYTHONPATH=/home/shared/caffe-builds/caffe-rc2_cuda7.5/python:./src ipython --

LMDB_DIR=./data/cell-vs-noncell-lmdb


#-------------------------------------------------------------------------------
unittest :
	$(PY) ./tests/test_preprocessing.py


# Make a Caffe-compatible data set from the two-class hand-annotated images 
# (derived from the original one-class annotations)
lmdb :
	$(PY) ./src/make_binary_dataset.py \
		--train-dir ./data/cell-vs-noncell-auto/train \
		--test-dir ./data/cell-vs-noncell-auto/test \
		--n-samp 3000 \
		--out-dir $(LMDB_DIR)


# Create LMDB dataset from some manually generated labels
lmdb-manual :
	$(PY) ./src/make_binary_dataset.py \
		--train-dir ./data/cell-vs-noncell-manual/train \
		--test-dir ./data/cell-vs-noncell-manual/test \
		--n-samp 80000 \
		--synthetic-examples \
		--out-dir $(LMDB_DIR)


# Train a Caffe classifier
train-gpu : 
	$(CAFFE) train -gpu 3 \
		--solver=./models/cifar10/cifar10_full_solver.prototxt |& tee train.out



# An example of how to run predictions for a single image.
deploy-gpu : 
	$(PY) ./src/deploy_classifier.py \
		--gpu 4 \
		--network ./models/cifar10/cifar10_full_deploy.prototxt \
		--weights ./models/cifar10/cifar10_full_iter_60000.caffemodel \
		--output-layer pred \
		--input ./data/interpolated/img.00012.interp.png


# Removes intermediate outputs (LMDB database and caffe models)
clean :
	@\rm -rf $(LMDB_DIR)/train
	@\rm -rf $(LMDB_DIR)/test
	@\rm -f $(LMDB_DIR)/mean.npy
	@\rm -f $(LMDB_DIR)/mean.binaryproto
	@\rm -f ./models/cifar10/cifar10_full_iter*
