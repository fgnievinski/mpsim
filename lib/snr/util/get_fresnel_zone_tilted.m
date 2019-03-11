function answer = get_fresnel_zone_tilted (height, elev, azim, wavelength, zone, ...
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
    [~, ~, height, elev, azim, wavelength, zone] = get_fresnel_zone_input (...
        height, elev, azim, wavelength, zone);

    setup = struct();
    setup.ref = snr_setup_origin (height);
    setup.sfc = snr_setup_sfc_geometry_tilted (...
        setup.ref.pos_ant, [], struct('slope',slope, 'aspect',aspect));

    dir_incid = struct('elev',elev, 'azim',azim);
    dir_sfc = setup.sfc.snr_fwd_direction_local2sfc (dir_incid, setup);
    
    %height_perp = setup.sfc.height_ant_sfc;  % WRONG!
    height_perp = setup.sfc.dist_ant_sfc_perp;    
    graz = dir_sfc.elev;
    azim2 = dir_sfc.azim;
    
    answer0 = get_fresnel_zone_horiz (height_perp, graz, azim2, wavelength, zone, ...
       dang, step, form);
    
    % transform from tilted plane back to horizontal plane:
    %rotate = @(pos) (setup.sfc.rot * pos')';  % WRONG!
    rotate = @(pos) (setup.sfc.rot' * pos')';
    shift = @(pos, pos_ant_sfc) plus_all(pos, pos_ant_sfc);
    cat3 = @(pos) iif(size(pos,2)<3, @() cat(2, pos, zeros(size(pos,1),1)), @() pos);
    transform = @(pos, pos_ant_sfc) shift(rotate(cat3(pos)), pos_ant_sfc);
    transform = @(pos, pos_ant_sfc) iif(iscell(pos), ...
        @() cellfun2(transform, pos, mat2cellrow(setup.sfc.pos_ant_sfc)), ...
        @() transform(pos, setup.sfc.pos_ant_sfc));

    answer = struct();
    answer.pos = transform(answer0.pos);
    pos2coord = @(pos) dealc(neu2xyz(mat2cellcol(pos)));
    pos2coord = @(pos) iif (~iscell(pos), @() pos2coord(pos), @() cellfun2(pos2coord, pos));
    [answer.x, answer.y, answer.z] = pos2coord(answer.pos);
    answer.a2 = answer0.a;
    answer.b2 = answer0.b;
    answer.R2 = answer0.R;
    answer.a = NaN(size(answer0.a));
    answer.b = NaN(size(answer0.b));
    
    cat3R = @(R) cat(2, R, zeros(numel(R),2));
    transformR = @(R) norm_all(getel(transform(cat3R(R)), ':,1:2'));
    answer.R = transformR(answer0.R);
    answer.R_max = transformR(answer0.R_max);
    answer.R_min = transformR(answer0.R_min);
    
    if isfield(answer0, 'pos0')
        answer.pos0 = transform(answer0.pos0);
        [answer.x0, answer.y0, answer.z0] = pos2coord(answer.pos0);
    end
end
