function [setup, sett] = snr_resetup (sett, setup, verbose, check_deprecated, renew_pre)
%SNR_RESETUP: Faster snr_setup for multiple related settings.
% SEE ALSO: snr_resetup_check.

    verbose_default = false;
    %verbose_default = true;  % DEBUG
    check_deprecated_default = false;
    renew_pre_default = true;
    if (nargin < 1),  sett = [];  end
    if (nargin < 2),  setup = [];  end
    if (nargin < 3) || isempty(verbose),  verbose = verbose_default;  end
    if (nargin < 4) || isempty(check_deprecated),  check_deprecated = check_deprecated_default;  end
    if (nargin < 5) || isempty(renew_pre),  renew_pre = renew_pre_default;  end    
    if isstruct(verbose) || isstruct(check_deprecated)
        error('snr:resetup:badArg', 'Type of arguments invalid.');
    end
    %if (getfield(whos('sett'), 'bytes') > getfield(whos('setup'), 'bytes')) %#ok<GFLD>
    %    warning('snr:resetup:order', 'Order of arguments seems wrong.');
    %end
    %verbose = true;
    
    if iscell(sett)
        [setup, sett] = cell_snr_resetup (sett, setup, ...
            verbose, check_deprecated, renew_pre);
        return;
    end

    if isempty(setup),  setup = snr_setup (sett);  return;  end
    
    if check_deprecated
        sett = snr_deprecated (sett);
        %setup.sett = snr_deprecated (setup.sett);  % already done in snr_setup.
    end
    
    setup_old = setup;
    [setup, what_changed] = snr_resetup_aux (sett, setup);
    setup.sett = sett;  % keep a copy of input.
    
    if isempty(what_changed) ...
    || isequal(what_changed, {'bias'})
        if verbose,  disp([mfilename() ': early exit.']);  end
        return;
    end
    if verbose
        dbstack()
        %disp(str2list(what_changed))
        fprintf('%s (%s): %s\n', mfilename(), get_caller_name(), str2list(what_changed, [], '.'));
    end

    if isfieldempty(setup, 'pre'),  return;  end
    setup.pre = [];
    warning('snr:inv:preBad', ...
        'Disabling/resetting "setup.pre" because settings changed.');
    if ~renew_pre,  return;  end
%     if verbose,  for i=1:numel(what_changed)
%         disp([what_changed{i} ':'])
%         disp(setup.(what_changed{i}))
%         disp([what_changed{i} ' old:'])
%         disp(setup_old.(what_changed{i}))
%     end,  end
    result = snr_fwd (setup);
    setup.pre = result.pre;
end

