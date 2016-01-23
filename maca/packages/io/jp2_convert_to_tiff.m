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

    
