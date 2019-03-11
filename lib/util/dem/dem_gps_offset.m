function out = dem_gps_offset (dem_x, dem_y, dem_z, gps_x, gps_y, gps_z, robustify)
  if (nargin < 7) || isempty(robustify),  robustify = false;  end
  if robustify
    out = dem_gps_offset_robust (dem_x, dem_y, dem_z, gps_x, gps_y, gps_z);
    return
  end
  idx = isnan(gps_z);
  if any(idx)
    siz = size(gps_z);
    gps_z(idx) = [];
    gps_y(idx) = [];
    gps_x(idx) = [];
  end
  
  get_zi = @(offset) interp2(dem_x + offset(1), dem_y + offset(2), ...
    dem_z, gps_x, gps_y) + offset(3);
  get_ze = @(offset) get_zi(offset) - gps_z;
  [offset,sigma0,resid,~,~,~,J] = lsqnonlin(get_ze, zeros(3,1));
  
  out = struct();
  out.offset = offset;
  out.sigma0 = sigma0;
  
  N = J'*J;  if issparse(N),  N = full(N);  end
  out.cov = inv(N) * out.sigma0^2; %#ok<MINV>
  out.std = sqrt(diag(out.cov));
  
  if ~any(idx)
    out.resid = resid;
    out.jacob = J;
  else
    out.resid = NaN(siz);
    out.resid(~idx) = resid;
    out.jacob = NaN(siz(1), 3);
    out.jacob(~idx,:) = J;
  end
  
  out.dof = get_dof (out);
  out.conf = get_conf (out);
end

%%
function out = dem_gps_offset_robust (dem_x, dem_y, dem_z, gps_x, gps_y, gps_z)
  ze = interp2(dem_x, dem_y, dem_z, gps_x, gps_y) - gps_z;
  idx = is_outlier (ze, nanmedian(ze), nanstdr(ze)^2);
  gps_zr = setel(gps_z, idx, NaN);
  outnr = dem_gps_offset (dem_x, dem_y, dem_z, gps_x, gps_y, gps_zr, false);
  %tmp = outnr.resid;  % WRONG!
  %tmp = gps_zr;
  tmp = gps_z;
  [offset, extra] = robustfit(outnr.jacob, tmp, [], [], 'off');
  out = struct();
  out.offset = offset;
  out.sigma0 = extra.s;
  out.cov = extra.covb;
  out.std = extra.se;
  out.jacobian = outnr.jacob;
  out.resid = extra.resid;
  out.dof = get_dof (out);
  out.conf = get_conf (out);
end

%%
function dof = get_dof (out)
  dof = sum(~isnan(out.resid)) - 3;
end

%%
function conf = get_conf (out)
  conf = diff(get_pred_lim(out.offset, out.std, out.dof, [], [], ...
    'mean', 'mean'), 1, 2);
end