%%
function [setup, what_changed] = snr_resetup_aux (sett, setup)
    setup_old = setup;
    sett_old = setup_old.sett;
    what_changed = {};
    
    [sett, sett_old, return_now] = snr_resetup_aux2 (sett, sett_old);  
    if return_now,  return;  end
    iseq = @isequaln;

    if ~iseq(sett.sat, sett_old.sat)
        what_changed{end+1} = 'sat';
        setup.sat = snr_setup_sat (sett.sat);
        if iseq(setup.sat, setup_old.sat),  what_changed(end) = [];  end
    end
    [sett, sett_old, return_now] = snr_resetup_aux2 (sett, sett_old, 'sat');
    %if return_now,  return;  end  % WRONG!  bias depends on sat.
    
    if ~iseq(sett.opt, sett_old.opt)
        what_changed{end+1} = 'opt';
        setup.opt = snr_setup_opt (sett.opt);
        if iseq(setup.opt, setup_old.opt),  what_changed(end) = [];  end
    end
    [sett, sett_old, return_now] = snr_resetup_aux2 (sett, sett_old, 'opt');
    %if return_now,  return;  end  % WRONG!  bias depends on opt

    if ~iseq(sett.bias, sett_old.bias) ...
    || ~iseq(setup.sat, setup_old.sat) ...
    || ~iseq(setup.opt, setup_old.opt)
        what_changed{end+1} = 'bias';
        setup.bias = snr_setup_bias (sett.bias, setup.sat, setup.opt);
        if iseq(setup.bias, setup_old.bias),  what_changed(end) = [];  end
    end
    [sett, sett_old, return_now] = snr_resetup_aux2 (sett, sett_old, 'bias');
    %if return_now,  return;  end  % WRONG!  ant depends on opt
    
    if ~iseq(sett.ant, sett_old.ant) ...
    ...%|| ~iseq(sett.opt.freq_name, sett_old.opt.freq_name) ...  % % WRONG!
    || ~iseq(setup.opt.freq_name, setup_old.opt.freq_name) ...
    || ~iseq(setup.opt.frequency, setup_old.opt.frequency) ...
    || ~iseq(sett.ref.ignore_vec_apc_arp, sett_old.ref.ignore_vec_apc_arp)
        what_changed{end+1} = 'ant';
        setup.ant = snr_setup_ant (sett.ant, setup.opt.freq_name, ...
            setup.opt.frequency, sett.ref.ignore_vec_apc_arp);
    end
    %[sett, sett_old, return_now] = snr_resetup_aux2 (sett, sett_old, 'ant');
    %if return_now,  return;  end  % WRONG! ant, ref, sfc are inter-twined.

    if ~iseq(sett.ref, sett_old.ref) ...
    || ~iseq(setup.ant.rot, setup_old.ant.rot) ...
    || ~iseq(setup.ant.vec_apc_arp_upright, setup_old.ant.vec_apc_arp_upright) ...
    || ~iseq(setup.sat.epoch, setup_old.sat.epoch)
        what_changed{end+1} = 'ref';
        setup.ref = snr_setup_origin (sett.ref, ...
            setup.ant.vec_apc_arp_upright, setup.ant.rot, setup.sat.epoch);
        if iseq(setup.ref, setup.ref)
            what_changed(end) = [];  % it didn't change after all.
        end
    end
    %[sett, sett_old, return_now] = snr_resetup_aux2 (sett, sett_old, 'ref');
    %if return_now,  return;  end  % WRONG! ant, ref, sfc are inter-twined.
  
    if ~iseq(sett.sfc, sett_old.sfc) || iscell(sett.sfc)
        what_changed{end+1} = 'sfc';
        setup.sfc = snr_setup_sfcs (sett.sfc, setup.opt.frequency, setup.ref);
    else  % (do incremental load separately for each sfc part)
        sfc  = setup_old.sfc;
        sfc0 = sfc.pre0;
        sfc1 = sfc.pre1;
        sfc2 = sfc.pre2;
        if ~iseq(setup.opt.freq_name, setup_old.opt.freq_name) ...
        || ~iseq(setup.opt.channel, setup_old.opt.channel)
            what_changed{end+1} = 'sfc0';
            sfc0 = snr_setup_sfc_material (sett.sfc, setup.opt.frequency);
            sfc = structmerge(sfc, sfc0);
        end
        if ~iseq(setup.ref, setup_old.ref) ...
        || ~iseq(sfc0.thickness, setup_old.sfc.pre0.thickness)
            what_changed{end+1} = 'sfc1';
            sfc1 = snr_setup_sfc_origin (sfc0.thickness, setup.ref, sett.sfc);
            sfc = structmerge(sfc, sfc1);
        end
        if ~iseq(setup.ref, setup_old.ref) ...
        || ~iseq(sfc0.thickness, setup_old.sfc.pre0.thickness)
            what_changed{end+1} = 'sfc2';
            sfc2 = snr_setup_sfc_geometry (setup.ref.pos_ant, sfc1.pos_sfc0, sett.sfc);
            sfc = structmerge(sfc, sfc2);
        end
        setup.sfc = sfc;
        setup.sfc.pre0 = sfc0;
        setup.sfc.pre1 = sfc1;
        setup.sfc.pre2 = sfc2;
    end
%#ok<*NASGU>
end

%%
function [sett, sett_old, return_now] = snr_resetup_aux2 (sett, sett_old, f)
    if (nargin > 2) && ~isempty(f)
        f = {f};  % speeds up rmfield.
        sett = rmfield(sett, f);
        sett_old = rmfield(sett_old, f);
    end
    return_now = isequaln(sett, sett_old);
end
