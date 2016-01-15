function run_manno_example()
% Manno Example 
% manno starter to demonstrate protocol functionality.  All required inputs
% are hardcoded for this demo.  Paths are hardcoded for Linux/Mac.
% 
% This example should be run from the code directory because of the
% relative paths
%
% The result of this run can be viewed in a webbrowser using the following
% URL: http://openconnecto.me/ocp/overlay/0.6/openconnecto.me/kasthuri11cc/image/openconnecto.me/manno/mito/xy/1/5472,5972/8712,9212/1031/

xstart = 5472;
xstop = xstart + 512;
ystart = 8712;
ystop = ystart + 512;
zstart = 1020;
zstop = zstart + 16;

resolution = 1;

query = OCPQuery;
query.setType(eOCPQueryType.imageDense);
query.setCutoutArgs([xstart, xstop],[ystart,ystop],[zstart,zstop],resolution);

save('../data/queryFileTest.mat','query')
%% Servers and tokens - alter appropriately
server = 'openconnecto.me';
token = 'kasthuri11cc';
channel = 'image';
serverUp = 'openconnecto.me';
tokenUp = 'manno';
channelUp = 'mito';
%% Run manno
manno_getImage(server,token,channel,'../data/queryFileTest','../data/testitk.nii',0)

% Manual annotation step happens here
manno_putAnno(serverUp,tokenUp,channelUp,'../data/queryFileTest','../data/mito_seg_example.nii.gz','RAMONOrganelle', 1,0)