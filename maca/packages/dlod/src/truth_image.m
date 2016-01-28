function [IsCell, IsNonCell, Xi] = truth_image(X, epsilon, thresh, showPlot)
% TRUTH_IMAGE: Extends cell body ground truth to all pixels in image.
%
%   [IsCell, IsNonCell, Xinterp] = truth_image(X, epsilon, thresh, showPlot)
%
%     where:
%       X : an (m x n) matrix of image data where cell body truth has
%           been superimposed by setting certain pixel values to 255.
%
%       epsilon: The radius of the epsilon ball to use for erosion and dilation.
%
%       thresh: The pixel intensity threshold to use when calculating 
%               connected components.
%
%       showPlot: If 1/true, displays a class label visualization.
%
%       IsCell : an (m x n) boolean matrix indicating presumed cell body pixels
%
%       IsNonCell : an (m x n) boolean matrix indicating presumed non-cell pixels
%
%       Xi : A copy of X where the pixels with value 255 have been interpolated
%            away.
%
%  This function takes images that are sparsely labeled with cell body 
%  labels and extends these labels to (a subset of) the rest of the image.
%
%  The (ad hoc) rule used here to generate these additional labels is:
%    - any pixel within an epsilon ball of a user annotation is y=cell
%    - any pixel within same connected component (as determined by
%      the threshold argument) as user annotation is y=cell
%    - anything else is eroded by a factor; what survives is y=non-cell
%
%  Note this implies that some pixels (presumabely those near cell boundaries) 
%  will be left unlabeled.  This is intentional - we do not want to train
%  on the least certain data.
%
%  This function is a bit of a band-aid to support a proof-of concept; 
%  a better approach is to get reliable dense class labels.


% Defaults selected arbitrarily; more careful selection left to the caller.
if nargin < 4, showPlot=1; end
if nargin < 3, thresh=180; end
if nargin < 2, epsilon=5; end


assert(max(X(:)) <= 255);
assert(min(X(:)) >= 0);


% Rule 1: any pixel within epsilon of a labeled pixel is cell.
IsCell = (X == 255);
se = strel('disk', epsilon);
IsCell = imdilate(IsCell, se);

% Rule 2: any pixel within the same connected component as a labeled pixel is cell.
%
% interpolate away class labels.
Xi = X;
Xbar = mean4(X);
Xi(X==255) = Xbar(X==255);

cc = bwconncomp(Xi < thresh);
for ii = 1:cc.NumObjects
    if any(X(cc.PixelIdxList{ii}) == 255)
        IsCell(cc.PixelIdxList{ii}) = 1;
    end
end

% Rule 3: a subset of what remains is non-cell
IsNonCell = imerode(~IsCell, se);

if 1
    h1 = figure;
    colormap(bone);
    imagesc(X); colorbar;
    
    h2 = figure;
    colormap default;
    imagesc(double(IsCell) - double(IsNonCell));
    hold on;
    [row,col] = ind2sub(size(X), find(X==255));
    plot(col,row,'ro');
    hold off;
    colorbar;
    
    linkaxes([h1.CurrentAxes, h2.CurrentAxes], 'xy');
end


end % truthing()



function M = mean4(X)
    assert(ndims(X) == 2);
    X = double(X);
    zeroRow = zeros(size(X(1,:)));
    zeroCol = zeros(size(X(:,1)));
  
    Xsouth = [X(2:end,:) ; zeroRow];
    Xnorth = [zeroRow ; X(1:end-1,:)];
    Xeast =  [X(:,2:end)  zeroCol];
    Xwest =  [zeroCol  X(:,1:end-1)];

    % NN := stores number of neighbors
    %       Domain is not periodic, so only 3 neighbors on edges and
    %       2 on corners.
    NN = 4 * ones(size(X));  
    NN(1,:) = NN(1,:) - 1;
    NN(end,:) = NN(end,:) - 1;
    NN(:,1) = NN(:,1) - 1;
    NN(:,end) = NN(:,end) - 1;
    
    M = (Xnorth + Xsouth + Xeast + Xwest) ./ NN;
end

% (c) 2015 The Johns Hopkins University / Applied Physics Laboratory 
% All Rights Reserved. Contact the JHU/APL Office of Technology Transfer for any # additional rights.  www.jhuapl.edu/ott
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%    http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

