% Example of using mana to do ground truthing on local data

% get data
img = mana_get_local(filename, dirname, xArgs, yArgs);

% do truthing in ITK snap and save segmentation

%put data
mana_put_local('/sample_data/test_segmentation.nii', labelOut,-1)

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
