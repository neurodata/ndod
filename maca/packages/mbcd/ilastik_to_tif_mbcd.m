function ilastik_to_tif_mbcd(fileIn, fileOut)
% Example ilastik hdf5 to tif conversion
% Assumes that default hdf5 parameters are used 
% and that data is in 'export_data'.

% Further assumes that probabilities of interest are in first channel

z = h5read(fileIn,'/exported_data');
prob = squeeze(z(1,:,:,:))'; %requires transpose

prob = im2uint16(prob); %matlab stores these files best as uint16

%figure, imagesc(prob)
imwrite(prob, fileOut)
