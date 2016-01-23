% Example of using mana to do ground truthing on local data

% get data
img = mana_get_local(filename, dirname, xArgs, yArgs);

% do truthing in ITK snap and save segmentation

%put data
mana_put_local('/sample_data/test_segmentation.nii', labelOut,-1)