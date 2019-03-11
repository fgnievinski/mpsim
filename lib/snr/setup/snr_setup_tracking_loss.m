function data = snr_setup_tracking_loss (opt, varargin)
    if ( strcmpi(opt.freq_name, 'L5') && strcmpi(opt.code_name, 'L5')  && strcmpi(opt.subcode_name, 'Q') ) ...
    || ( strcmpi(opt.freq_name, 'L2') && strcmpi(opt.code_name, 'L2C') && strcmpi(opt.subcode_name, 'CL') )
        data = -6;
        % ... "the signal 
        % component without data modulation can be tracked with a 
        % simple phase locked loop, which has a 6 dB better 
        % tracking threshold than a Costas loop"            
        % <http://navcen.uscg.gov/pdf/gps/TheNewL2CivilSignal.pdf>
    elseif strcmpi(opt.freq_name, 'R2') && strcmpi(opt.code_name, 'P(Y)')
        % As per Boon et al. (1998), "GPS+GLONASS RTK: Making the Choice
        % Between Civilian and Military L2 GLONASS"
        % <http://www.septentrio.com/sites/default/files/papers/BoonSleewaegenSimskyDewilde_GLOL2_IONGNSS2008.pdf>:
        % "Figure 4 represents the carrier-to-noise ratio difference
        % between the L2CA and L2P signals, measured over a period of about
        % 2 hours. (...) It is apparent that the L2CA signal benefits from
        % about 2 dB of additional carrier power."
        data = +2;  % G2-P has low power than G2-C/A
        %data = -2;  % WRONG!
    elseif strcmpi(opt.freq_name, 'R1') && strcmpi(opt.code_name, 'P(Y)')
        % ASSUMPTION: it's the same as for second band:
        opt2 = setfield(opt, 'freq_name','R2');
        data = snr_setup_tracking_loss (opt2);
    elseif strcmpi(opt.freq_name, 'L2') && strcmpi(opt.code_name, 'P(Y)')
        data = snr_setup_tracking_loss_L2P (opt, varargin);
    else
        data = [];
    end
end

%%
function data = snr_setup_tracking_loss_L2P (opt, data_dir, filename)
    if (nargin < 2) || isempty(data_dir),  data_dir = snr_setup_rec_path ();  end
    if (nargin < 3) || isempty(filename),  filename = 'snr_s2_vs_sc_fit2.dat';  end
    if opt.disable_tracking_loss,  data = [];  return;  end
    persistent data0 opt0 data_dir0 filename0
    if all(isequaln({opt data_dir filename}, {opt0 data_dir0 filename0}))
        data = data0;
        return;
    end
    data = snr_setup_tracking_loss_L2P_aux (opt, data_dir, filename);
    data0 = data;
    data_dir0 = data_dir;
    filename0 = filename;
    opt0 = opt;
end

%%
function data = snr_setup_tracking_loss_L2P_aux (opt, data_dir, filename)
    filepath = fullfile(data_dir, filename);
    temp = load(filepath);
    data = struct('sc',temp(:,1), 'sd',temp(:,2));
    opt2 = opt;
    opt2.gnss_name = 'GPS';
    opt2.block_name = 'IIR-M';
    opt2.code_name = 'L2C';
    opt2.subcode_name = 'CL';  % this was used in collecting the data.
    data.sc_incident_power_min = get_gnss_power_min (...
        opt2.gnss_name, opt2.freq_name, opt2.block_name, opt2.code_name, opt2.subcode_name);
    data.sc_loss = snr_setup_tracking_loss (opt2);
end

%%
function data_dir = snr_setup_rec_path ()
    data_dir = fullfile(dirup(fileparts(which(mfilename()))), 'data', 'rec');
end

