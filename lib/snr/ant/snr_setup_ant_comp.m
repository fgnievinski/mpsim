function comp = snr_setup_ant_comp (comp_type, model, radome, freq_name, ...
sph_harm_degree, load_redundant, switch_left_right, load_extended)
    if (nargin < 5),  sph_harm_degree = [];  end
    if (nargin < 6) || isempty(load_redundant),  load_redundant = false;  end
    if (nargin < 7) || isempty(switch_left_right),  switch_left_right = false;  end
    if (nargin < 8) || isempty(load_extended),  load_extended = true;  end
    %load_extended = false;  % DEBUG
    
    doit = @(polar) snr_setup_ant_comp_aux (...
        comp_type, model, radome, freq_name, polar, sph_harm_degree, ...
        load_redundant, load_extended);
    comp = struct();
    comp.eval = [];
    [comp.rhcp, preprocessed_rhcp] = doit('rhcp');
    [comp.lhcp, preprocessed_lhcp] = doit('lhcp');
    
    if strcmpi(comp_type, 'phase'),  return;  end
    
    if ( isempty(comp.rhcp) || isempty(comp.lhcp) )
        switch upper(freq_name)
        case 'L5'
            freq_name2 = 'L2';
            comp = snr_setup_ant_comp_retry (freq_name, freq_name2, ...
                comp_type, model, radome, ...
                sph_harm_degree, load_redundant, switch_left_right, load_extended);
        case {'R1','R2'}
            freq_name2 = setel(freq_name, 1, 'L');
            comp = snr_setup_ant_comp_retry (freq_name, freq_name2, ...
                comp_type, model, radome, ...
                sph_harm_degree, load_redundant, switch_left_right, load_extended);
        otherwise
            error('snr:ant:badPath', ...
                ['No pattern data found for '...
                 'antenna "%s" and radome "%s" in "%s" frequency\n'...
                 '(directory <%s>).'], ...
                model, radome, freq_name, snr_setup_ant_path());
        end
        return;
    end
    
    if ~preprocessed_rhcp || ~preprocessed_lhcp
        if is_octave ()
            warning('snr:setup_ant_comp:noPre', ...
                ['Pre-loaded antenna data not found.\n' ...
                 'For improved speed, please execute snr_setup_ant_preload();\n' ...
                 'to disable this warning message, execute instead:\n' ...
                 'warning(''off'',''snr:setup_ant_comp:noPre'')']);
        else
            warning('snr:setup_ant_comp:noPre', ...
                ['Pre-loaded antenna data not found.\n' ...
                 'For improved speed, please ' ...
                 '<a href="matlab: snr_setup_ant_preload(); ">click here</a>;\n' ...
                 'to disable this warning message, ' ...
                 '<a href="matlab: warning(''off'',''snr:setup_ant_comp:noPre'')">'...
                 'click here instead</a>.']);
        end
    end
    
    if switch_left_right
        % (Ad-hoc solution for defining an unknown LHCP-predominant 
        % antenna similar to a known RHCP-predominant antenna.)
        [comp.rhcp, comp.lhcp] = deal(comp.lhcp, comp.rhcp);
    end
end

%%
function comp = snr_setup_ant_comp_retry (freq_name_old, freq_name_new, ...
comp_type, model, radome, ...
sph_harm_degree, load_redundant, switch_left_right, load_extended)
    warning('snr:ant:noFreq', ...
       ['No antenna pattern data found for frequency "%s"; trying "%s" '...
        '(model "%s" and radome "%s").'], ...
       freq_name_old, freq_name_new, model, radome);
    comp = snr_setup_ant_comp (comp_type, model, radome, freq_name_new, ...
        sph_harm_degree, load_redundant, switch_left_right, load_extended);
end

%%
function [comp, preprocessed, freq_name] = snr_setup_ant_comp_aux (...
comp_type, model, radome, freq_name, polar, sph_harm_degree, ...
load_redundant, load_extended)
    comp = struct();
    comp.type = comp_type;
    comp.filename = snr_setup_ant_filename (...
        comp_type, model, radome, freq_name, polar);
    data_dir = snr_setup_ant_path();
    
    filepath = fullfile(data_dir, 'densemap', comp.filename);
    if exist(filepath, 'file')
        comp.densemap = getfield1(load(filepath, '-mat'));
        preprocessed = true;
        if ~load_redundant,  return;  end
    else
        preprocessed = false;
    end
    
    filepath = fullfile(data_dir, 'sphharm', comp.filename);
    if exist(filepath, 'file')
        comp.sphharm = getfield1(load(filepath, '-mat'));
        preprocessed = preprocessed && true;
        if ~preprocessed
            comp.densemap = snr_setup_ant_densemap_load(comp.sphharm);
        end
        if ~load_redundant,  return;  end
    else
        preprocessed = false;
    end
    
    filepath = fullfile(data_dir, 'profile', comp.filename);
    if load_extended
        filepath2 = [filepath 'X'];
        if exist(filepath2, 'file')
            filepath = filepath2;
        end
    end
    if exist(filepath, 'file')
        comp.profile = snr_setup_ant_profile_load (filepath, comp.type);
        preprocessed = preprocessed && true;
        if ~preprocessed
            comp.sphharm  = snr_setup_ant_sphharm_load(comp.profile, sph_harm_degree);
            comp.densemap = snr_setup_ant_densemap_load(comp.sphharm);
        end
        return;
    end

    comp = [];
end
