function cluster_postprocess_mbcd(inputFile, outputprefix)
% Cell Cluster Post Processing
% Will Gray Roncal, v1.0

% Input is a mat file containing the variable prob
% Output is a thresholded labeled image and a corresponding
% MAT file containing cell statistics.  Basic stats are provided as
% an example and can be extended.
%
% A short parameter structure is provided immediately below.  This function
% may need to be modified for user needs.

% modify these parameters if necessary
threshold = 0.5;
minSize2D = 50;
maxSize2D = 1000000;
minSize3D = 0;
% if used for processing raw images, flip the intensities so that cells appear bright
% for ilastik post processing, leave = 0
flipIntensity = 0;

im = imread(inputFile);

stats.objCentroid = [];
stats.objSize = [];


%% Core code

if size(im,3) > 1
    cellDetect = rgb2gray(im);
else
    cellDetect = im;
end

if max(im(:)) > 1
    cellDetect = double(cellDetect)/double(max(cellDetect(:)));
end

if flipIntensity
    cellDetect = 1 - cellDetect;
end

H = fspecial('gaussian',2);
cellDetect = imfilter(cellDetect,H,'replicate');

cellDetect = cellDetect > threshold;
cellDetect = bwareaopen(cellDetect,minSize2D);

% get size of each region
cc = bwconncomp(cellDetect, 4);

% check each region
for ii = 1:cc.NumObjects
    %to be small
    if length(cc.PixelIdxList{ii}) < minSize2D || length(cc.PixelIdxList{ii}) > maxSize2D
        cellDetect(cc.PixelIdxList{ii}) = 0;
        continue;
    end
    
end

% re-run connected components
cc = bwconncomp(cellDetect,8);
cellDetect = labelmatrix(cc);


%% Object Stats
fprintf('Creating CellCluster Objects...\n');

for ii = 1:cc.NumObjects
    
    [r,c,z] = ind2sub(size(cellDetect),cc.PixelIdxList{ii});
    
    
    % Approximate absolute centroid
    approxCentroid = [mean(r), mean(c), i];
    
    stats.objCentroid(end+1,:) = approxCentroid;
    stats.objSize(end+1,:) = length(r);
end

imwrite(cellDetect,[outputprefix, '_image.tif'])
save([outputprefix,'_stats.mat'], 'stats')