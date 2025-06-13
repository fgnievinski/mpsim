function data = get_glo_power_trend_data (freq_name, code_name)
    temp = get_glo_power_trend_data_aux (freq_name, code_name);
    data.elev = temp(:,1);
    data.incident_power = decibel_power_inv(temp(:,2));
    [~, ~, factor] = get_glo_code_sizes (code_name);
    data.incident_power = data.incident_power ./ factor;
    data.incident_power_pp = spline(data.elev, data.incident_power);
end

%%
function data = get_glo_power_trend_data_aux (freq_name, code_name)
    code_name = get_glo_synonym (code_name);
    all = get_glo_power_trend_all ();
    idx_freq = ismembercc(all.freq_name, freq_name);
    idx_code = ismembercc(all.code_name, code_name);
    idx_exact = idx_freq & idx_code;
    
    if (sum(idx_exact) ~= 1)
        error('snr:get_glo_power_trend_data:badComb', ...
            ['Unknown GLONASS combination of '...
            'frequency "%s", code "%s".'],...
            freq_name, code_name);
    end
    
    data = all.data{idx_exact};
    if ~isempty(data) && ~isequaln(data, NaN)
        return;
    end

    % find closest replacement among combinations available:
    idx_notempty = ~cellfun(@isempty, all.data);
    idx_notnan = ~cellfun(@(in) isequaln(in, NaN), all.data);
    idx_alt = idx_notempty & idx_notnan;  assert(sum(idx_alt) >= 1)
    if any(idx_alt & idx_freq),  idx_alt = idx_alt & idx_freq;  end
    if any(idx_alt & idx_code),  idx_alt = idx_alt & idx_code;  end
    
    ind_alt = find(idx_alt, 1, 'last');  clear idx_alt
    data = all.data{ind_alt};
    if ~isequaln(all.data{idx_exact}, NaN)      
        warning('snr:get_glo_power_trend_data:noData', ...
            ['Incident power trend data unavailable for '...
             'frequency "%s", code "%s"; '...
             'using instead data for '...
             'frequency "%s", code "%s".'],...
             freq_name, code_name, ...
             str2list(all.freq_name{ind_alt}, '/'), ...
             str2list(all.code_name{ind_alt}, '/')...
        );
    end
end

%%
function all = get_glo_power_trend_all ()
    % From Edition 5.1 2008 ICD R1, R2 GLONASS, sec. 3.3.1.9
    % Figure A.1 Relationship between minimum received power level and elevation angle

    all.freq_name = {...
        'R1'
        'R1'
        'R2'
        'R2'
    };

    all.code_name = {...
        'C/A'
        'P'
        'C/A'
        'P'
    };

    all.data{1,1} = [];  
    all.data{2,1} = [];  
    all.data{3,1} = []; 
    all.data{4,1} = []; 

    idx = ismembercc(all.freq_name, 'R1') ...
        & ismembercc(all.code_name, 'C/A');
    all.data{idx} = [...
       90 -160.66
       75 -159.75
       60 -158.9
       45 -158.75
       30 -160
       15 -161
       10 -161.08
    ];

    idx = ismembercc(all.freq_name, 'R2') ...
        & ismembercc(all.code_name, 'C/A');
    all.data{idx} = [...
       90 -166.66
       75 -166.25
       60 -165.66
       45 -166
       30 -166.5
       15 -166.8
       10 -166.88
    ];
    
%     idx = ismembercc(all.freq_name, {'R1','R2'}) ...
%         & ismembercc(all.code_name, 'P');
%     all.data(idx) = {NaN};  
    
    return;
    % DEBUG:
    temp = cellfun(@isempty, all.data);
    temp = getfieldel(all, temp);
    temp.freq_name, temp.code_name
end

