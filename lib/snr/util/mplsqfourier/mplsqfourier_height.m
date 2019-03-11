function domain = mplsqfourier_height (input)
% Usage (all produce the same output):
% mplsqfourier_height(2:0.1:3)
% mplsqfourier_height({[2 3], 0.1})
% mplsqfourier_height({[], 0.1, 2.5, 0.5})
    if (nargin < 1) || isempty(input)
        domain = mplsqfourier_height_aux ();
    elseif iscell(input)
        domain = mplsqfourier_height_aux (input{:});
    elseif isstruct(input)
        domain = input;
    elseif isvector(input)
        domain = input(:);
    end
end

%%
function domain = mplsqfourier_height_aux (lim, step, h0, delta)
    %if (nargin < 1) || isempty(lim),  lim = [1 3];  end
    if (nargin < 1) || isempty(lim),  lim = [0 4];  end
    if (nargin < 2) || isempty(step),  step = 1e-2;  end
    if (nargin < 3) || isempty(h0),  h0 = 0;  end
    if (nargin < 4),  delta = [];  end
    assert(numel(step) == 1)
    if (nargin > 2)
        assert(~isempty(delta))
        if isscalar(delta),  delta = [-1, +1] * delta;  end
        lim = h0 + delta;
    end
    %lim  % DEBUG
    assert(numel(lim) == 2)
    domain = (lim(1):step:lim(2))';
end

