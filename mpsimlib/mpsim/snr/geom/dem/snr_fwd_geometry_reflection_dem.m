function [dir_refl_ant, pos_refl_ref, delay, doppler, extra] = snr_fwd_geometry_reflection_dem (...
dir_sat, order, setup)
    if isempty(order),  order = 1;  end
    n = length(dir_sat.elev);
    if isfieldempty(dir_sat, 'cart')
        if isfieldempty(dir_sat, 'sph')
            dir_sat.sph = [dir_sat.elev, dir_sat.azim, ones(n,1)];
        end
        dir_sat.cart = sph2cart_local (dir_sat.sph);
    end
    %setup.sfc.tol_delay = 0;  % DEBUG
        
    [pos_refl_horiz_approx, delay_approx] = snr_fwd_geometry_approx_eval (...
        dir_sat, order, setup);
    pos_refl_horiz_approx_cart = pos_refl_horiz_approx.cart;
    
    pos_refl_horiz_cart = snr_fwd_geometry_reflection_dem_aux (...
        dir_sat, pos_refl_horiz_approx_cart, delay_approx, setup);

    extra = fnc();
    delay = extra.delay_self;
    doppler = extra.doppler;
    height = extra.height_self;
    pos_refl_ref_cart = [pos_refl_horiz_cart, height];
    pos_refl_ref = struct('cart',pos_refl_ref_cart);
    
    dir_refl_ant = struct();
    %dir_refl_ant.cart = extra.dir_scatt;  % WRONG!
    dir_refl_ant.cart = -extra.dir_scatt;  % from receiver to surface.
    dir_refl_ant.sph = cart2sph_local (dir_refl_ant.cart);
    dir_refl_ant.elev = dir_refl_ant.sph(:,1);
    dir_refl_ant.azim = dir_refl_ant.sph(:,2);
end

