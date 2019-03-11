function [wmean, ws] = meanw (obs, dim)
%MEANW Weighted meam.
% 
% See also:  RMSE, STDR.

    if (nargin < 2),  dim = [];  end
    detrendit = false;
    [wmean, ws] = nanmeanw (obs, dim, detrendit);
end

