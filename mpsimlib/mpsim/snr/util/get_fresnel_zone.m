% Input:
%   receive antenna height, in meters
%   satellite elevation angle, in degrees
%   satellite azimuth, in degrees (positive clockwise from north)
%   wavelength, either a scalar (in meters) or a string ('L1','L2').
%   zone index (optional); 1 means first Fresnel zone, 0.5 first Fresnel subzone
%   surface slope (optional), in degrees
%   surface aspect angle (optional), in degrees
% Output: a structure with the following fields:
%   a: ellipse semi-major axis (or semi-major diameter), in meters
%   b: ellipse semi-minor axis (or semi-minor diameter), in meters
%   R: distance between center of ellipse and receive antenna, in meters
%   x: ellipse east coordinates, in meters
%   y: ellipse north coordinates, in meters
% For scalar input, x and y are vectors; for vector input, x and y are cell 
% arrays, whose elements x{i},y{i} are vectors.
function answer = get_fresnel_zone (height, elev, azim, wavelength, zone, ...
slope, aspect, dang, step, form)
    if (nargin < 1),  height = [];  end
    if (nargin < 2),  elev = [];  end
    if (nargin < 3),  azim = [];  end
    if (nargin < 4),  wavelength = [];  end
    if (nargin < 5),  zone = [];  end
    if (nargin < 6),  slope = [];  end
    if (nargin < 7),  aspect = [];  end
    if (nargin < 8),  dang = [];  end
    if (nargin < 9),  step = [];  end
    if (nargin <10),  form = [];  end
    
    if ischar(dang) &&  (nargin <= 8)
        warning('snr:get_fresnel_zone:oldSyntax', 'Syntax deprecated.')
        [dang, step, form] = deal(slope, aspect, dang);  slope = [];  aspect = [];
    end

    if isempty(slope) && isempty(aspect)
    %if isempty(slope) || isempty(aspect)  % WRONG!
        answer = get_fresnel_zone_horiz (height, elev, azim, wavelength, zone, ...
            dang, step, form);
    else
        answer = get_fresnel_zone_tilted (height, elev, azim, wavelength, zone, ...
            slope, aspect, dang, step, form);
    end
end

%!test
%! % zero elev ang
%! wavelength = get_gps_wavelengths ('L2');
%! h = 1;
%! e = 0;
%! a = 0;
%! ffz = get_fresnel_zone (h, e, a, wavelength);

%!test
%! % single direction
%! wavelength = get_gps_wavelengths ('L2');
%! h = 1;
%! e = 5;
%! a = 0;
%! ffz = get_fresnel_zone (h, e, a, wavelength);
%! % (not testing for correctness, just testing if it runs.)

%!test
%! % non-empty zero slope as well as negligible slope:
%! h = 1;
%! e = 5;
%! a = 0;
%! ffz1 = get_fresnel_zone (h, e, a, [], []);
%! ffz2 = get_fresnel_zone (h, e, a, [], [], 0, 0);
%! ffz3 = get_fresnel_zone (h, e, a, [], [], eps(), eps());
%! 
%! %max(abs(ffz2.x-ffz1.x))
%! %max(abs(ffz3.x-ffz1.x))
%! %max(abs(ffz2.y-ffz1.y))
%! %max(abs(ffz3.y-ffz1.y))
%! 
%! myassert(ffz2.pos(:,1:2), ffz1.pos, -sqrt(eps()))
%! myassert(ffz3.pos(:,1:2), ffz1.pos, -sqrt(eps()))

%!test
%! % infinitesimal Fresnel zone (perimeter, not only focus) coincides with specular point:
%! wavelength = get_gps_wavelengths ('L2');
%! h = 1;
%! e = 5;
%! a = 0;
%! %n = sqrt(eps());
%! n = eps();
%! 
%! slope = [];  aspect = [];
%! for i=1:2 
%!   if (i == 2),  slope = 2;  aspect = 0;  end
%!   
%!   [sp.pos, sp.dir, sp.dist] = get_specular_point (h, e, a, slope, aspect);
%!   ffz = get_fresnel_zone (h, e, a, [], n, slope, aspect, 360);
%!   if (i == 1),  ffz.pos(:,3) = 0;  end
%! 
%!   %[norm(sp.pos), norm(ffz.pos), norm(ffz.pos)-norm(sp.pos)]  % DEBUG
%!   %[sp.pos; ffz.pos; ffz.pos-sp.pos]  % DEBUG
%!   myassert(norm_all(ffz.pos), norm(sp.pos), -nthroot(eps(),3))
%!   myassert(ffz.pos, sp.pos, -nthroot(eps(),3))
%! end
%! %error('stop!')  % DEBUG

