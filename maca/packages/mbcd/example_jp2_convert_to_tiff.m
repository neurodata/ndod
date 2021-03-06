 tic
 inDir = '~/code/PMD2040';
 outDir = '~/code/PMD2040/PMD2040_rgb';
 resample = 0.25;
 singleChannel = 0;
jp2_convert_to_tiff(inDir, outDir, resample, singleChannel)
 toc
 
tic
 inDir = '~/code/PMD2040';
 outDir = '~/code/PMD2040/PMD2040_bw';
 resample = 0.25;
 singleChannel = 1;
 jp2_convert_to_tiff(inDir, outDir, resample, singleChannel)
toc

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
