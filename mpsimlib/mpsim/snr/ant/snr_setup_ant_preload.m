function snr_setup_ant_preload (sett)
    if (nargin < 1) || isempty(sett),  sett = snr_settings();  end
    warn1 = warning('off', 'snr:setup_ant_comp:noPre');
    warn2 = warning('off', 'snr:ant:Profile:noOffset');    
    try
        snr_setup_ant_preload_aux (sett);
    catch err
        warning(err.identifier, err.message);
        rethrow(err)
    end
    warning(warn1);
    warning(warn2);
end

%%
function snr_setup_ant_preload_aux (sett)
    data_dir = snr_setup_ant_path();
    sph_harm_degree = sett.ant.sph_harm_degree;
    load_redundant = true;
    sep = '__';
    ext = 'DAT';
    %ext = 'dat';  % WRONG!
    filelist = dir(fullfile(data_dir, 'profile', ['*.' ext]));
    for i=1:length(filelist)
        %str = 'TRM29659.00__NONE__L1__LHCP__GAIN.DAT'
        str = filelist(i).name;
        str = lower(str);
        str(find(str=='.', 1, 'last'):end) = [];
        temp = regexp(str, sep, 'split');
        [model, radome, freq_name, polar, comp_type] = temp{:};

        comp = snr_setup_ant_comp (comp_type, model, radome, freq_name, ...
            sph_harm_degree, load_redundant);

        prod = {'sphharm', 'densemap'};
        for j=1:length(prod)
            filepath = fullfile(data_dir, prod{j}, filelist(i).name);
            if exist(filepath, 'file'),  continue;  end
            fprintf('%s\t%s\n', upper(str), upper(prod{j}))
            temp = comp.(lower(polar)).(prod{j});
            if is_octave(),  temp = structfun2(@func2str2, temp);  end  %#ok<NASGU>
            %save(filepath, 'temp');  % octave's default might be different.
            save(filepath, 'temp', '-mat');
        end
    end
end
