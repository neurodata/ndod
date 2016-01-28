function mana_put_local(niftiLabels, outputDir, ignoreID)

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

% (c) 2015 The Johns Hopkins University / Applied Physics Laboratory 
% All Rights Reserved. Contact the JHU/APL Office of Technology Transfer for any # additional rights.  www.jhuapl.edu/ott
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%    http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
