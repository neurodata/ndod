function put_truthing_data_local(niftiLabels, outputDir, ignoreID)

% INPUTS:
% niftiLabels:  NIFTI File from ITK Snap Truthing (full path)
% OutputDir:  Output Directory
% ignoreID:  Optional ID to ignore in final results

% OUTPUTS:
% PNG Stack (one per input slice)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COPYRIGHT NOTICE
% (c) 2014 The Johns Hopkins University / Applied Physics Laboratory
% All Rights Reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load Data

% Load nii
filename = fullfile(niftiLabels);
nii = load_nii(filename);

data = nii.img;
clear nii;
data = permute(data,[2,1]);
data = fliplr(data);
data = flipud(data);

% fill holes
data = imfill(data);

% Break into IDs and connected component
ids = unique(data);

% Relabel all cells
cell_data = zeros(size(data));
cnt = 2;
for ii = 2:length(ids)
  
   tdata = data;
   tdata(tdata ~= ids(ii)) = 0;
   cc = bwconncomp(tdata);
   
   if ii == ignoreID
       for jj = 1:cc.NumObjects
           cell_data(cc.PixelIdxList{jj}) = 1;
       end
   else       
       for jj = 1:cc.NumObjects
           cell_data(cc.PixelIdxList{jj}) = cnt;
           cnt = cnt + 1;
       end
   end
end


%% Save PNG Stack

mkdir(outputDir)
[~, prefixName, ~] = fileparts(filename);

for i = 1:size(cell_data,3)
    filename = fullfile(outputDir, [prefixName,'_labels_' num2str(i),'.png']);
    imwrite(cell_data(:,:,i), filename)
end
