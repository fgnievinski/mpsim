function data = get_gps_power_trend_data (freq_name, block_name, code_name, subcode_name)
    temp = get_gps_power_trend_data_aux (freq_name, block_name, code_name, subcode_name);
    data.elev = temp(:,1);
    data.incident_power = decibel_power_inv(temp(:,2));
    [~, ~, factor] = get_gps_code_sizes (code_name, subcode_name, freq_name);
    data.incident_power = data.incident_power ./ factor;
    data.incident_power_pp = spline(data.elev, data.incident_power);
end

%%
function data = get_gps_power_trend_data_aux (freq_name, block_name, code_name, subcode_name)
    [code_name, subcode_name] = get_gps_synonym (code_name, subcode_name, freq_name);
    all = get_gps_power_trend_all ();
    idx_freq    = ismembercc(all.freq_name,    freq_name);
    idx_block   = ismembercc(all.block_name,   block_name);
    idx_code    = ismembercc(all.code_name,    code_name);
    idx_subcode = ismembercc(all.subcode_name, subcode_name);
    idx_exact = idx_freq & idx_block & idx_code & idx_subcode;
    
    if (sum(idx_exact) ~= 1)
        error('snr:get_gps_power_trend_data:badComb', ...
            ['Unknown GPS combination of '...
            'frequency "%s", block "%s", code "%s", subcode "%s".'],...
            freq_name, block_name, code_name, subcode_name);
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
    %if ~isequaln(data, NaN)  % WRONG!
    if ~isequaln(all.data{idx_exact}, NaN)      
        % there is better information in the GPS ICD:
        warning('snr:get_gps_power_trend_data:noData', ...
            ['Incident power trend data unavailable for '...
             'frequency "%s", block "%s", code "%s", subcode "%s"; '...
             'using instead data for '...
             'frequency "%s", block "%s", code "%s", subcode "%s".'],...
             freq_name, block_name, code_name, subcode_name, ...
             str2list(all.freq_name{ind_alt}, '/'), ...
             str2list(all.block_name{ind_alt}, '/'), ...
             str2list(all.code_name{ind_alt}, '/'), ...
             str2list(all.subcode_name{ind_alt}, '/') ...
        );
    end
end

