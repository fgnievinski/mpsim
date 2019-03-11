function [snr_db, answer, carrier_error, code_error] = calc_diffraction_series2 (elev_sat, azim_sat, ant, opt2, field)
    if (nargin < 5),  field = {};  end
    
    sett = snr_fwd_settings_local (elev_sat, azim_sat, ant, opt2);
    [sat, sfc, ant, ref, opt] = snr_fwd_setup (sett);

    opt2 = getfields(opt2, {'patch_extent','lim','step','z_fnc','dem'}, true);
    opt = structmergenonempty(opt, opt2);
    
    if isequaln(field, NaN)
    %if isscalar(field) && isnan(field)  % WRONG! fails with field = {'*'}.
        [snr_db, answer, carrier_error, code_error] = snr_po_run1 (...
            sat, sfc, ant, ref, opt);
    else
        [snr_db, answer, carrier_error, code_error] = snr_po_run (...
            sat, sfc, ant, ref, opt, field);
    end
    
    answer_old = answer;
    clear answer
    %answer = struct();  % WRONG!
    for i=1:numel(answer_old)
        answer(i) = structmerge(answer_old(i), answer_old(i).info);
    end
end

function sett = snr_fwd_settings_local (elev_sat, azim_sat, ant, opt2)
    sett = snr_fwd_settings ();
    sett.sat.elev = elev_sat;
    sett.sat.azim = azim_sat;
    if isfield(opt2, 'height_std') && ~isempty(opt2.height_std)
        sett.sfc.height_std = opt2.height_std;
    end
    if isfield(opt2, 'material_top') && ~isempty(opt2.material_top)
        sett.sfc.material_top = opt2.material_top;
    end
    if isfield(opt2, 'material_bottom') && ~isempty(opt2.material_bottom)
        sett.sfc.material_bottom = opt2.material_bottom;
    end
    if isfield(ant, 'model') && ~isempty(ant.model)
        sett.ant.model = ant.model;
    end
    if isfield(ant, 'radome') && ~isempty(ant.radome)
        sett.ant.radome = ant.radome;
    end
    if isfield(opt2, 'ant_height_above_sfc') && ~isempty(opt2.ant_height_above_sfc)
        sett.ref.height_ant = opt2.ant_height_above_sfc;
    end
    if (opt2.frequency == get_gps_const('L1', 'frequency'))
        sett.opt.freq_name = 'L1';
    elseif (opt2.frequency == get_gps_const('L2', 'frequency'))
        sett.opt.freq_name = 'L2';
    else
        warning('snr:calc_diffraction2:badFreq', ...
            'Unknown name of frequency value %f Hz -- assuming L2.', ...
            opt2.frequency);
        sett.opt.freq_name = 'L2';
    end
end
