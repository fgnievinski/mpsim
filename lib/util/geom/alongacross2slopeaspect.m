function [slope, aspect, along, across, azim] = alongacross2slopeaspect (along, across, azim)
    [along, across, azim, size_original] = alongacrossazim_expand (along, across, azim);
    dir_nrml = alongacross2sfcnrml (along, across, azim);
    %dir_nrml = -dir_nrml;  % DEBUG
    [slope, aspect] = sfcnrml2slopeaspect(dir_nrml);
    slope  = reshape(slope,  size_original);
    aspect = reshape(aspect, size_original);
    along  = reshape(along,  size_original);
    across = reshape(across, size_original);
    azim   = reshape(azim,   size_original);
end
    
function [slope, aspect, along, across, azim] = alongacross2slopeaspect_v2 (along, across, azim)
    [along, across, azim, size_original] = alongacrossazim_expand (along, across, azim);
    
    % azimuth refers to the satellite direct or line-of-sight direction, 
    % not to its reflection on the tilted surface, which is a complication.
    sat_azim_val = azim;
    sat_azim_dir = sph2cart_local([zeros(size(sat_azim_val)), sat_azim_val]);
    up_dir = [0 0 1];

    dot__sfc_nrml_dir__out_of_plane = cosd(90 - across);
    dot__sfc_nrml_dir__sat_azim_dir = cosd(90 - along);
    out_of_plane = cross_all(sat_azim_dir, up_dir);
    
    dot__sfc_nrml_dir__up_dir1 = sind(90 - across);
    dot__sfc_nrml_dir__up_dir2 = sind(90 - along);
    dot__sfc_nrml_dir__up_dir  = ...
    dot__sfc_nrml_dir__up_dir1 + ...
    dot__sfc_nrml_dir__up_dir2;
    
    sfc_nrml_dir = times_all(dot__sfc_nrml_dir__sat_azim_dir, sat_azim_dir) ...
                 + times_all(dot__sfc_nrml_dir__out_of_plane, out_of_plane) ...
                 + times_all(dot__sfc_nrml_dir__up_dir, up_dir);
    %sfc_nrml_dir = normalize_all(sfc_nrml_dir);  % DEBUG
    
    sfc_nrml_dir = -sfc_nrml_dir;  % DEBUG    
    [slope, aspect] = sfcnrml2slopeaspect (sfc_nrml_dir);
    
    slope  = reshape(slope,  size_original);
    aspect = reshape(aspect, size_original);
    along  = reshape(along,  size_original);
    across = reshape(across, size_original);
    azim   = reshape(azim,   size_original);
end

%!test
%! % alongacross2slopeaspect()
%! test slopeaspect2alongacross
