function out = getel (in, varargin)
%     s = struct('type','()', 'subs',{varargin});
%     out = subsref(in, s);
%     return
    if all(cellfun(@(argin) isa(argin, 'function_handle'), varargin))
        out = in(feval(varargin{:}));
    elseif all(cellfun(@(argin) ~ischar(argin) || strcmp(argin, ':'), varargin))
        out = in(varargin{:});
    else
        temp = ['in(' varargin{:} ')'];
        %disp(temp)  % DEBUG
        out = eval(temp);
    end      
end
% getel = @(M, i, j) subsref(M, substruct('()', {i, j}));
% getel = @(M, i, j) M(i, j);

%!shared
%! m = ceil(10*rand);
%! n = ceil(10*rand);
%! o = ceil(10*rand);
%! i = round(randint(1, m));
%! j = round(randint(1, n));
%! k = round(randint(1, o));
%! A = rand(m,n,o);

%!test
%! myassert(getel(A, i,j,k), A(i,j,k))

%!test
%! myassert(getel(A, ':'), A(:))

%!test
%! myassert(getel(A, 1:1), A(1:1))
