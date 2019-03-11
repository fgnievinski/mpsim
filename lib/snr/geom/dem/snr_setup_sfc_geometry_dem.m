function sfc = snr_setup_sfc_geometry_dem (pos_ant, pos_sfc0, sett_sfc)
    if (nargin < 2) || isempty(pos_sfc0),  pos_sfc0 = [0 0 0];  end
    if ~isfieldempty(sett_sfc, 'slope') ...
    && (sett_sfc.slope ~= 0) && ~isnan(sett_sfc.slope)
        warning('snr:snr_setup_sfc_geometry_dem:slope', ...
            'Ignoring non-zero slope.');
    end
    if isfieldempty(sett_sfc, 'type'),  sett_sfc.type = 'poly';  end

    sfc = struct();
    switch lower(sett_sfc.type)
    case {'user'},  sfc.type = sett_sfc.type;
    case {'poly', 'polynomial', 'global polynomial'},  sfc.type = 'poly';
    case {'grid', 'gridded', 'interp', 'interpolated'},  sfc.type = 'grid';
    %case {'spline', 'piecewise polynomial'}  %TODO (hint: spline2.m)
    %case {'tin', 'triangulated'}  %TODO (faceted, not pixelated.)
    otherwise
        error('snr:snr_setup_sfc_geometry_dem:badType', ...
            'Unknown type "%s".', sett_sfc.type);
    end
    sfc = feval(['snr_setup_sfc_geometry_dem_' sfc.type], sett_sfc, sfc);
    
    sfc.snr_fwd_geometry_reflection = @snr_fwd_geometry_reflection_dem;
    sfc.snr_fwd_direction_local2sfc = @snr_fwd_direction_local2sfc_dem;
    sfc.snr_fwd_visibility          = @snr_fwd_visibility_dem;
    sfc.snr_fwd_divergence          = @snr_fwd_divergence_dem;
    sfc.snr_fwd_geometry_sfc_height = @snr_fwd_geometry_sfc_height_dem;

    if isfieldempty(sett_sfc, 'dem_is_relative'),  sett_sfc.dem_is_relative = true;  end
    sfc.dem_is_relative = sett_sfc.dem_is_relative;
    sfc.pos_sfc0 = pos_sfc0;
    clear pos_sfc0  % avoid misuse.
    sfc.height0 = snr_fwd_geometry_height_self (sfc.pos_sfc0(:,1:2), ...
        setfield(sfc, 'dem_is_relative',false));
    if ~sfc.dem_is_relative
        sfc.pos_sfc0(:,3) = sfc.pos_sfc0(:,3) + sfc.height0;
    end
    %sfc.snr_fwd_geometry_sfc_height(sfc.pos_sfc0, [], sfc)  % DEBUG
    
    %sfc.height_ant_sfc = pos_ant(:,3) - sfc.pos_sfc0(:,3);  % WRONG!
    sfc.height_ant_sfc = pos_ant(:,3) - snr_fwd_geometry_height_self (...
        pos_ant(:,1:2), sfc);
    
    if isfieldempty(sett_sfc, 'approximateit'),  sett_sfc.approximateit = true;  end
    sfc.approximateit = sett_sfc.approximateit;
    if sfc.approximateit,  sfc.approx = snr_setup_sfc_geometry_horiz (pos_ant, sfc.pos_sfc0);  end
    sfc.num_specular_max = 1;  % TODO: change after updating sfc.approx with PO calibration.
end

function sfc = snr_setup_sfc_geometry_dem_user (sett_sfc, sfc) %#ok<DEFNU>
    sfc.snr_fwd_geometry_height_self_aux = @(x, y, sfc) sett_sfc.fnc_height_self(x, y);
    sfc.snr_fwd_geometry_height_grad_aux = @(x, y, sfc) sett_sfc.fnc_height_grad(x, y);
    sfc.snr_fwd_geometry_height_hess_aux = @(x, y, sfc) sett_sfc.fnc_height_hess(x, y);
end

function sfc = snr_setup_sfc_geometry_dem_poly (sett_sfc, sfc) %#ok<DEFNU>
    sfc.coeff = sett_sfc.coeff;
    sfc.coeffs = polyhess2_aux (sfc.coeff);
    sfc.snr_fwd_geometry_height_self_aux = @(x, y, sfc)  polyval2(sfc.coeff, x, y);
    sfc.snr_fwd_geometry_height_grad_aux = @(x, y, sfc) polygrad2(sfc.coeff, x, y, ...
        sfc.coeffs.cdx, sfc.coeffs.cdy);
    sfc.snr_fwd_geometry_height_hess_aux = @(x, y, sfc) polyhess2(sfc.coeff, x, y, ...
        sfc.coeffs.cdx2, sfc.coeffs.cdy2, sfc.coeffs.cdxy);
end

