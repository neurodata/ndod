Configuration
*************

In order to use this truthing protocol, users should have the following software:

 * `CAJAL Toolbox <http://github.com/openconnectome/cajal>`_
 * `NIFTI Tools (distributed as part of CAJAL) <http://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image>`_
 * `ITK-Snap v 3.x <http://www.itksnap.org/>`_
 * A recent version of MATLAB
 * The manno toolbox <http://github.com/openconnectome/manno>`_

 Please follow the instructions with each program to download and install, and setup cajal and manno (as an installed toolbox).
 For the neurodata tools, you can be up and running with the following commands within MATLAB:

 .. code-block:: bash

   run('/share0/cajal/tools/matlab_install/setupEnvironment.m')
   run('/share0/cajal/cajal.m')
   cajal.installToolbox('~/code/manno/setup.m')

*This tool uses ITK-Snap for annotating, and MANNO+CAJAL to pull and push data appropriately.  It is not necessary for all annotators to use MATLAB and CAJAL, as long as they have a mechanism (such as a grad student) to help pull and push data.  Annotators only need to be able to load, annotate, and save within ITK Snap.*
