function truth_entire_directory(inDir, outDir)
% TRUTH_ENTIRE_DIRECTORY  Generates per-pixel class labels for all files 
%                         in a directory
%
%    truth_entire_directory(inputDirectory, outputDirectory)
% 
%  Example:
%    truth_entire_directory('../data/orig/train', '../data/cell-vs-noncell-auto/train');
%    truth_entire_directory('../data/orig/test', '../data/cell-vs-noncell-auto/test');


files = dir([inDir filesep '*.png']);

if length(files) == 0
    error('no .png files found in directory: ' + inDir);
end

if ~exist(outDir, 'dir')
    mkdir(outDir);
end


for ii = 1:length(files)
    fn = fullfile(inDir, files(ii).name);
    Xraw = imread(fn);
    assert(ndims(Xraw) == 2);
    
    [IsCell, IsNonCell, X] = truth_image(Xraw);
    
    Y = zeros(size(X));
    Y(IsNonCell) = 1;
    Y(IsCell) = 2;
   
    [~,name,ext] = fileparts(files(ii).name);
    fn = fullfile(outDir, [name  '.mat']);   
    save(fn, 'Y', 'X', '-v7.3');  % save in HDF5 (non-proprietary)
    
    fprintf('[info]: extracted truth from %s\n', files(ii).name);
    fprintf('[info]:   # of cell/non-cell/unknown: %d/%d/%d\n', ...
            sum(Y(:)==2), sum(Y(:) == 1), sum(Y(:)==0));
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
