function [graz, incid, cosi] = convert_dir_local2sfc_grazing (dir_local, dir_normal)
    %norm_all(dir_normal)  % DEBUG
    %norm_all(dir_local)  % DEBUG
    cosi = dot_all(dir_local, dir_normal);
    incid = acosd(cosi);
    graz = 90 - incid;
    %graz = 90 - acosd(dot_all(dir_local, dir_normal));
end

%!test
%! % convert_dir_local2sfc_grazing()
%! test('snr_fwd_direction_local2sfc_grazing')

