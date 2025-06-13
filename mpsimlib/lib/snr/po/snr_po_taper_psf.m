function psf = snr_po_taper_psf (info, setup) %#ok<INUSL>
    % taper_gaussian_sigma_in_pixels = setup.opt.taper_gaussian_sigma(:) ./ info.step(:);
    % taper_gaussian_hsize_in_pixels = setup.opt.taper_gaussian_hsize(:) ./ info.step(:);
    taper_gaussian_sigma_in_pixels = setup.opt.taper_gaussian_sigma_in_pixels(:);
    taper_gaussian_hsize_in_pixels = setup.opt.taper_gaussian_hsize_in_pixels(:);

    taper_gaussian_sigma_in_pixels = mean(taper_gaussian_sigma_in_pixels);  % fspecial requires scalar
    taper_gaussian_hsize_in_pixels = ceil(taper_gaussian_hsize_in_pixels);  % fspecial requires integer
    
    psf = fspecial('gaussian', ...
        taper_gaussian_hsize_in_pixels, ...
        taper_gaussian_sigma_in_pixels  ...
    );
end
