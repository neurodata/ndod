function rename_jp2(inDir,outDir,series, prefix)
% This is a utility function used to rename raw brain files to a format 
% where sequential files occur in alphabetical order and with simplified
% names

% inDir = '~/code/WillJHU_PMD2040';
% outDir = '~/code/PMD2040';
% series = 'PMD2040';
% prefix = '_0';

f = dir(fullfile(inDir,'*.jp2'));
if ~exist(outDir)
    mkdir(outDir)
end

for i = 1:length(f)
    
    idx = strfind(f(i).name,prefix);
    idx = idx(end); %last value
    [~, file, ext] = fileparts(f(i).name(idx:end));
    
    sprintf('Now processing file %d of %d...\n',i,length(f))
    
    copyfile(fullfile(inDir,f(i).name),fullfile(outDir,[series,file,ext]));
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
