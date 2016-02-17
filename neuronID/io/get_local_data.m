function img = get_local_data(filename, dirname, xArgs, yArgs)

% INPUTS:
% filename:  A single TIF/JP2/PNG or other imread supported file, with
% complete path information
% dirname:  Output directory for nifti file
% OUTPUTS:
% NIFTI File for Truthing in ITK Snap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COPYRIGHT NOTICE
% (c) 2014 The Johns Hopkins University / Applied Physics Laboratory
% All Rights Reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Get Data

imgRaw = imread(filename);
[~,prefixName,~] = fileparts(filename);

imgRaw = imgRaw(xArgs(1):xArgs(2),yArgs(1):yArgs(2),:);
% Format for NIFTI file
if size(imgRaw,4) == 1
    img(:,:,:,1) = imgRaw(:,:,1);
    img(:,:,:,2) = imgRaw(:,:,1);
    img(:,:,:,3) = imgRaw(:,:,1);
    img(:,:,:,4) = imgRaw(:,:,1);
    
else
    img = imgRaw;
end

%% Save nii
filename = fullfile(dirname, [prefixName,'_',num2str(xArgs(1)), '_',num2str(xArgs(2)),'_',num2str(yArgs(1)),'_',num2str(yArgs(2)),'.nii']);

nii = make_nii(img(:,:,:,1:3), [1 1 1], [0 0 0], 128);
save_nii(nii, filename);