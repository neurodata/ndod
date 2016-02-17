% Cell Cluster Framework
% Will Gray Roncal, December 2014

% Modify these paths
sourceDir = '/mnt/data/will/N/';
outputDir = '/home/graywr1/partha_v1/';

fileList = dir([sourceDir,'*.ti*']);

threshold = 128;
minSize2D = 50;
maxSize2D = 1000000;
minSize3D = 0;

objCentroid = {};
objSize = [];
tic
for i = 1:length(fileList)
    i
    toc
    im = imread(fullfile(sourceDir,fileList(i).name));
    %% Core code
    Ismall = imresize(im,0.25);
    
    
    if i < 10
        istr = ['00',num2str(i)];
    elseif i < 100
        istr = ['0', num2str(i)];
    else
        istr = num2str(i);
    end
    
    imwrite(Ismall, ['cellCluster_V1_out_imageSmall_',istr,'.png']);
    
    
    cellDetect = rgb2gray(im);
    clear im Ismall
    H = fspecial('gaussian',2);
    cellDetect = imfilter(cellDetect,H,'replicate');
    
    cellDetect = cellDetect  < threshold;
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
    fprintf('Creating CellCluster Objects...');
    
    for ii = 1:cc.NumObjects
        
        [r,c,z] = ind2sub(size(cellDetect),cc.PixelIdxList{ii});
        
        
        % Approximate absolute centroid
        approxCentroid = [mean(r), mean(c), i];
        
        objCentroid{end+1} = approxCentroid;
        objSize(end+1) = length(r);
    end
    
    fprintf('done.\n');
    imwrite(cellDetect, ['cellCluster_V1_out_',istr,'.png'])
    
    Lsmall = imresize(cellDetect,0.25);
    imwrite(Lsmall, ['cellCluster_V1_out_labelSmall_',istr,'.png']);
end