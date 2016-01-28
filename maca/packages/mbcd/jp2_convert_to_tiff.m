function jp2_convert_to_tiff(inDir, outDir, resample, singleChannel)
% This function converts JP2 to TIFF, with options to resample to smaller or 
% larger image sizes and to convert to single channel data

% W. Gray Roncal

% inDir = '~/code/PMD2040';
% outDir = '~/code/PMD2040/PMD2040rgb';
% resample = 0.25;
% singleChannel = 1;

f = dir(fullfile(inDir,'*.jp2'));
if ~exist(outDir)
    mkdir(outDir)
end

for i = 1:length(f)
    sprintf('Now processing file %d of %d...\n',i,length(f))
    im = imread(fullfile(inDir, f(i).name));
    im = imresize(im,resample,'nearest');
    
    resStr = num2str(resample);
    idx = strfind(resStr,'.'); 
    resStr(idx) = [];
    
    if singleChannel == 1
        im = rgb2gray(im);
        chan = 'gray';
    else
        chan = 'rgb';
    end
    
    [~,file,~] = fileparts(f(i).name);
    imwrite(im,fullfile(outDir, [file,'_',chan,'_',resStr,'.tif']));
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