%!test
%! wavelength = get_gps_wavelengths ('L2');
%! e = (5:5:25);
%! h = [1, 2, 3];
%! n = [0.5, 1, 2, 3, 4, 5];
%! E = repmat(reshape(e, [],1,1), [1,length(h),length(n)]);
%! H = repmat(reshape(h, 1,[],1), [length(e),1,length(n)]);
%! N = repmat(reshape(n, 1,1,[]), [length(e),length(h),1]);
%! siz = [length(e),length(h),length(n)];
%! a = 0;  A = repmat(a, siz);
%! doreshape = @(ffz) structfun(@(f) reshape(f, siz), ffz, 'UniformOutput',false);
%! 
%! ffz = get_fresnel_zone (H(:), E(:), A(:), wavelength, N(:));
%! ffz = rmfieldifexist(ffz, {'pos','pos0'});
%! ffz = doreshape(ffz);
%! b = ffz.b;
%! a = ffz.a;
%! R = ffz.R;
%! 
%! ffz2 = get_fresnel_zone (H(:), E(:), A(:), wavelength, N(:), [], [], 'incorrect');
%! ffz2 = rmfieldifexist(ffz2, {'pos','pos0'});
%! ffz2 = doreshape(ffz2);
%! b2 = ffz2.b;
%! a2 = ffz2.a;
%! R2 = ffz2.R;
%! 
%! y_offset = 0;
%! x_offset = -5;
%! x_offset2 = +30;
%! figure
%! hold on
%! axis equal
%! %for k=1:length(n)
%! %for k=find(ismember(n, [0.5,1]))
%! for k=find(n==1)
%! for j=1:length(h)
%! for i=1:length(e)
%!   plot(x_offset*(i-1)+x_offset2*(j-1), 0, 'ok', 'LineWidth',1, 'MarkerSize',10);
%!   plot(x_offset*(i-1)+x_offset2*(j-1), 0, '+k', 'LineWidth',1, 'MarkerSize',12.5);
%!   hnd(2)=rectangle(...
%!     'Position',[0-b2(i,j,k)+x_offset*(i-1)+x_offset2*(j-1), R2(i,j,k)-a2(i,j,k)+y_offset, ...
%!                 2*b2(i,j,k),2*a2(i,j,k)],...
%!     'Curvature',[1,1], ...
%!     'EdgeColor',[1 1 1]*0.5, 'LineWidth',2);
%!   hnd(1)=rectangle(...
%!     'Position',[0-b(i,j,k)+x_offset*(i-1)+x_offset2*(j-1), R(i,j,k)-a(i,j,k), ...
%!                 2*b(i,j,k),2*a(i,j,k)],...
%!     'Curvature',[1,1], ...
%!      'EdgeColor',[1 1 1]*0, 'LineWidth',2);
%!   text(0+x_offset*(i-1)+x_offset2*(j-1), R(i,j,k)+a(i,j,k)+1.5, [num2str(e(i)) 'º'], ...
%!     'HorizontalAlignment','center')
%!   text(x_offset2*(j-1)-x_offset2/2+2.5, 40, [' ' num2str(h(j)) ' m '], ...
%!     'HorizontalAlignment','center', 'FontWeight','bold', 'EdgeColor','k')
%!   title(sprintf('e=%g, h=%g, n=%g', e(i), h(j), n(k)))
%!   %pause
%! end
%! %pause
%! end
%! %pause
%! end
%! %legend(hnd, {'Right','Wrong'})
%! set(gca, 'XTick',[])
%! title('')
%! ylabel('(m)')

