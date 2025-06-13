function [slope, aspect, azim, size_original] = slopeaspectazim_expand (slope, aspect, azim)
    size_azim   = size(azim);
    size_aspect = size(aspect);
    size_slope  = size(slope);
    azim   = azim(:);
    aspect = aspect(:);
    slope  = slope(:);
    assert(isequal(size_slope, size_aspect))
    if (numel(azim) == numel(aspect))
        % do nothing.
        size_original = size_azim;
    elseif isscalar(azim)
        azim = repmat(azim, size(aspect));
        size_original = size_aspect;
    else
        assert(isscalar(aspect))
        aspect = repmat(aspect, [prod(size_azim),1]);
        slope  = repmat(slope,  [prod(size_azim),1]);
        size_original = size_azim;
    end
end

