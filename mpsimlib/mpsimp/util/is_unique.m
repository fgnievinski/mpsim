function [isu, inu, varargout] = is_unique (in, varargin)
    if (nargout <= 1)
        is_unique_sorted = @(in) none(diff(in(:)) == 0);
        % quick check assuming it's sorted:
        isu = is_unique_sorted(in);
        %return;  % WRONG! too soon
        if ~isu,  return;  end
        in = sort(in);
        isu = is_unique_sorted(in);
        return;
    end
    [inu, varargout{1:nargout-2}] = unique(in, varargin{:});
    isu = (numel(inu) == numel(in));
end

%!test
%! assert( is_unique([1 2 3]'))
%! assert( is_unique([1 2 3]))
%! assert(~is_unique([1 2 2]'))
%! assert(~is_unique([1 2 2]))
%! assert( is_unique([1 2 NaN]))
%! assert( is_unique([1 2 NaN NaN]))
%! %assert(~is_unique([1 2 NaN NaN]))  % WRONG!
%! assert(~is_unique([1 2 3 2]))
%! assert(~is_unique([2 1 2 3]))