%!test
%! height = 2;
%! elev = 20;
%! azim = 45;
%! %azim = 0;  % DEBUG
%! material_top = 'air';
%! material_bottom = 'wet ground';
%! freq_name = 'L2';
%! lim = 10;  step_in_wavelengths = 0.5;
%! s = warning('off', 'matlab:get_permittivity:badFreq');
%! 
%! sett = snr_fwd_settings ();
%! sett.ref.height_ant = height;
%! sett.opt.freq_name = 'L2';
%! sett.opt.code_name = 'L2C';
%! sett.opt.block_name = 'IIR-M';
%! sett.ant.slope = 0;
%! sett.ant.aspect = 0;
%! sett.ant.axial = 0;
%! sett.ant.model = 'isotropic';  sett.ant.radome = 'none';
%! sett.sat.elev = elev;
%! sett.sat.azim = azim;
%! sett.sfc.material_top = material_top;
%! sett.sfc.material_bottom = material_bottom;
%! sett.opt.po.lim = lim;
%! sett.opt.po.step_in_wavelengths = step_in_wavelengths;
%! sett.opt.occlusion.disabled = true;
%! sett.opt.num_specular_max = Inf;
%! sett.sfc.slope = 0;  sett.sfc.aspect = 0;  % WRONG! won't do horiz.
%! sett.sfc.slope = [];  sett.sfc.aspect = [];
%! 
%! slope = [];  aspect = [];
%! for i=1:2 
%!   if (i == 2),  sett.sfc.slope = 2;  sett.sfc.aspect = 0;  end
%!   setup = snr_setup (sett);
%!   setup.field = {'*'};
%!   answer = snr_po (setup);
%!   warning(s);
%!   
%!   e = elev;
%!   h = height;
%!   n = [0.5, 1, 2, 3, 4, 5];
%!   E = repmat(reshape(e, [],1,1), [1,length(h),length(n)]);
%!   H = repmat(reshape(h, 1,[],1), [length(e),1,length(n)]);
%!   N = repmat(reshape(n, 1,1,[]), [length(e),length(h),1]);
%!   siz = [length(e),length(h),length(n)];
%!   a = azim;  A = repmat(a, siz);
%!   doreshape = @(ffz) structfun(@(f) reshape(f, siz), ffz, 'UniformOutput',false);
%!   
%!   ffz = get_fresnel_zone (H(:), E(:), A(:), freq_name, N(:), sett.sfc.slope, sett.sfc.aspect);
%!   ffz = rmfieldifexist(ffz, {'pos','pos0'});
%!   ffz = doreshape(ffz);
%!   x = ffz.x;
%!   y = ffz.y;
%!   
%!   c = {'w','k'};
%!   c = {'k','w'};
%!   w = [3,2];
%!   %w = [5,2];
%!   %a = a3;  b = b3;  R = R3;
%!   %a = a2;  b = b2;  R = R2;
%!   
%!   %plotit(answer, @(map) abs(100*get_power(answer.phasor_reflected - map.mphasor)./get_power(answer.phasor_reflected)-100), 'jet')  % if I were to NOT image only one 1-m^2 portion
%!   %plotit(answer, @(map) 100*get_power(map.cphasor - answer.phasor_reflected)./get_power(answer.phasor_reflected), 'jet')  % how cum phasor converges to net phasor, in terms of power
%!   plotit(answer, @(map) 100*(abs(map.cphasor) - abs(answer.phasor_reflected))./abs(answer.phasor_reflected), 'bwr')  % how cum phasor changes in ampl
%!   %plotit(answer, @(map) 100*(get_power(map.cphasor) - get_power(answer.phasor_reflected))./get_power(answer.phasor_reflected), 'bwr')  % how cum phasor changes in power
%!   %temp = (answer.map.phase_unwrapped - min(answer.map.phase_unwrapped(:)));
%!   %img = 0*ones(size(temp));
%!   %for i=1:length(n),  img = img + (temp <= n(i)/2);  end
%!   %plotit(answer, @(map) img, 'flipud(gray)');  delete(colorbar);
%!     hold on
%!     %plot(pos_reflection(2), pos_reflection(1), ...
%!     %  'Marker','+', 'MarkerSize',20, 'Color','w', 'LineWidth',2);
%!     for k=1:length(n)
%!     for j=find(h==height)  %j=1:length(h)
%!     for i=find(e==elev)  %i=1:length(e)
%!     for I=1:2
%!       plot(x{i,j,k}, y{i,j,k}, 'Color',c{I}, 'LineWidth',w(I))
%!       %rectangle(...
%!       %  'Position',[0-b(i,j,k), ...
%!       %              R(i,j,k)-a(i,j,k), 2*b(i,j,k),2*a(i,j,k)],...
%!       %  'Curvature',[1,1], ...
%!       %   'EdgeColor',c{I}, 'LineWidth',w(I))
%!     end
%!     end
%!     end
%!     end
%! end
%! %keyboard  % DEBUG
%!   
%! function plotit (answer, f, cmap, prc)
%!   if (nargin < 3) || isempty(cmap),  cmap = 'hsv';  end
%!   if (nargin < 4) || isempty(prc),  prc = 100;  end
%!   img = f(answer.map);
%!   figure
%!   imagesc(answer.info.x_domain, answer.info.y_domain, img)
%!   set(gca, 'YDir','normal')
%!   colorbar
%!   axis image
%!   title(func2str(f), 'Interpreter','none')
%!   grid on
%!   xlabel('East (m)')
%!   ylabel('North (m)')
%!   set(gca, 'XTick',linspace(answer.info.x_domain(1),answer.info.x_domain(end),10+1))
%!   set(gca, 'YTick',linspace(answer.info.y_domain(1),answer.info.y_domain(end),10+1))
%!   switch cmap
%!   case 'bwr'
%!       colormap_bwr_it(img)
%!       if (prc ~= 100),  set(gca, 'CLim',[-1,+1]*prctile(abs(img(:)),prc));  end
%!   otherwise
%!       eval(sprintf('colormap(%s)', cmap));
%!       if (prc ~= 100),  set(gca, 'CLim',prctile(abs(img(:)),[0,prc]));  end
%!       %prc2 = (100-prc)/2;
%!       %set(gca, 'CLim',prctile(abs(img(:)),[prc2,100-prc2]))
%!   end
%! end
