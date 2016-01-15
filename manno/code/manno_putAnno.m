function manno_putAnno(server, token, channel, queryFile, fileIn, protoRAMON, doConnComp, useSemaphore)
% MANNO function to upload annotation data from ITK-Snap to OCP.
%
% **Inputs**
%
%	server: [string]
%		- OCP server where annotation data will reside
%
%	token: [string]
%		- OCP token name for the annotation data of interest
%
%	channel: [string]
%		- OCP channel name for the annotation data of interest
%
%	queryFile: [string]
%		- path and filename for queryFile.  Should be a MAT file containing one OCPQuery variable, named 'query'.  This should be the same as the queryFile used to cutout data
%
%	fileIn: [string]
%		- path and filename for NIFTI segmentation file saved in ITK Snap
%
%	protoRAMON: [string]
%		- A prototype RAMONObject; each annotation object created will be based on this template (e.g., RAMONOrganelle, RAMONSynapse).  Users can set fields (e.g., author, confidence) by writing wrapper scripts
%
%	doConnComp: [number]
%		- If equal to 1, objects will be relabeled based on 3D (26-connected) voxels.  If set to 0, objects will be uploaded exactly as created.
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


nii = load_nii(fileIn);
anno = nii.img;

anno = permute(rot90(anno,2),[2,1,3]);

if doConnComp
    anno = anno > 0;
    cc = bwconncomp(anno,26);
    anno = labelmatrix(cc);
end

load(queryFile)

ANNO = RAMONVolume;
ANNO.setCutout(anno);
ANNO.setResolution(query.resolution);
ANNO.setXyzOffset([query.xRange(1),query.yRange(1),query.zRange(1)]);

cubeUploadDense(server,token, channel, ANNO,protoRAMON,useSemaphore)
