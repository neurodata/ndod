% Only the following two projects are currently supported
% as an initial test case
token = 'mitra14N788';
%token = 'mitra14IHC1035';
serverLocation = 'http://braingraph1.cs.jhu.edu/';
% data location
outputDir = '/sample_data/';

% resolution (0 is full resolution)
resolution = 0;

% Uncomment the relevant lines to retrieve a data volume
% Truth chunk 1
% xArgs = [12650,12850]; % N788
% yArgs = [10100,10300];
% zArgs = [104,105];

% Truth chunk 2
% xArgs = [19400,19600]; % N788
% yArgs = [10900,11100];
% zArgs = [75,76];

% Truth chunk 3
%  xArgs = [20900,21100]; % N788
%  yArgs = [8800,9000];
%  zArgs = [192,193];

% Truth chunk 4
% xArgs = [20850,21050]; % N788
% yArgs = [8500,8700];
% zArgs = [160,161];

% Truth chunk 5
% xArgs = [18000,18200]; % N788
% yArgs = [8500,8700];
% zArgs = [240,241];

% Truth chunk 6
xArgs = [12000,12200]; % N788
yArgs = [8500,8700];
zArgs = [140,141];

labelOut = '/sample_data/test_output';

%get data - option 1 (remote - ocp calls)
ocp_get_cshl_data(serverLocation, token, resolution, outputDir, xArgs, yArgs, zArgs);

% Uncomment the following lines to write data or do local ingest
% get data - option 2 (local)
%img = get_local_data(filename, dirname, xArgs, yArgs);

% do truthing in ITK snap and save segmentation
%put data
%put_truthing_data('/sample_data/test_segmentation.nii', labelOut,-1)
