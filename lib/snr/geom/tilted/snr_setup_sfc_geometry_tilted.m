function sfc = snr_setup_sfc_geometry_tilted (pos_ant, pos_sfc0, sett_sfc)
    if (nargin < 2) || isempty(pos_sfc0),  pos_sfc0 = [0 0 0];  end
    
    %if ~isfieldempty(sett_sfc, 'along') && ~isfieldempty(sett_sfc, 'across')
    if ~isfieldempty(sett_sfc, 'along') || ~isfieldempty(sett_sfc, 'across')
        if isfieldempty(sett_sfc, 'along'),   sett_sfc.along = 0;   end
        if isfieldempty(sett_sfc, 'across'),  sett_sfc.across = 0;  end
        if ~(isscalar(sett_sfc.along) && isscalar(sett_sfc.across))
            error('snr:snr_setup_sfc_geometry_tilted:nonScalar', ...
                'Non-scalar surface along- and across-track tilting.')
        end
        if ~isfieldempty(sett_sfc, 'slope') || ~isfieldempty(sett_sfc, 'aspect')
            warning('snr:snr_setup_sfc_geometry_tilted:hasBoth', ...
                ['Ignoring non-empty surface slope/aspect angles'...
                 '(non-empty along/across takes precedence).']);
        end
        if isfieldempty(sett_sfc, 'azim')
            sett_sfc.azim = 0;
            %warning('snr:snr_setup_sfc_geometry_tilted:azim', ...
            %    'Assuming sfc.azim = 0.');
        end
        sfc.azim = sett_sfc.azim;
        sfc.along = sett_sfc.along;
        sfc.across = sett_sfc.across;
        [sfc.dir_nrml, sfc.rot] = alongacross2sfcnrml (sfc.along, sfc.across, sfc.azim);
        [sfc.slope, sfc.aspect] = sfcnrml2slopeaspect(sfc.dir_nrml);
    else
        if isfieldempty(sett_sfc, 'slope'),   sett_sfc.slope = 0;   end
        if isfieldempty(sett_sfc, 'aspect'),  sett_sfc.aspect = 0;  end
        %assert(all(0 <= sett_sfc.slope && sett_sfc.slope <= 90))
        if ~(isscalar(sett_sfc.slope) && isscalar(sett_sfc.aspect))
            error('snr:snr_setup_sfc_geometry_tilted:nonScalar', ...
                'Non-scalar surface slope and aspect.')
        end
        sfc.slope  = sett_sfc.slope;
        sfc.aspect = sett_sfc.aspect;
        [sfc.rot, sfc.dir_nrml, sfc.dz_dx, sfc.dz_dy] = get_rotation_matrix3_local (...
            sfc.slope, sfc.aspect);
        sfc.azim = [];
        sfc.along = [];
        sfc.across = [];
    end
    sfc.vec_nrml = sfc.dir_nrml;
    sfc.pos_sfc0 = pos_sfc0;
    
    sfc.pos_ant_sfc = proj_pt_plane (...
        pos_ant, pos_sfc0, sfc.dir_nrml.cart, true);

    %sfc.vec_ant_sfc = minus_all(pos_ant, pos_sfc0);  % WRONG!
    sfc.vec_ant_sfc_perp = minus_all(pos_ant, sfc.pos_ant_sfc);
    sfc.dist_ant_sfc_perp = norm_all(sfc.vec_ant_sfc_perp);
    sfc.height_ant_sfc = pos_ant(:,3) - plane_eval (...
        pos_ant(:,1:2), sfc.pos_sfc0, sfc.vec_nrml.cart);

    %sfc.pos_ant_img = 2*(sfc.pos_ant_sfc - pos_ant) + pos_ant;  % WRONG!
    sfc.pos_ant_img = 2*sfc.pos_ant_sfc - pos_ant;

    sfc.snr_fwd_geometry_reflection = @snr_fwd_geometry_reflection_tilted;
    sfc.snr_fwd_direction_local2sfc = @snr_fwd_direction_local2sfc_tilted;
    sfc.snr_fwd_visibility          = @snr_fwd_visibility_tilted;
    sfc.snr_fwd_divergence          = @snr_fwd_divergence_tilted;
    sfc.snr_fwd_geometry_sfc_height = @snr_fwd_geometry_sfc_height_tilted;
    sfc.num_specular_max = 1;
end

