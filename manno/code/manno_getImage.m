function manno_getImage(server, token, channel, queryFile, fileOut, useSemaphore)
% MANNO function to get OCP image data and format it to be
% compatible with ITK-Snap.
%
% **Inputs**
%
%	server: [string]
%		- OCP server name hosting the image data of interest
%
%	token: [string]
%		- OCP token name for the annotation data of interest
%
%	channel: [string]
%		- OCP channel name for the annotation data of interest
%
%	queryFile: [string]
%		- path and filename for queryFile.  Should be a MAT file containing one OCPQuery variable, named 'query'
%
%	fileOut: [string]
%		- path and filename for NIFTI image file to use in ITK Snap for annotating
%
%	useSemaphore: [number][default=0]
%		- Throttles reading/writing client-side for large batch jobs.  Not needed in single cutout mode
%
% **Outputs**
%
%	No explicit outputs.  Output file is saved to disk rather than
%	output as a variable to allow for downstream integration with LONI.
%
% **Notes**
%
%	Currently only uint8 image data is supported.  Multichannel data may
%	produce unexpected results.


cubeCutout(token, channel, queryFile, 'tempCutout', useSemaphore, 0, server)

load('tempCutout')
im = cube;
im = permute(rot90(im.data,2),[2,1,3]);

if isa(im, 'uint8') == 1
    nii = make_nii(im, [1 1 1], [0 0 0], 2);
else
    nii = make_nii(im);
end
save_nii(nii, fileOut);