function sfc = snr_setup_sfc_geometry_dem_grid (sett_sfc, sfc) %#ok<DEFNU>
    sett_sfc_defaults = struct();
    sett_sfc_defaults.suppress_edges = false;
    sett_sfc_defaults.crop_halfdim = 150;  % in meters.
    sett_sfc_defaults.smoothing_radius = 5;  % in meters.
    sett_sfc_defaults.get_gradient = true;
    sett_sfc_defaults.get_hessian = true;
    sett_sfc_defaults.PO_not_GO = false;
    sett_sfc_defaults.plotit = false;
    sett_sfc_defaults.cropit = true;
    sett_sfc_defaults.method = 'spline';
    %sett_sfc_defaults.approximateit = true;  % WRONG! needs for all grid types.
    if isfield(sett_sfc, 'PO_not_GO') && sett_sfc.PO_not_GO
        sett_sfc_defaults.suppress_edges = false;
        sett_sfc_defaults.crop_halfdim = Inf;
        sett_sfc_defaults.smoothing_radius = NaN;
        sett_sfc_defaults.get_gradient = false;
        sett_sfc_defaults.get_hessian = false;
        sett_sfc_defaults.method = 'cubic';
    end
    sett_sfc = structmergenonempty(sett_sfc_defaults, sett_sfc);
    sfc.grid = sett_sfc.grid;
    sfc.grid.siz = size(sfc.grid.z);
    sfc.method = sett_sfc.method;
    if isfieldempty(sfc.grid, 'x') ...
    || isfieldempty(sfc.grid, 'y') ...
    || ~isequal(size(sfc.grid.x), sfc.grid.siz) ...
    || ~isequal(size(sfc.grid.y), sfc.grid.siz)
        [sfc.grid.x, sfc.grid.y] = meshgrid(sfc.grid.x_domain, sfc.grid.y_domain);
    end
    if isfieldempty(sfc.grid, 'x_domain') ...
    || isfieldempty(sfc.grid, 'y_domain')
        sfc.grid.x_domain = sfc.grid.x(1,:);
        sfc.grid.y_domain = sfc.grid.y(:,1);
    end
    if sett_sfc.cropit && isfinite(sett_sfc.crop_halfdim) && (sett_sfc.crop_halfdim > 0) ...
    && (sett_sfc.crop_halfdim*2 < min(diff(sfc.grid.x_domain([1 end])), diff(sfc.grid.x_domain([1 end]))))
        sfc.grid_uncrop = sfc.grid;
        sfc.grid = struct();
        [sfc.grid.z, sfc.grid.x_domain, sfc.grid.y_domain] = imcrop2 (sett_sfc.crop_halfdim, ...
            sfc.grid_uncrop.z, sfc.grid_uncrop.x_domain, sfc.grid_uncrop.y_domain);
        [sfc.grid.x, sfc.grid.y] = meshgrid(sfc.grid.x_domain, sfc.grid.y_domain);
    end
    idx = isnan(sfc.grid.z);
    if any(idx(:))
        warning('snr:snr_setup_sfc_geometry_dem:zNaN', ...
            'NaN found in Z grid; replacing with median height.');
        sfc.grid.z(idx) = nanmedian(sfc.grid.z(:));
    end
    if isfinite(sett_sfc.smoothing_radius) && (sett_sfc.smoothing_radius > 0) ...
    && (sett_sfc.smoothing_radius > sqrt(range(sfc.grid.x_domain).^2 + range(sfc.grid.y_domain).^2))
        sfc.grid_unsmooth = sfc.grid;
        sfc.grid = [];
        temp = ( mode(diff(sfc.grid_unsmooth.x_domain)) + mode(diff(sfc.grid_unsmooth.y_domain)) ) / 2;
        sfc.grid.z = filter2(fspecial('disk', sett_sfc.smoothing_radius/temp), sfc.grid_unsmooth.z, 'valid');
        [n1, n2] = size(sfc.grid.z);
        [n1_unsmooth, n2_unsmooth] = size(sfc.grid_unsmooth.z);
        sfc.grid.x_domain = sfc.grid_unsmooth.x_domain( (1:n2) + round((n2_unsmooth-n2)/2) );
        sfc.grid.y_domain = sfc.grid_unsmooth.y_domain( (1:n1) + round((n1_unsmooth-n1)/2) );
        [sfc.grid.x, sfc.grid.y] = meshgrid(sfc.grid.x_domain, sfc.grid.y_domain);
    end
    sfc.grid.x_lim = sfc.grid.x_domain([1 end]);
    sfc.grid.y_lim = sfc.grid.y_domain([1 end]);
    if sett_sfc.get_gradient && ( ...
       ~isfield(sfc.grid, 'dz_dx') || isempty(sfc.grid.dz_dx) ...
    || ~isfield(sfc.grid, 'dz_dy') || isempty(sfc.grid.dz_dy) )
        [sfc.grid.dz_dx, sfc.grid.dz_dy] = gradient(sfc.grid.z, ...
            sfc.grid.x_domain, sfc.grid.y_domain);
        if sett_sfc.suppress_edges
            ind = get_border_ind(sfc.grid.z);
            %figure, subplot(2,3,1), imagesc(sfc.grid.x_domain, sfc.grid.y_domain, sfc.grid.dz_dx), axis image  % DEBUG
            sfc.grid.dz_dx(ind) = NaN;
            sfc.grid.dz_dy(ind) = NaN;
            %figure, subplot(2,3,1), imagesc(sfc.grid.x_domain, sfc.grid.y_domain, sfc.grid.dz_dx), axis image  % DEBUG
            %keyboard  % DEBUG
        end
    end
    if sett_sfc.get_hessian && ( ...
       ~isfield(sfc.grid, 'dz2_dx2') || isempty(sfc.grid.dz2_dx2) ...
    || ~isfield(sfc.grid, 'dz2_dy2') || isempty(sfc.grid.dz2_dy2) ...
    || ~isfield(sfc.grid, 'dz2_dxy') || isempty(sfc.grid.dz2_dxy) )
        [sfc.grid.dz2_dx2, sfc.grid.dz2_dxy] = gradient(sfc.grid.dz_dx, ...
            sfc.grid.x_domain, sfc.grid.y_domain);
        [sfc.grid.dz2_dyx, sfc.grid.dz2_dy2] = gradient(sfc.grid.dz_dy, ...
            sfc.grid.x_domain, sfc.grid.y_domain);
          temp = max(abs(sfc.grid.dz2_dyx(:) - sfc.grid.dz2_dxy(:)));
          assert(temp < sqrt(eps()))
        %if sett_sfc.suppress_edges
        %    % unnecessary because NaN's in gradient will propagate to Hess.
        %end
    end
