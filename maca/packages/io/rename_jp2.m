function rename_jp2(inDir,outDir,series, prefix)

inDir = '~/code/WillJHU_PMD2040';
outDir = '~/code/PMD2040';
series = 'PMD2040';
prefix = '_0';

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
