function out = strsub (in, ind, len)
%STRSUB: Extract substrings in input string.
%   OUT = STRSUB(IN, IND, LEN) returns the substring starting at initial 
%   index IND and optional length LEN.  The input string IN can be a cell
%   array, in which case the indices IND, LEN can be vectors. See examples
%   at the bottom.

    if ~iscell(in)
        if isvector(in)
            if (nargin < 3)
                out = in(ind:end);
            else
                out = in(ind:min(end,ind+len-1));
            end
        else
            if (nargin < 3)
                out = in(:,ind:end);
            else
                out = in(:,ind:min(end,ind+len-1));
            end
        end
    else
        cellfun2 = @(varargin) cellfun(varargin{:}, 'UniformOutput',false);
        if (nargin < 3)
            if isscalar(ind)
                out = cellfun2(@(in) strsub(in, ind), in);
            else
                ind = reshape(ind, size(in));
                ind = num2cell(ind);
                out = cellfun2(@strsub, in, ind);
            end
        else
            if isscalar(ind) && isscalar(len)
                out = cellfun2(@(in) strsub(in, ind, len), in);
            else
                ind = reshape(ind, size(in));
                len = reshape(len, size(in));
                ind = num2cell(ind);
                len = num2cell(len);
                out = cellfun2(@strsub, in, ind, len);
            end
        end
    end
end

%!test
%! myassert(strsub('abcdefg', 3), 'cdefg')  % char array
%! myassert(strsub('abcdefg', 3, 2), 'cd')  % char array
%! myassert(strsub('abcdefg'.', 3), 'cdefg'.')  % column char array
%! myassert(strsub('abcdefg'.', 3, 2), 'cd'.')  % column char array
%! myassert(strsub(repmat('abcdefg', [2 1]), 3, 2), repmat('cd', [2 1]))  % matrix
%! myassert(strsub(repmat({'abcdefg'}, [2 1]), 3, 2), repmat({'cd'}, [2 1]))  % cellstr
%! myassert(strsub(repmat({'abcdefg'}, [2 1]), [3 3], [2 1]), {'cd';'c'})  % cellstr, vector indices

