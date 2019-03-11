function varargout = meanu (varargin)
%MEANU  Uncertainty-weighted mean.
    nargchk(nargin, 1, 3);
    varargin(end+1:3) = {[]};
    ignore_nans = false;
    [varargout{1:nargout}] = nanmeanu (varargin{:}, ignore_nans);
end

%!test
%! n = 3;
%! obs = rand(3);
%! std = rand(3);
%! dim = 1;
%! wmeana = nanmeanu(obs, std, dim, false);
%! wmeanb =    meanu(obs, std, dim);
%! wmeanc =    meanu(obs, std);
%! %wmeana, wmeanb, wmeanc
%! myassert(wmeana, wmeanb)
%! myassert(wmeana, wmeanc)

