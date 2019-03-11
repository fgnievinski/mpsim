function sfc = snr_setup_sfc_origin (thickness, ref, sett_sfc)
    thickness_total = 0;
    if ~isempty(thickness)
       %thickness_total = max(thickness);  % WRONG!
       thickness_total = sum(thickness);
        assert(isscalar(thickness_total))
        assert(thickness_total >= 0)
    end

    vert_datum = sett_sfc.vert_datum;
    if isempty(vert_datum),  vert_datum = 'top';  end
    switch lower(vert_datum)
    case {'top','top-most','topmost'}  % useful for soil moisture
        pos_sfc0 = ref.pos_origin;
    case {'bottom','bottom-most','bottommost'}  % useful for snow
        assert(isscalar(thickness_total))
        pos_sfc0 = add_all(ref.pos_origin, times_all(thickness_total, ref.dir_up));
    otherwise
        error('snr:snr_setup_sfc_geometry:badVertDatum', ...
            ['Unknown vertical datum "%s"; try "top" or "bottom" for '...
             'the interface separating the middle layered medium from '...
             'the top and bottom half-spaces, respectively.'], vert_datum);
    end
    
    assert(size(pos_sfc0,1)==1)  % origin is unique.
    pos_sfc0 = repmat(pos_sfc0, [ref.num_heights 1]);

    sfc.pos_sfc0 = pos_sfc0;
    sfc.vert_datum = vert_datum;
    sfc.thickness_total = thickness_total;
end