%%
function all = get_gps_power_trend_all ()
    % From the GPS ICD, Figure 6-1. "User Received Minimum Signal Level
    % Variations (Example, Block II/IIA/IIR)", p.54:
    %   <http://www.gps.gov/technical/icwg/IS-GPS-200F.pdf>
    % 
    % Digitized using Inkscape (tried Trace bitmap tool, ended up doing it
    % manually), then exported as a latex drawing to get the coordinates.
    % 
    % I digitized the trend for all combinations of frequency, block, and
    % code available in the GPS ICD; it had no power trend data for some 
    % of the combinations.
    % 
    % These values are in dBW, so they already include the 
    % receiving antenna isotropic effective area! In other words,
    % these values are NOT in dB-W/m^2! Be carefull when applying A_iso!

    % Freq, Block, Code, Power (dBW re 1 W)
    % L1  II/IIA/IIR  P(Y)
    % L1  II/IIA/IIR  C/A 
    % L2  II/IIA/IIR  P(Y)
    % L1  IIR-M/IIF   P(Y)
    % L1  IIR-M/IIF   C/A 
    % L2  IIR-M/IIF   P(Y)
    % L2  IIR-M/IIF   L2C 
    % L2  IIR-M/IIF   C/A  % possible according to ICD.
    % L5  IIF/III
    all.freq_name = {...
        'L1'
        'L1'
        'L2'
        'L1'
        'L1'
        'L2'
        'L2'
        'L2'
        'L5'
    };
    all.block_name = {...
        {'II','IIA','IIR'}
        {'II','IIA','IIR'}
        {'II','IIA','IIR'}
        {'IIR-M','IIF'}
        {'IIR-M','IIF'}
        {'IIR-M','IIF'}
        {'IIR-M','IIF'}
        {'IIR-M','IIF'}
        {'IIF','III'}
    };
    all.code_name = {...
        'P(Y)'
        'C/A'
        'P(Y)'
        'P(Y)'
        'C/A'
        'P(Y)'
        'L2C'
        'C/A'
        {'','L5'}
    };
    all.subcode_name = {...
        {''}
        {''}
        {''}
        {''}
        {''}
        {''}
        {'CM','CL'}
        {''}
        {'I','Q','X'}
    };

    all.data{1,1} = [];  % L1  II/IIA/IIR  P(Y)
    all.data{2,1} = [];  % L1  II/IIA/IIR  C/A 
    all.data{3,1} = [];  % L2  II/IIA/IIR  P(Y)
    all.data{4,1} = [];  % L1  IIR-M/IIF   P(Y)
    all.data{5,1} = [];  % L1  IIR-M/IIF   C/A 
    all.data{6,1} = [];  % L2  IIR-M/IIF   P(Y)
    all.data{7,1} = [];  % L2  IIR-M/IIF   L2C 
    all.data{8,1} = [];  % L2  IIR-M/IIF   C/A 
    all.data{9,1} = [];  % L5  IIF/III     I,Q

    %ismembercc(all.block_name, {'II','IIA','IIR'})  % DEBUG
    idx = ismembercc(all.freq_name, 'L2') ...
        & ismembercc(all.block_name, {'II','IIA','IIR'}) ...
        & ismembercc(all.code_name, 'P(Y)');
    all.data{idx} = [...
       93.1966 -164.5021
       91.7666 -164.5063
       89.7897 -164.4937
       87.3922 -164.4852
       85.0368 -164.4599
       82.4711 -164.4346
       78.8520 -164.3924
       74.9763 -164.3418
       72.3223 -164.3038
       68.7414 -164.2405
       65.9610 -164.1857
       62.1696 -164.1097
       59.8523 -164.0422
       57.4894 -164.0000
       54.7046 -163.9367
       51.6667 -163.8608
       47.9536 -163.7764
       45.1688 -163.7300
       43.9451 -163.7131
       42.5105 -163.7004
       41.0759 -163.6878
       39.5991 -163.6751
       38.1224 -163.6709
       36.1814 -163.6667
       34.8312 -163.6793
       32.8903 -163.6962
       31.4979 -163.7173
       30.3586 -163.7426
       29.2616 -163.7722
       28.2068 -163.8017
       26.2658 -163.8565
       25.1688 -163.8945
       23.8186 -163.9367
       22.5105 -163.9873
       21.0338 -164.0380
       20.2321 -164.0717
       18.7544 -164.1181
       17.1499 -164.1688
       15.7143 -164.2110
       13.9409 -164.2658
       11.9141 -164.3249
        9.6763 -164.3755
        7.3962 -164.4262
        6.4673 -164.4473
        5.3483 -164.4662
        3.9936 -164.4968
        2.6017 -164.5021
       -0.0642 -164.5021
    ];

    idx = ismembercc(all.freq_name, 'L1') ...
        & ismembercc(all.block_name, 'IIR') ...
        & ismembercc(all.code_name, 'P(Y)');
    all.data{idx} = [...
        93.3499 -161.5089
        92.4715 -161.5056
        91.5665 -161.4951
        89.6837 -161.4498
        87.0542 -161.3786
        84.7343 -161.3149
        82.1749 -161.2601
        78.8324 -161.1528
        74.6386 -160.9744
        71.6336 -160.8533
        68.6275 -160.7253
        65.7944 -160.5817
        61.9527 -160.3574
        60.0286 -160.2402
        57.6418 -160.0881
        54.8638 -159.9032
        51.4455 -159.7119
        49.6698 -159.6404
        47.7415 -159.5692
        45.2321 -159.5056
        44.3098 -159.4890
        42.9981 -159.4766
        41.5670 -159.4731
        39.9447 -159.4756
        38.1135 -159.4984
        36.3265 -159.5272
        35.0095 -159.5636
        32.9838 -159.6340
        31.7440 -159.6906
        30.5777 -159.7634
        29.5132 -159.8223
        28.3715 -159.8872
        26.4353 -160.0309
        25.5796 -160.1011
        24.4714 -160.1964
        23.1666 -160.3120
        21.8128 -160.4485
        20.8043 -160.5385
        19.6590 -160.6410
        18.2675 -160.7566
        16.9847 -160.8638
        15.4545 -160.9716
        13.6418 -161.1074
        11.8274 -161.2290
         9.7619 -161.3326
         7.6410 -161.4191
         6.4353 -161.4557
         5.5003 -161.4815
         4.2212 -161.5052
         2.7116 -161.5089
         0.1128 -161.5059
    ];
    %all.data{idx} = [];  % DEBUG

    idx = ismembercc(all.freq_name, 'L1') ...
        & ismembercc(all.block_name, {'II','IIA','IIR'}) ...
        & ismembercc(all.code_name, 'C/A');
    all.data{idx} = [...
        93.3499 -158.51167
        92.4715 -158.50836
        91.3285 -158.50983
        89.5944 -158.48542
        86.9352 -158.39635
        84.5856 -158.33856
        82.1749 -158.26283
        78.8622 -158.17051
        74.5789 -158.01305
        71.4548 -157.87102
        68.5381 -157.73703
        65.7646 -157.59936
        61.8930 -157.39907
        60.0286 -157.29085
        57.5522 -157.16263
        54.7146 -156.99573
        52.0720 -156.83135
        49.5803 -156.69397
        47.6818 -156.58986
        45.9182 -156.54126
        44.3098 -156.50673
        42.9980 -156.47933
        41.5670 -156.47587
        39.9446 -156.47839
        38.1135 -156.50118
        36.3265 -156.52994
        35.0094 -156.56631
        32.9838 -156.61880
        31.6246 -156.67543
        30.4285 -156.72424
        29.4833 -156.78019
        28.1626 -156.86307
        26.7336 -156.95286
        25.4006 -157.03505
        24.3222 -157.10045
        23.1368 -157.19507
        21.8426 -157.29568
        20.8042 -157.36475
        19.1813 -157.49413
        17.8793 -157.58876
        16.6264 -157.68706
        15.0066 -157.82174
        12.6565 -157.99946
        11.3795 -158.09409
        9.73208 -158.20367
        7.64101 -158.32014
        6.64427 -158.37470
        5.44055 -158.42739
        4.22117 -158.50798
        2.71158 -158.51167
        0.11277 -158.50868
    ];
    
    idx = ismembercc(all.code_name, 'L2C');
    all.data{idx} = NaN;  % there is no better information in the GPS ICD.
    
    idx = ismembercc(all.code_name, 'L5');
    all.data{idx} = NaN;  % there is no better information in the GPS ICD.

    idx = ismembercc(all.freq_name, {'L1','L2'}) ...
        & ismembercc(all.block_name, {'IIR-M','IIF'}) ...
        & ismembercc(all.code_name, {'C/A','P(Y)'});
    all.data(idx) = {NaN};  % there is no better information in the GPS ICD.
    %all.data{idx} = NaN;  % WRONG!
    
    return;
    % DEBUG:
    temp = cellfun(@isempty, all.data);
    temp = getfieldel(all, temp);
    temp.freq_name, temp.block_name{:}, temp.code_name
end

