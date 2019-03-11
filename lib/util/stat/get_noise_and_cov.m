function [noise, cov, tol] = get_noise_and_cov (m, std)
    %m,  whos std % DEBUG
    if (nargin < 2),  std = 1;  end
    noise = std .* randn(m, 1);
    
    cov = noise * transpose(noise);
    % the formula above follows from the very definition of covariance.

    [cov, tol] = make_cov_posdef(cov);
    %figure, imagesc(cov), colorbar
end
