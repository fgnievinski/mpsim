% amplitude of noise sample through rmse
function out = rmseamp (in, robustify)
    if (nargin < 2) || isempty(robustify),  robustify = false;  end
    if robustify
        temp = nan_std_robust(in);
    else
        temp = nanstd(in);
    end
    out = rmse2amp(temp);
    if is_uniform(sign(in))
        warning('MATLAB:rmseamp:noSignChange', ...
            'Input does not change sign -- median recommended instead.');
    end
end
