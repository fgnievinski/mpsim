function [average, std] = weighted_average (sample, sample_std)
    if isvector(sample)
        if (nargout == 2)
            [average, std] = weighted_average_vec (sample, sample_std);
        else
            average = weighted_average_vec (sample, sample_std);
        end
        return;
    end
    n = size(sample,2);
    for j=1:n
        if (nargout == 2)
            [average(:,j), std(:,j)] = weighted_average_vec (...
                sample(:,j), sample_std(:,j));
        else
            average(:,j) = weighted_average_vec (sample(:,j), sample_std(:,j));
        end
    end
end

function [average, std] = weighted_average_vec (sample, sample_std)
    assert(isvector(sample))
    assert(isequal(size(sample), size(sample_std)));
    sample_std(sample_std==0) = NaN;
    m = sum(isnan(sample) | isnan(sample_std));
    sample_var = sample_std.^2;
    weight_den = sample_var;
    weight_num = nansum(sample_var.^-1)^-1;
    weight = weight_num ./ weight_den;
    average = nansum(weight .* sample);
    if (nargout < 2),  return;  end
    residual = sample - average;
    variance_unity = (numel(sample) - m - 1)^-1 * nansum((residual./sample_std).^2);
    variance = weight_num * variance_unity;
    std = sqrt(variance);
    %disp([variance, weight_num, variance_unity])  % DEBUG
end

