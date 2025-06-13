function model = snr_setup_ant_synonym (model)
    temp = {...
        'TRM41249USCG'   'TRM41249.00'
        'TRM55971.00'    'TRM57971.00'
        'TRM59800.80'    'TRM59800.00'
    };
    idx = strcmpi(temp(:,1), model);
    if ~any(idx),  return;  end
    model = temp{idx,2};
end