% Deprecated in Matlab/Octave:    
%    if (sfc.method(1) ~= '*') ...
%    && is_regularly_spaced(sfc.grid.x_domain, sqrt(eps())) ...
%    && is_regularly_spaced(sfc.grid.y_domain, sqrt(eps()))
%        sfc.method = ['*' sfc.method];
%    end
    [sfc.snr_fwd_geometry_height_self_aux, ...
     sfc.snr_fwd_geometry_height_grad_aux, ...
     sfc.snr_fwd_geometry_height_hess_aux] ...
        = setup_fhandles ();
    %keyboard  % DEBUG
    if sett_sfc.plotit
        [sfc.grid.slope, sfc.grid.aspect] = horizgrad2slopeaspect (sfc.grid.dz_dx, sfc.grid.dz_dy);
        figure
          subplot(1,1,1), imagesc(sfc.grid.x_domain, sfc.grid.y_domain, sfc.grid.z), axis equal, axis image
        figure
          subplot(1,3,1), imagesc(sfc.grid.x_domain, sfc.grid.y_domain, sfc.grid.slope), axis equal, axis image, title('slope'), colorbar
          subplot(1,3,2), imagesc(sfc.grid.x_domain, sfc.grid.y_domain, sfc.grid.aspect), axis equal, axis image, title('aspect'), colormap(hsv), set(gca, 'CLim',[0,360]), h = colorbar; set(h, 'YTick',0:90:360)
        if sett_sfc.get_gradient
          figure
            subplot(1,3,1), imagesc(sfc.grid.x_domain, sfc.grid.y_domain, sfc.grid.z),     axis equal, axis image
            subplot(1,3,2), imagesc(sfc.grid.x_domain, sfc.grid.y_domain, sfc.grid.dz_dx), axis equal, axis image
            subplot(1,3,3), imagesc(sfc.grid.x_domain, sfc.grid.y_domain, sfc.grid.dz_dy), axis equal, axis image
        end
        if sett_sfc.get_hessian
          figure
            subplot(1,3,1), imagesc(sfc.grid.x_domain, sfc.grid.y_domain, sfc.grid.dz2_dxy), axis equal, axis image
            subplot(1,3,2), imagesc(sfc.grid.x_domain, sfc.grid.y_domain, sfc.grid.dz2_dx2), axis equal, axis image
            subplot(1,3,3), imagesc(sfc.grid.x_domain, sfc.grid.y_domain, sfc.grid.dz2_dy2), axis equal, axis image
        end
    end
end

function [self, grad, hess] = setup_fhandles ()
% setup function handles separately, otherwise they will soak up all the function's variables, even unused ones.
    temp = NaN;
    f = @(x, y, sfc, name) reshape(interp2nanxy(sfc.grid.x, sfc.grid.y, sfc.grid.(name), x(:), y(:), sfc.method, temp), size(x));
    self = @(x, y, sfc) f(x, y, sfc, 'z');
    grad = @(x, y, sfc) deal2([f(x, y, sfc,'dz_dx'),   f(x, y, sfc,'dz_dy')]);
    hess = @(x, y, sfc) deal2([f(x, y, sfc,'dz2_dx2'), f(x, y, sfc,'dz2_dy2'), f(x, y, sfc,'dz2_dxy')]);
end

% sfc = snr_setup_sfc_geometry_dem ([0 0 5], [0 0 0], struct('type','poly', 'coeff',[pi], 'dem_is_relative',false))
