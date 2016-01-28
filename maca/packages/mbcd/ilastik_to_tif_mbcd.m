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
