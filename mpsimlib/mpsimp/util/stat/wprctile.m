function y = wprctile(X,p,varargin)
%WPRCTILE  Returns weighted percentiles of a sample with six algorithms.
% The idea is to give more emphasis in some examples of data as compared to
% others by giving more weight. For example, we could give lower weights to
% the outliers. The motivation to write this function is to compute percentiles
% for Monte Carlo simulations where some simulations are very bad (in terms of
% goodness of fit between simulated and actual value) than the others and to 
% give the lower weights based on some goodness of fit criteria.
%
% USAGE:
%         y = WPRCTILE(X,p)
%         y = WPRCTILE(X,p,w)
%         y = WPRCTILE(X,p,w,type)
%                                             
% INPUT:
%    X -  vector or matrix of the sample data                                 
%    p -  scalar  or a vector of percent values between 0 and 100
%
%    w -  positive weight vector for the sample data. Length of w must be
%         equal to either number of rows or columns of X. If X is matrix, same
%         weight vector w is used for all columns (DIM=1)or for all rows
%         (DIM=2). If the weights are equal, then WPRCTILE is same as PRCTILE.
%
%  type - an integer between 4 and 9 selecting one of the 6 quantile algorithms. 
%         Type 4: p(k) = k/n. That is, linear interpolation of the empirical cdf. 
%         Type 5: p(k) = (k-0.5)/n. That is a piecewise linear function where
%                 the knots are the values midway through the steps of the 
%                 empirical cdf. This is popular amongst hydrologists. (default)
%                 PRCTILE also uses this formula.
%         Type 6: p(k) = k/(n+1). Thus p(k) = E[F(x[k])]. 
%                 This is used by Minitab and by SPSS. 
%         Type 7: p(k) = (k-1)/(n-1). In this case, p(k) = mode[F(x[k])]. 
%                 This is used by S. 
%         Type 8: p(k) = (k-1/3)/(n+1/3). Then p(k) =~ median[F(x[k])]. 
%                 The resulting quantile estimates are approximately 
%                 median-unbiased regardless of the distribution of x. 
%         Type 9: p(k) = (k-3/8)/(n+1/4). The resulting quantile estimates are 
%                 approximately unbiased for the expected order statistics 
%                 if x is normally distributed.
%         
%         Interpolating between the points pk and X(k) gives the sample
%         quantile. Here pk is plotting position and X(k) is order statistics of
%         x such that x(k)< x(k+1) < x(k+2)...
%                  
% OUTPUT:
%    y - percentiles of the values in X
%        When X is a vector, y is the same size as p, and y(i) contains the
%        P(i)-th percentile.
%        When X is a matrix, WPRCTILE calculates percentiles along dimension DIM
%        which is based on: if size(X,1) == length(w), DIM = 1;
%                       elseif size(X,2) == length(w), DIM = 2;
%                      
% EXAMPLES:
%    w = rand(1000,1);
%    y = wprctile(x,[2.5 25 50 75 97.5],w,5);
%    % here if the size of x is 1000-by-50, then y will be size of 6-by-50
%    % if x is 50-by-1000, then y will be of the size of 50-by-6
% 
% Please note that this version of WPRCTILE will not work with NaNs values and
% planned to update in near future to handle NaNs values as missing values.
%
% References: Rob J. Hyndman and Yanan Fan, 1996, Sample Quantiles in Statistical
%             Package, The American Statistician, 50, 4. 
%
% HISTORY:
% version 1.0.0, Release 2007/10/16: Initial release
% version 1.1.0, Release 2008/04/02: Implementation of other 5 algorithms and
%                                    other minor improvements of code
%
%
% I appreciate the bug reports and suggestions.
% See also: PRCTILE (Statistical Toolbox)

% Author: Durga Lal Shrestha
% UNESCO-IHE Institute for Water Education, Delft, The Netherlands
% eMail: durgals@hotmail.com
% Website: http://www.hi.ihe.nl/durgalal/index.htm
% Copyright 2004-2007 Durga Lal Shrestha.
% $First created: 16-Oct-2007
% $Revision: 1.1.0 $ $Date: 02-Apr-2008 13:40:29 $

% ***********************************************************************

%% Input arguments check

error(nargchk(2,4,nargin))
if ~isvector(p) || numel(p) == 0
    error('wprctile:BadPercents', ...
          'P must be a scalar or a non-empty vector.');
elseif any(p < 0 | p > 100) || ~isreal(p)
    error('wprctile:BadPercents', ...
          'P must take real values between 0 and 100');
end
if ndims(X)>2
   error('wprctile:InvalidNumberofDimensions','X Must be 2D.')
end


% Default weight vector
if isvector(X)
	w = ones(length(X),1);         
else
	w = ones(size(X,1),1);   % works as dimension 1
end
type = 5; 

if nargin > 2
	if ~isempty(varargin{1})
		w = varargin{1};          % weight vector
	end
	if  nargin >3
		type = varargin{2};   % type to compute quantile
	end
end

if ~isvector(w)|| any(w<0) 
	error('wprctile:InvalidWeight', ...
          'w must vecor and values should be greater than 0');
end

% Check if there are NaN in any of the input
nans = isnan(X);
if any(nans(:)) || any(isnan(p))|| any(isnan(w))
	error('wprctile:NaNsInput',['This version of WPRCTILE will not work with ' ...
	      'NaNs values in any input and planned to update in near future to ' ...
		   'handle NaNs values as missing values.']);
end
%% Figure out which dimension WPRCTILE will work along using weight vector w

n = length(w);
[nrows ncols] = size(X);
if nrows==n
	dim = 1;
elseif ncols==n
	dim = 2;
else
	error('wprctile:InvalidDimension', ...
          'length of w must be equal to either number of rows or columns of X');
end

%% Work along DIM = 1 i.e. columswise, convert back later if needed using tflag

tflag = false; % flag to note transpose
if dim==2     
   X = X';
   tflag = true;  
end
ncols = size(X,2);
np = length(p);
y = zeros(np,ncols);

% Change w to column vector
w = w(:);

% normalise weight vector such that sum of the weight vector equals to n
w = w*n/sum(w);

%% Work on each column separately because of weight vector

for i=1:ncols
	[sortedX ind] = sort(X(:,i));  % sort the data
	sortedW = w(ind);              % rearrange the weight according to ind
	k = cumsum(sortedW);           % cumulative weight
	switch type                    % different algorithm to compute percentile
		case 4
			pk = k/n;
		case 5
			pk = (k-sortedW/2)/n;
		case 6
			pk = k/(n+1);
		case 7
			pk = (k-sortedW)/(n-1);
		case 8
			pk = (k-sortedW/3)/(n+1/3);
		case 9
			pk = (k-sortedW*3/8)/(n+1/4);
		otherwise
			error('wprctile:InvalidType', ...
				'Integer to select one of the six quantile algorithm should be between 4 to 9.')
	end
	
	% to avoid NaN for outside the range, the minimum or maximum values in X are
	% assigned to percentiles for percent values outside that range.
	q = [0;pk;1];
	xx = [sortedX(1); sortedX; sortedX(end)];
	
	% Interpolation between q and xx for given value of p
	y(:,i) = interp1q(q,xx,p(:)./100);
end

%% Transpose data back for DIM = 2 to the orginal dimension of X
% if p is row vector and X is vector then return y as row vector 
if tflag || (min(size(X))==1 && size(p,1)==1)    
	y=y';
end
