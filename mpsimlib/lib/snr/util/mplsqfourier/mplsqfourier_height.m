function domain = mplsqfourier_height (input)
% Usage (all input examples below produce the same output):
% - vector with entire domain vector: mplsqfourier_height(2:0.1:3)
% - cell with limits [min max]: mplsqfourier_height({[2 3]})
% - cell with limits [min max] and step: mplsqfourier_height({[2 3], 0.1})
% - cell with limits [min max], step, and central height: mplsqfourier_height({[-0.5 +0.5], 0.1, 2.5})
% - cell with step, center, and half-width: mplsqfourier_height({[], 0.1, 2.5, 0.5})
% Note: a non-cell input will always be interpreted as the entire domain, even if made of only one or two elements.
% - WRONG! non-cell with limits (min, max): mplsqfourier_height([2 3])

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
function domain = mplsqfourier_height_aux (lim, step, h0, half_width)
    %if (nargin < 1) || isempty(lim),  lim = [1 3];  end
    %if (nargin < 1) || isempty(lim),  lim = [0 4];  end
    if (nargin < 1),  lim = [];  end,  lim_default = [0 4];
    if (nargin < 2) || isempty(step),  step = 1e-2;  end
    if (nargin < 3) || isempty(h0),  h0 = 0;  end
    if (nargin < 4),  half_width = [];  end
    
    assert(numel(step) == 1)
    if (nargin > 2) % >= 3
        %assert(xor(isempty(lim), isempty(delta)))
        if ~isempty(half_width)
            assert(isempty(lim))
            if isscalar(half_width),  half_width = [-1, +1] * half_width;  end
            lim = half_width;
        else
            assert(isempty(half_width))
            if isempty(lim),  lim = lim_default;  end
        end
        lim = lim + h0;
    else
        if isempty(lim),  lim = lim_default;  end
    end
    %lim  % DEBUG
    assert(numel(lim) == 2)
    domain = (lim(1):step:lim(2))';
end

