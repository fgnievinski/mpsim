function [delay, vec_split, dist_scatt, dir_scatt, dist_incid, dir_incid] ...
= snr_fwd_geometry_delay_self (...
sfc_pos_horiz, sat_dir, pos_ant, sfc, ...
sfc_height, delay_incid_method)
    if (nargin < 5),  sfc_height = snr_fwd_geometry_height_self (sfc_pos_horiz, sfc);  end
    if (nargin < 6) || isempty(delay_incid_method),  delay_incid_method = [];  end
    assert(size(sfc_pos_horiz,2) == 2)
    [dist_scatt, dir_scatt] = snr_fwd_geometry_delay_self_scatt (...
        sfc_pos_horiz, sat_dir, pos_ant, sfc, sfc_height);
    [dist_incid, dir_incid] = snr_fwd_geometry_delay_self_incid (...
        sfc_pos_horiz, sat_dir, pos_ant, sfc, sfc_height, delay_incid_method);
    delay = dist_incid + dist_scatt;
    vec_split = add_all(dir_scatt, sat_dir); % = (dir_scatt - dir_incid)
end

%!test
%! % Here we compare solutions for height and delay
%! % (itself, its gradient, and its Hessian), 
%! % as given by 'poly' and 'interp' DEM types, 
%! % based on (1) their original implementation, 
%! % (2) grided numerical derivative, and 
%! % (3) pointwise numerical derivative.
%! rand('seed',0)  % DEBUG
%! height_ant = 3;
%! pos_ant = [0 0 height_ant];
%! pos_sfc0 = [0 0 0];
%! lim = 15;
%! m = 15;  n = 50;
%! %sat_elev = randint(0,90);  sat_azim = randint(0,360);
%! %sat_elev = 10,  sat_azim = 0
%! %sat_elev = 20,  sat_azim = 0
%! %sat_elev = 10,  sat_azim = 90
%! %sat_elev = 90,  sat_azim = 0
%! %sat_elev = 45,  sat_azim = 0
%! sat_elev = 10,  sat_azim = -90
%! sat_dir = sph2cart_local([sat_elev, sat_azim, 1]);
%! 
%! sfc_coeff = randint(-1,+1, [4,4]);
%! sfc_coeff = sfc_coeff .* [...  % smaller height range
%!     0        1./lim   1./lim^2 1./lim^3;
%!     1./lim   1./lim^2 1./lim^3 1./lim^4;
%!     1./lim^2 1./lim^3 1./lim^4 1./lim^5;
%!     1./lim^3 1./lim^4 1./lim^5 1./lim^6;
%! ];
%! sfc_coeff = sfc_coeff .* lim;  % increase range of sfc height.
%! %sfc_coeff(:,end) = 0;  sfc_coeff(end,:) = 0;
%! %sfc_coeff = [];
%! sfc_poly = snr_setup_sfc_geometry_dem (pos_ant, pos_sfc0, struct('type','poly', 'coeff',sfc_coeff));
%! 
%! mesh2list = @(input) reshape(input, [m*n,1]);
%! list2mesh = @(input) reshape(input, [m,n]);
%! x_lim = [-1,+1]*lim;
%! y_lim = [-1,+1]*lim;
%! x_domain = linspace(x_lim(1), x_lim(2), n);
%! y_domain = linspace(y_lim(1), y_lim(2), m);
%! [x_mesh, y_mesh] = meshgrid(x_domain, y_domain);
%! %pos_horiz = [mesh2list(x_mesh), mesh2list(y_mesh)];  % WRONG!
%! pos_horiz = xyz2neu(mesh2list(x_mesh), mesh2list(y_mesh));
%! 
%! function grid = doit (sfc, val_type)
%!     switch val_type
%!     case 'height'
%!         fnc_self = @snr_fwd_geometry_height_self;
%!         fnc_grad = @snr_fwd_geometry_height_grad;
%!         fnc_hess = @snr_fwd_geometry_height_hess;
%!         v = 'z';
%!     case 'delay'
%!         fnc_self = @(pos_horiz, sfc) snr_fwd_geometry_delay_self (pos_horiz, sat_dir, pos_ant, sfc);
%!         fnc_grad = @(pos_horiz, sfc) snr_fwd_geometry_delay_grad (pos_horiz, sat_dir, pos_ant, sfc);                       
%!         fnc_hess = @(pos_horiz, sfc) snr_fwd_geometry_delay_hess (pos_horiz, sat_dir, pos_ant, sfc);                       
%!         v = 'd';
%!     end
%!     grid.x = x_mesh;
%!     grid.y = y_mesh;
%!     grid.(v) = list2mesh(fnc_self(pos_horiz, sfc));
%!     temp = fnc_grad(pos_horiz, sfc);
%!     grid.(strrep('dz_dx',  'z',v)) = list2mesh(temp(:,2));
%!     grid.(strrep('dz_dy',  'z',v)) = list2mesh(temp(:,1));
%!     temp = fnc_hess(pos_horiz, sfc);
%!     grid.(strrep('dz2_dx2', 'z',v)) = list2mesh(temp(2,2,:));
%!     grid.(strrep('dz2_dy2', 'z',v)) = list2mesh(temp(1,1,:));
%!     grid.(strrep('dz2_dxy', 'z',v)) = list2mesh(temp(1,2,:));
%! end
%! function grid = doit2 (sfc, val_type)
%!     switch val_type
%!     case 'height'
%!         fnc_self = @snr_fwd_geometry_height_self;
%!         v = 'z';
%!     case 'delay'
%!         fnc_self = @(pos_horiz, sfc) snr_fwd_geometry_delay_self (pos_horiz, sat_dir, pos_ant, sfc);
%!         v = 'd';
%!     end
%!     grid.x = x_mesh;
%!     grid.y = y_mesh;
%!     grid.(v) = list2mesh(fnc_self(pos_horiz, sfc));
%!     % recall that pos_horiz = xyz2neu(x, y) = [y x].
%!     grid.(strrep('dz_dx','z',v)) = list2mesh(...
%!         diff_func(@(x_) fnc_self([pos_horiz(:,1), x_], sfc), pos_horiz(:,2)));
%!     grid.(strrep('dz_dy','z',v)) = list2mesh(...
%!         diff_func(@(y_) fnc_self([y_, pos_horiz(:,2)], sfc), pos_horiz(:,1)));
%!     grid.(strrep('dz2_dx2','z',v)) = list2mesh(...
%!         diff_func(@(x__) diff_func(@(x_) fnc_self([pos_horiz(:,1), x_], sfc), x__), pos_horiz(:,2)));
%!     grid.(strrep('dz2_dy2','z',v)) = list2mesh(...
%!         diff_func(@(y__) diff_func(@(y_) fnc_self([y_, pos_horiz(:,2)], sfc), y__), pos_horiz(:,1)));
%!     grid.(strrep('dz2_dxy','z',v)) = list2mesh(...
%!         diff_func(@(y_) diff_func(@(x_)  fnc_self([y_, x_], sfc), pos_horiz(:,2)), pos_horiz(:,1)));
%! end
%! 
%! height_grid_poly1 = doit (sfc_poly, 'height');
%!  delay_grid_poly1 = doit (sfc_poly, 'delay');
%! height_grid_poly2 = doit2(sfc_poly, 'height');
%!  delay_grid_poly2 = doit2(sfc_poly, 'delay');
%! 
%! sfc_interp = snr_setup_sfc_geometry_dem (pos_ant, pos_sfc0, struct('type','interp', ...
%!     'grid',struct('z',height_grid_poly1.z, ...
%!     'x',x_mesh, 'y',y_mesh), 'PO_not_GO',true, 'get_gradient',true, 'get_hessian',true));
%! %keyboard  % DEBUG 
%! height_grid_interp1 = doit (sfc_interp, 'height');
%!  delay_grid_interp1 = doit (sfc_interp, 'delay');
%! height_grid_interp2 = doit2(sfc_interp, 'height');
%!  delay_grid_interp2 = doit2(sfc_interp, 'delay');
%! height_grid_interp3 = sfc_interp.grid;
%! temp = snr_setup_sfc_geometry_dem (pos_ant, pos_sfc0, struct('type','interp', ...
%!     'grid',struct('z',delay_grid_poly1.d, ... % NOTICE z=d.
%!     'x',x_mesh, 'y',y_mesh), 'PO_not_GO',true, 'get_gradient',true, 'get_hessian',true));
%! delay_grid_interp3 = cell2struct(struct2cell(temp.grid), ...
%!     strrep(fieldnames(temp.grid), 'z', 'd'));
%! 
%! %for k=1:2
%! for k=2:-1:1
%!   switch k
%!   case 1
%!     data{1} = {delay_grid_poly1.d,       delay_grid_poly1.dd_dx,   delay_grid_poly1.dd_dy, ...
%!                delay_grid_poly1.dd2_dx2, delay_grid_poly1.dd2_dy2, delay_grid_poly1.dd2_dxy};
%!     temp    = {delay_grid_poly2.d,       delay_grid_poly2.dd_dx,   delay_grid_poly2.dd_dy, ...
%!                delay_grid_poly2.dd2_dx2, delay_grid_poly2.dd2_dy2, delay_grid_poly2.dd2_dxy};
%!     data{2} = cellfun(@minus, data{1}, temp, 'UniformOutput',false);
%!     data{3} = {delay_grid_interp1.d,       delay_grid_interp1.dd_dx,   delay_grid_interp1.dd_dy, ...
%!                delay_grid_interp1.dd2_dx2, delay_grid_interp1.dd2_dy2, delay_grid_interp1.dd2_dxy};
%!     temp    = {delay_grid_interp2.d,       delay_grid_interp2.dd_dx,   delay_grid_interp2.dd_dy, ...
%!                delay_grid_interp2.dd2_dx2, delay_grid_interp2.dd2_dy2, delay_grid_interp2.dd2_dxy};
%!     data{4} = cellfun(@minus, data{3}, temp, 'UniformOutput',false);
%!     data{5} = cellfun(@minus, data{3}, data{1}, 'UniformOutput',false);
%!     %data{5} = cellfun(@minus, data{3}, temp, 'UniformOutput',false);  % DEBUG
%!     %data{5} = cellfun(@minus, data{1}, temp, 'UniformOutput',false);  % DEBUG
%!     tit{1}  = {'d (poly1)' 'dd/dx (poly1)' 'dd/dy (poly1)' 'dd^2/dx^2 (poly1)' 'dd^2/dy^2 (poly1)' 'dd^2/dxdy (poly1)'};
%!     tit{2}  = {'d (poly1-2)' 'dd/dx (poly1-2)' 'dd/dy (poly1-2)' 'dd^2/dx^2 (poly1-2)' 'dd^2/dy^2 (poly1-2)' 'dd^2/dxdy (poly1-2)'};
%!     tit{3}  = {'d (interp1)' 'dd/dx (interp1)' 'dd/dy (interp1)' 'dd^2/dx^2 (interp1)' 'dd^2/dy^2 (interp1)' 'dd^2/dxdy (interp1)'};
%!     tit{4}  = {'d (interp1-2)' 'dd/dx (interp1-2)' 'dd/dy (interp1-2)' 'dd^2/dx^2 (interp1-2)' 'dd^2/dy^2 (interp1-2)' 'dd^2/dxdy (interp1-2)'};
%!     tit{5}  = {'d (interp1-poly1)' 'dd/dx (interp1-poly1)' 'dd/dy (interp1-poly1)' 'dd^2/dx^2 (interp1-poly1)' 'dd^2/dy^2 (interp1-poly1)' 'dd^2/dxdy (interp1-poly1)'};
%!   case 2
%!     data{1} = {height_grid_poly1.z,       height_grid_poly1.dz_dx,   height_grid_poly1.dz_dy, ...
%!                height_grid_poly1.dz2_dx2, height_grid_poly1.dz2_dy2, height_grid_poly1.dz2_dxy};
%!     temp    = {height_grid_poly2.z,       height_grid_poly2.dz_dx,   height_grid_poly2.dz_dy, ...
%!                height_grid_poly2.dz2_dx2, height_grid_poly2.dz2_dy2, height_grid_poly2.dz2_dxy};
%!     data{2} = cellfun(@minus, data{1}, temp, 'UniformOutput',false);
%!     data{3} = {height_grid_interp1.z,       height_grid_interp1.dz_dx,   height_grid_interp1.dz_dy, ...
%!                height_grid_interp1.dz2_dx2, height_grid_interp1.dz2_dy2, height_grid_interp1.dz2_dxy};
%!     temp    = {height_grid_interp2.z,       height_grid_interp2.dz_dx,   height_grid_interp2.dz_dy, ...
%!                height_grid_interp2.dz2_dx2, height_grid_interp2.dz2_dy2, height_grid_interp2.dz2_dxy};
%!     data{4} = cellfun(@minus, data{3}, temp, 'UniformOutput',false);
%!     data{5} = cellfun(@minus, data{3}, data{1}, 'UniformOutput',false);
%!     %data{5} = cellfun(@minus, data{3}, temp, 'UniformOutput',false);  % DEBUG
%!     %data{5} = cellfun(@minus, data{1}, temp, 'UniformOutput',false);  % DEBUG
%!     tit{1}  = {'z (poly1)' 'dz/dx (poly1)' 'dz/dy (poly1)' 'dz^2/dx^2 (poly1)' 'dz^2/dy^2 (poly1)' 'dz^2/dxdy (poly1)'};
%!     tit{2}  = {'z (poly1-2)' 'dz/dx (poly1-2)' 'dz/dy (poly1-2)' 'dz^2/dx^2 (poly1-2)' 'dz^2/dy^2 (poly1-2)' 'dz^2/dxdy (poly1-2)'};
%!     tit{3}  = {'z (interp1)' 'dz/dx (interp1)' 'dz/dy (interp1)' 'dz^2/dx^2 (interp1)' 'dz^2/dy^2 (interp1)' 'dz^2/dxdy (interp1)'};
%!     tit{4}  = {'z (interp1-2)' 'dz/dx (interp1-2)' 'dz/dy (interp1-2)' 'dz^2/dx^2 (interp1-2)' 'dz^2/dy^2 (interp1-2)' 'dz^2/dxdy (interp1-2)'};
%!     tit{5}  = {'z (interp1-poly1)' 'dz/dx (interp1-poly1)' 'dz/dy (interp1-poly1)' 'dz^2/dx^2 (interp1-poly1)' 'dz^2/dy^2 (interp1-poly1)' 'dz^2/dxdy (interp1-poly1)'};
%!   end
%!   %keyboard   % DEBUG
%!   for j=1:numel(data)
%!   %for j=numel(data):-1:1
%!     figure
%!     for i=1:numel(data{j})
%!       subplot(2,ceil(numel(data{j})/2),i)
%!       imagesc(x_domain, y_domain, data{j}{i}, 'AlphaData',~isnan(data{j}{i}))
%!       set(gca, 'YDir','normal')
%!       %set(gca, 'CLim',[min(mesh_grad(:)),max(mesh_grad(:))])
%!       title(tit{j}{i}, 'Interpreter','none')
%!       axis tight
%!       axis equal
%!       axis image
%!       grid on
%!       colorbar('EastOutside')
%!     end
%!     maximize(gcf)
%!   %subplot(2,3,2),  set(gca, 'CLim',[min(mesh_grad(:)),max(mesh_grad(:))])
%!   %subplot(2,3,3),  set(gca, 'CLim',[min(mesh_grad(:)),max(mesh_grad(:))])
%!   %keyboard  % DEBUG
%!     pause
%!   end
%! end
%! 
%! %myassert(mesh_grad3, mesh_grad, -nthroot(eps(),2));
%! %myassert(mesh_grad2, mesh_grad, -nthroot(eps(),2));  % not realiable because it depend on the sampling spacing.

