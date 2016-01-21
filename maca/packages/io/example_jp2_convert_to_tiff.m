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