function pos_refl_horiz = snr_fwd_geometry_reflection_dem_aux (...
dir_sat, pos_refl_horiz_approx, delay_approx, setup)
    sfc = setup.sfc;
    ref = setup.ref;
    n = length(dir_sat.elev);
    if isfieldempty(sfc, 'algorithm'),  sfc.algorithm = 'specialized';  end
    if isfieldempty(sfc, 'individually'),  sfc.individually = false;  end
    if isfieldempty(sfc, 'objonly'),  sfc.objonly = false;  end
    if isfieldempty(sfc, 'reuse_previous'),  sfc.reuse_previous = false;  end
    if isfieldempty(sfc, 'tol_pos'),  sfc.tol_pos = 1e-3;  end
    if isfieldempty(sfc, 'tol_delay'),  sfc.tol_delay = 1e-3;  end
    if ~any(strcmp(sfc.algorithm, {'generic','specialized'}))
        error('snr:snr_fwd_geometry_reflection_dem:badMethod', ...
            'Invalid method "%s"; try "specialized" or "generic".', ...
            sfc.algorithm)
    end
    opt2 = optimset(...
        'Display','off' ...
        ...%'Display','iter' ...  % DEBUG
    );

    switch sfc.algorithm
    case 'specialized'
        unpack = @(x) x;
        pack0  = @(x) x;
        pack1  = @(x) x;
        pack2  = @(x) x;
        opt2.tol_pos = sfc.tol_pos;
        opt2.tol_delay = sfc.tol_delay;
        fnc2 = @(sfc_pos_horiz, idx) fnc (...
            sfc_pos_horiz(idx,:), dir_sat.cart(idx,:), ...
            sfc, ref, unpack, pack0, pack1, pack2);
        pos_refl_horiz = myfminunc(fnc2, pos_refl_horiz_approx, opt2);
        % later we'll need a complete "extra" (persistent):
        fnc(pos_refl_horiz, dir_sat.cart, sfc, ref, unpack, pack0, pack1, pack2);
    case 'generic'
        %opt2 = optimset(opt2, 'DerivativeCheck','on', 'FinDiffType','central');  % DEBUG
        %opt2 = optimset(opt2, 'LargeScale','off');  % DEBUG
        if sfc.objonly
            opt2 = optimset(opt2, 'LargeScale','off');
        else
            %disp('hw!')  % DEBUG
            opt2 = optimset(opt2, ...
                'GradObj','on', ...
                'Hessian','on'  ...
            );
        end
        %keyboard  % DEBUG
        if sfc.individually
            %unpack = @(x) x;
            %pack1  = @(x) x;
            %unpack = @(x) reshape(x, [1,2]);  % WRONG!
            %pack1  = @(x) reshape(x, [2,1]);  % WRONG!
            unpack = @(x) reshape(x, [],2);
            pack1  = @(x) x(:);
            pack2  = @(x) x;
            pack0  = @(x) x;
            pos_refl_horiz = NaN(n,2);
            for i=1:n
                % Matlab's TolX, TolFun are relative, not absolute;
                opt2.TolX = sfc.tol_pos / max(1, max(abs(pos_refl_horiz_approx(i,:))));
                opt2.TolFun = sfc.tol_delay / max(1, delay_approx(i));
                opt2.TolFun = opt2.TolFun / 100;  % otherwise TolX is not honored.
                fnc2 = @(sfc_pos_horiz_) fnc (...
                    sfc_pos_horiz_, dir_sat.cart(i,:), ...
                    sfc, ref, unpack, pack0, pack1, pack2);
                tempin = pack1(pos_refl_horiz_approx(i,:));
                tempout = fminunc(fnc2, tempin, opt2);
                pos_refl_horiz(i,:) = unpack(tempout);
                if sfc.reuse_previous
                    pos_refl_horiz_approx(i+1,:) = pos_refl_horiz(i,:);
                    delay_approx(i+1,:) = getfield(fnc(), 'delay_self'); %#ok<GFLD>
                end
                %pause  % DEBUG
            end
            % later we'll need a complete "extra" (persistent):
            fnc(pos_refl_horiz, dir_sat.cart, sfc, ref, unpack, pack0, pack1, pack2);
        else
            % sort observations by point first and coordinate type second, so that 
            % the Hessian matrix is block diagonal:
            unpack = @(in) reshape(in, [2,n]).';
            pack0  = @(in) sum(in);
            pack1  = @(in) reshape(in.', [2*n,1]);
            %pack2  = @(in) feval(deal_vec2arg(@blkdiag, mat2cell(in, 2,2,ones(n,1))));  % WRONG!
            pack2  = @(in) feval(deal_vec2arg(@blkdiag, arrayfun(@(i) in(:,:,i), 1:n, 'UniformOutput',false)));
            s = warning('off', 'MATLAB:mat2cell:TrailingUnityVectorArgRemoved');
            %opt2 = optimset(opt2, 'HessPattern',pack2(repmat(eye(2),[1,1,n])));  % WRONG!
            opt2 = optimset(opt2, 'HessPattern',pack2(repmat(ones(2,2),[1,1,n])));
            % Matlab's TolX, TolFun are relative, not absolute;
            % furthermore, now these values refer to the norm or sum of all points:
            opt2.TolX = sfc.tol_pos / n / max(1, max(max(abs(pos_refl_horiz_approx))));
            opt2.TolFun = sfc.tol_delay / n / max(1, max(delay_approx));
            opt2.TolFun = opt2.TolFun / 100;  % otherwise TolX is not honored.
            fnc2 = @(sfc_pos_horiz_) fnc (...
                sfc_pos_horiz_, dir_sat.cart, ...
                sfc, ref, unpack, pack0, pack1, pack2);
            pos_refl_horiz_approx = pack1(pos_refl_horiz_approx);
            pos_refl_horiz = fminunc(fnc2, pos_refl_horiz_approx, opt2);
            pos_refl_horiz = unpack(pos_refl_horiz);
            warning(s)
        end
    end
      %figure, spy(hessian)
      %figure, spy(abs(hessian) >nthroot(eps(),3))
end

function varargout = fnc (sfc_pos_horiz, dir_sat_cart, sfc, ref, unpack, pack0, pack1, pack2)
    persistent extra
    if (nargin == 0),  varargout = {extra};  return;  end
    sfc_pos_horiz = unpack(sfc_pos_horiz);
      myassert(size(sfc_pos_horiz,1), size(dir_sat_cart,1));

    height_self = snr_fwd_geometry_height_self (sfc_pos_horiz, sfc);
    height_grad = snr_fwd_geometry_height_grad (sfc_pos_horiz, sfc);
    height_hess = snr_fwd_geometry_height_hess (sfc_pos_horiz, sfc);

    [delay_self, dir_split, dist_scatt, dir_scatt] = ...
        snr_fwd_geometry_delay_self (...
        sfc_pos_horiz, dir_sat_cart, ref.pos_ant, sfc, height_self);        
    delay_grad = snr_fwd_geometry_delay_grad (sfc_pos_horiz, ...
        dir_sat_cart, ref.pos_ant, sfc, dir_split);
    delay_hess = snr_fwd_geometry_delay_hess (sfc_pos_horiz, ...
        dir_sat_cart, ref.pos_ant, sfc, ...
        height_self, height_grad, height_hess, dir_split);
    %delay_hess = repmat(eye(2),[1,1,size(sfc_pos_horiz,1)]);  % DEBUG

    obj  = pack0(delay_self);
    grad = pack1(delay_grad);
    hess = pack2(delay_hess);
    varargout = {obj, grad, hess};

    extra = struct();
    extra.height_self = height_self;
    extra.height_grad = height_grad;
    extra.height_hess = height_hess;
    extra.delay_self  = delay_self;
    extra.delay_grad  = delay_grad;
    extra.delay_hess  = delay_hess;
    extra.dir_split   = dir_split;
    extra.dist_scatt  = dist_scatt;
    extra.dir_scatt   = dir_scatt;
    extra.doppler     = NaN(size(delay_self));
end

function [x, obj, exitflag] = myfminunc (fun, x0, opt)
    obj = [];
    exitflag = [];
    [n, n2] = size(x0);
    i_max = 15;
    force_vectorial = false;
    %force_vectorial = true;  % DEBUG
    if (n > 1) || force_vectorial
        delay0   = NaN(n,1);
        delay    = NaN(n,1);
        x        = NaN(n,n2);
        xd       = NaN(n,n2);
        grad     = NaN(n,n2);
        hess     = NaN(n2,n2,n);
        hess_inv = NaN(n2,n2,n);
        idx       = false(n,1);  % keeps track of points that converged.
        for i=1:i_max
            [delay(~idx,1), grad(~idx,:), hess(:,:,~idx)] = fun(x0, ~idx);
            hess_inv(:,:,~idx) = inv_2by2_symm(hess(:,:,~idx));
            xd(~idx,:) = frontal_mtimes_pt(hess_inv(:,:,~idx), grad(~idx,:));
            x(~idx,:) = x0(~idx,:) - xd(~idx,:);
            xe = norm_all(xd);
            de = abs(delay0 - delay);
            if strcmp(opt.Display, 'iter'),  fprintf('i=%d\txe=%g\tde=%g\n', i, max(xe), max(de));  end
            idx = (xe < opt.tol_pos) | (de < opt.tol_delay);
            idx(any(isnan(x),2)) = true;  % interp2 had to extrapolate.
            if all(idx),  break;  end
            x0 = x;  delay0 = delay;
                %[i, sum(idx2), max(de(idx2)), max(xe(idx2)), max(de), max(xe)]  % DEBUG
            %xd, pause  % DEBUG
        end
    else
        % (simplified version for scalars.)
        delay0 = NaN;
        for i=1:i_max
            [delay, grad, hess] = fun(x0, 1);
            xd = (hess \ grad.').';
            xe = norm(xd);
            de = abs(delay0 - delay);
            x = x0 - xd;
            if strcmp(opt.Display, 'iter'),  fprintf('i=%d\txe=%g\tde=%g\n', i, xe, de);  end
            %if (xe <= opt.tol_pos) && (de < opt.tol_delay),  break;  end  % WRONG!
            if (xe <= opt.tol_pos) || (de < opt.tol_delay),  break;  end  % consistent with fminunc.
            if isnan(xe),  break;  end
            x0 = x;  delay0 = delay;
        end
    end
    if any(isnan(xe)) || (i == i_max)
        warning('snr:snr_fwd_geometry_reflection_dem:didNotConverge', ...
            'Failed to converge.');
    end
end

%TODO: restore generic solvers.
%TODO: test against cylindrical surface, for which analytical closed-form solutions exist for a low-order polynomial surface.
%TODO: test at normal incidence.

%%
%!test
%! % tilted surface, random surface aspect and slope, random incident direction; vs. simpler implementation.
%! rand('seed',0)  % DEBUG
%! n = ceil(100*rand);
%! n = 2;  elev_lim = [20, 20];  azim_lim = [0, 0];
%! n = 3;  elev_lim = [20, 20];  azim_lim = [0, 0];
%! n = 2;  elev_lim = [20, 30];  azim_lim = [0, 360];
%! %n = 1;  elev_lim = [10, 10];  azim_lim = [0, 0];  % DEBUG
%! %n = 1;  elev_lim = [30, 30];  azim_lim = [0, 0];  % DEBUG
%! height_ant = 3;
%! sett = snr_settings();
%! sett.sat.num_obs = n;
%! sett.ref.height_ant = height_ant;
%! sett.ref.ignore_vec_apc_arp = true;
%! setup = snr_setup(sett);
%! ref = setup.ref;
%! sfc_slope = randint(0,90);  sfc_aspect = randint(0,360);
%! sfc_slope = 15;
%! %sfc_slope = 0;  sfc_aspect = 0;  % DEBUG
%! [sfc_dz_dx, sfc_dz_dy] = slopeaspect2horizgrad(sfc_slope, sfc_aspect);
%! %sfc_coeff = [0, sfc_dz_dx; sfc_dz_dy, 0];  % WRONG!
%! sfc_coeff = [0, sfc_dz_dy; sfc_dz_dx, 0];
%! %sfc_coeff = [0 0; 0 0];  % DEBUG
%! pos_sfc0 = [0 0 0];
%! 
%! sfc_sett0 = struct('coeff',sfc_coeff, 'type','poly');
%! sfc_sett1 = struct('slope',sfc_slope, 'aspect',sfc_aspect);
%! sfc0 = snr_setup_sfc_geometry_dem    (ref.pos_ant, pos_sfc0, sfc_sett0);
%! sfc1 = snr_setup_sfc_geometry_tilted (ref.pos_ant, pos_sfc0, sfc_sett1);
%! sfc2 = snr_setup_sfc_geometry_horiz  (ref.pos_ant, pos_sfc0);
%! 
%! dir_incident.elev = randint(elev_lim(1), elev_lim(2), n,1);
%! dir_incident.azim = randint(azim_lim(1), azim_lim(2), n,1);
%! 
%! sfc0a = setfields(sfc0, 'approximateit',false, 'algorithm','specialized');
%! sfc0b = setfields(sfc0, 'approximateit',true,  'algorithm','specialized');
%! sfc0c = setfields(sfc0, 'approximateit',true,  'algorithm','generic', 'individually',true);
%! sfc0d = setfields(sfc0, 'approximateit',true,  'algorithm','generic', 'individually',false);
%! sfc0e = setfields(sfc0, 'approximateit',true,  'algorithm','generic', 'individually',true,  'objonly',true);
%! sfc0f = setfields(sfc0, 'approximateit',true,  'algorithm','generic', 'individually',false, 'objonly',true);
%! res0a = runit('0a');
%! res0b = runit('0b');
%! res0c = runit('0c');
%! res0d = runit('0d');
%! res0e = runit('0e');
%! res0f = runit('0f');
%! 
%! [res1.dir_reflected, res1.pos_reflected, res1.delay] = ...
%!     snr_fwd_geometry_reflection_tilted (dir_incident, [], setfield(setup, 'sfc',sfc1));
%! [res2.dir_reflected, res2.pos_reflected, res2.delay] = ...
%!     snr_fwd_geometry_reflection_horiz (dir_incident, [], setfield(setup, 'sfc',sfc2));
%! 
%! % directional and positional tolerance must be greater than ranging tolerance:
%! tol_dir = 1;  
%! tol_pos = 1e-3;  
%! tol_delay = 1e-3;
%! 
%! %n  % DEBUG
%! %sfc_slope, sfc_aspect  % DEBUG
%! %sfc_dz_dx, sfc_dz_dy, sfc_coeff  % DEBUG
%! %dir_incident  % DEBUG
%! 
%! %res0e.pos_reflected.cart, res1.pos_reflected.cart, res0e.pos_reflected.cart - res1.pos_reflected.cart, keyboard  % DEBUG
%! checkit(res0a, res1, '0a-1')
%! checkit(res0b, res1, '0b-1')
%! %checkit(res0c, res1, '0c-1')
%! %checkit(res0d, res1, '0d-1')
%! %checkit(res0e, res1, '0e-1')
%! %checkit(res0f, res1, '0f-1')
%! printit(res0c, res1, '0c-1')
%! printit(res0d, res1, '0d-1')
%! printit(res0e, res1, '0e-1')
%! printit(res0f, res1, '0f-1')
%! printit(res2,  res1,  '2-1')  % not supposed to agree -- just to give a sense of deviation from horiz sfc.
%! 
%! function res = runit (tit)
%!   %disp(tit)  % DEBUG
%!   sfc = eval(['sfc' tit]);
%!   res = struct();
%!   [res.dir_reflected, res.pos_reflected, res.delay] = snr_fwd_geometry_reflection_dem (...
%!     dir_incident, [], setfield(setup, 'sfc',sfc));
%!   %eval(sprintf('res%s = res;', tit));
%!   %assignin('caller', ['res' tit], res);
%! end
%! function checkit (resa, resb, tit)
%!   printit(resa, resb, tit)  % DEBUG
%!   assertit(resa, resb, tit)
%! end
%! function printit (resa, resb, tit)
%!   fprintf('\n');
%!   fprintf('%s::\n', tit);
%!   fprintf('elev: %g\n',  max(abs(resa.dir_reflected.elev - resb.dir_reflected.elev)))
%!   fprintf('azim: %g\n',  max(abs(azimuth_diff(resa.dir_reflected.azim, resb.dir_reflected.azim))))
%!   fprintf('pos: %g\n',   max(norm_all(resa.pos_reflected.cart - resb.pos_reflected.cart)))
%!   fprintf('delay: %g\n', max(abs(resa.delay - resb.delay)))
%! end
%! function assertit (resa, resb, tit)
%!   myassert(resa.dir_reflected.elev, resb.dir_reflected.elev, -tol_dir)
%!   myassert(abs(azimuth_diff(resa.dir_reflected.azim, resb.dir_reflected.azim)) < tol_dir)
%!   myassert(resa.pos_reflected.cart, resb.pos_reflected.cart, -tol_pos)
%!   myassert(resa.delay, resb.delay, -tol_delay)
%! end

