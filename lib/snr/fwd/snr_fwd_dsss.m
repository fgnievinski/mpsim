% Direct-sequence spread-spectrum (DSSS) modulation -- 
% currently only binary phase shift keying (BPSK), for both GPS and GLONASS.
function [delay_replica, phasor_replica, delay_update, ...
phasor_direct_post, phasor_reflected_post, phasor_reflected_post_net, ...
correl_direct, correl_reflected] ...
= snr_fwd_dsss (opt, ...
phasor_direct_pre, phasor_reflected_pre, ...
delay_reflected, doppler_reflected, ...
delay_replica)
    %TODO: add test for PO
    %TODO: stress test for PO large-magnitude reflections (hint: material_bottom = 'pec';  ant_model = 'isotropic';  ant_radome = '';)
    %TODO: make tests pass for coherent discriminator.
    %TODO: iterate phasor_replica, too (hint: if opt.plotit; also reuse input; init it as phasor_direct_pre, not ones? -- correct first phasor or delay?)
    [num_dirs, num_refl] = size(delay_reflected);
    if isscalar(phasor_reflected_pre)
        phasor_reflected_pre = repmat(phasor_reflected_pre, [num_dirs, num_refl]);
    end
    assert(isequal(size(phasor_reflected_pre), [num_dirs, num_refl]))
    if (nargin < 6) || isempty(delay_replica), delay_replica = zeros(num_dirs,1);  end
    %opt.disable = true;  % DEBUG
    %opt.plotit = true;  % DEBUG
    
    %opt = structmergenonempty(get_opt_default(), opt);  % wait
    %if opt.disable
    if isfield(opt, 'disable') ...
    ... %&& opt.disable ...  % WRONG!
    && (~isempty(opt.disable) && opt.disable) ... 
    || getfield(get_opt_default(), 'disable') %#ok<GFLD>
        delay_replica = NaN(num_dirs,1);  % indetermined
        delay_update = NaN(num_dirs,1);  % indetermined
        correl_direct = ones(num_dirs,1);  % postulated
        correl_reflected = ones(num_dirs,num_refl);  % postulated
        phasor_direct_post = phasor_direct_pre;
        phasor_reflected_post = phasor_reflected_pre;
        phasor_reflected_post_net = sum(phasor_reflected_post, 2);
        phasor_replica = phasor_direct_post + phasor_reflected_post_net;
        return;
    end
    opt = structmergenonempty(get_opt_default(), opt);

    if opt.assume_zero  % Assume zero delay error? 
        delay_replica = zeros(num_dirs,1);  % postulated
        delay_update = NaN(num_dirs,1);  % indetermined
        [phasor_replica, phasor_direct_post, ...
         phasor_reflected_post, phasor_reflected_post_net, ...
         correl_direct, correl_reflected] ...        
            = get_dsss_correlation_composite (opt, ...
            phasor_direct_pre, phasor_reflected_pre, ...
            delay_reflected, doppler_reflected, ...
            delay_replica);
        return;
    end
    
    if opt.approx_small_delay
        correl_direct = ones(num_dirs,1);  % postulated
        correl_reflected = ones(num_dirs,num_refl);  % postulated
        phasor_direct_post = phasor_direct_pre;
        phasor_reflected_post = phasor_reflected_pre;
        phasor_reflected_post_net = sum(phasor_reflected_post, 2);
        phasor_replica = phasor_direct_post + phasor_reflected_post_net;
        %phasor_interf = phasor_reflected_post ./ phasor_direct_post;
        phasor_interf = bsxfun(@rdivide, phasor_reflected_post, phasor_direct_post);
        delay_direct = 0;
        delay_interf = delay_reflected - delay_direct;
        re_interf = real(phasor_interf);
        if opt.approx_small_power
            delay_error = sum(delay_interf .* re_interf, 2);
        else
            delay_error = sum(delay_interf .* re_interf ./ (1 + re_interf), 2);
        end
        delay_replica = delay_direct + delay_error;
        delay_update = NaN(num_dirs,1);  % indetermined
        return;
    else
        if opt.approx_small_power
            warning('snr:snr_fwd_dsss:badApprox', ...
                ['Code (not phase) small-power approximation unavailable '...
                 'unless it is selected in conjunction with the small-delay '...
                 'approximation; ignoring it.']);
        end
    end
    
    i = 0;
    if opt.plotit,  phasor_replica_old = ones(num_dirs,1);  end
    %phasor_replica_old = phasor_direct_pre + sum(phasor_reflected_pre, 2);  % DEBUG
    delay_update = NaN;
    while true
        if opt.plotit
            [phasor_replica, phasor_direct_post, ...
             phasor_reflected_post, phasor_reflected_post_net, ...
             correl_direct, correl_reflected] ...        
                = get_dsss_correlation_composite (opt, ...
                phasor_direct_pre, phasor_reflected_pre, ...
                delay_reflected, doppler_reflected, ...
                delay_replica);
            phasor_update = phasor_replica_old ./ phasor_replica;
            phasor_replica_old = phasor_replica;
            if (i==0),  figure(), maximize();  end
            subplot(4,2,1),  hold on,  plot(delay_update, '-k', 'LineWidth',2)
            subplot(4,2,2),  hold on,  plot(delay_replica, '-r', 'LineWidth',2)
            subplot(4,2,3),  hold on,  plot(correl_direct, '-k', 'LineWidth',2)
            subplot(4,2,4),  hold on,  plot(correl_reflected, '-r', 'LineWidth',2)
            subplot(4,2,5),  hold on,  plot(get_power(phasor_update), '-k', 'LineWidth',2)
            subplot(4,2,6),  hold on,  plot(get_power(phasor_replica), '-r', 'LineWidth',2)
            subplot(4,2,7),  hold on,  plot(get_phase(phasor_update), '-k', 'LineWidth',2)
            subplot(4,2,8),  hold on,  plot(get_phase(phasor_replica), '-r', 'LineWidth',2)
            subplot(4,2,1),  ylabel('delay')
            subplot(4,2,3),  ylabel('correl')
            subplot(4,2,5),  ylabel('power')
            subplot(4,2,7),  ylabel('phase')
            subplot(4,2,1),  title('update')
            subplot(4,2,2),  title('full replica')
            subplot(4,2,7),  xlabel('delay')
            subplot(4,2,8),  xlabel('delay')
            mtit(sprintf('iteration: %d', i))
            pause  % DEBUG
        end
      
        i = i + 1;
        delay_update = get_dsss_discriminator (opt, ...
            phasor_direct_pre, phasor_reflected_pre, ...
            delay_reflected, doppler_reflected, ...
            delay_replica);
        delay_replica = delay_replica - delay_update;
        
        %fprintf('i=%d,\t,%g\n', i, max(abs(delay_update)))  % DEBUG
        if ~opt.iterate || all(isnan(delay_update)) ...
        || (max(abs(delay_update)) < opt.delay_tol)
            break;
        end
        if (i >= opt.iteration_max)
            warning('snr:snr_fwd_dsss:notConv', ...
                'Reached maximum number of iterations before converging.');
            break
        end
    end
    if ~opt.plotit
        [phasor_replica, phasor_direct_post, ...
         phasor_reflected_post, phasor_reflected_post_net, ...
         correl_direct, correl_reflected] ...        
            = get_dsss_correlation_composite (opt, ...
            phasor_direct_pre, phasor_reflected_pre, ...
            delay_reflected, doppler_reflected, ...
            delay_replica);
    end
    
    %clear get_dsss_correlation_composite  % free up memory.
end

function opt = get_opt_default ()
    opt.disable = false;
    opt.assume_zero = false;
    opt.approx_small_delay = false;
    opt.approx_small_power = false;
    opt.iterate = false;
    opt.iteration_max = 15;
    %opt.delay_tol = nthroot(eps(),3);
    %opt.delay_tol = 1e-2;  % in meters
    %opt.delay_tol = 1e-3;  % in meters
    opt.delay_tol = 1e-4;  % in meters
    opt.plotit = false;
    opt.neglect_doppler = true;
    opt.coherent_integration_time = 20e-6;  % in seconds.
end

function answer = get_dsss_correlation (opt, delay, doppler)
    if (nargin < 3),  doppler = [];  end
    answer_delay   = get_dsss_correlation_delay (opt, delay);
    answer_doppler = get_dsss_correlation_doppler (opt, doppler);
    if isempty(answer_doppler)
        answer = answer_delay;
    else
        answer = answer_delay .* answer_doppler;
    end
end

function answer = get_dsss_correlation_doppler (opt, doppler)
    if opt.neglect_doppler || isempty(doppler) || all(isnan(doppler))
        answer = [];
        return;
    end
    temp = doppler .* opt.coherent_integration_time;
    answer = sinc(temp);
end

function answer = get_dsss_correlation_delay (opt, delay)
    if isfieldempty(opt, 'frontend_bandwidth')
        opt.frontend_bandwidth = Inf;
    end    
    if ~isinf(opt.frontend_bandwidth)
        error('snr:snr_fwd_dsss:unkBW', 'Non-infinite bandwidth not supported.');
    % TODO: support finite front-end bandwidth (rounding of dsss auto-correlation peak)
    % - hint: sample PRN at given bw then cross-correlate it (possibly via fft/ifft)
    % - hint2: save then reuse preprocessed result.
    end

    % convert units:
    delay_in_meters = delay;
    delay_in_chips = delay_in_meters ./ opt.chip_width;
    
    % PN DSSS auto-correlation, as function of number of chips 
    % (its mathematical definition is given on p.20-21 of the textbook;
    % this particular implementation is given on p.105):
     answer = (1 - abs(delay_in_chips)) .* heaviside(1 - abs(delay_in_chips));
    %answer = (1 - abs(delay_in_chips)) .*     (0 < (1 - abs(delay_in_chips)));
    % the textbook is Borre, Akos et al., "GPS SDR".
    %TODO: support BOC modulation (is it just a diff DSS correl fnc?).
end

function [phasor_replica, phasor_direct_post, ...
phasor_reflected_post, phasor_reflected_post_net, ...
correl_direct, correl_reflected] ...
= get_dsss_correlation_composite (opt, ...
phasor_direct_pre, phasor_reflected_pre, ...
delay_reflected, doppler_reflected, ...
delay_replica, delay_offset)
    if (nargin < 6) || isempty(delay_replica),  delay_replica = 0;  end
    if (nargin < 7) || isempty(delay_offset),  delay_offset = 0;    end
    %doppler_replica = 0;
    delay_replica2 = delay_replica + delay_offset;
    correl_direct  = get_dsss_correlation (opt, delay_replica2);
    phasor_direct_post = phasor_direct_pre .* correl_direct;
    if (size(delay_reflected,2) == 1)
        % valid only for a single simultaneous reflection:
        delay_replica3 = delay_replica2 - delay_reflected;
        correl_reflected = get_dsss_correlation (opt, delay_replica3, doppler_reflected);
        phasor_reflected_post = phasor_reflected_pre .* correl_reflected;
        phasor_reflected_post_net = phasor_reflected_post;
    else
        delay_replica3 = bsxfun(@minus, delay_replica2, delay_reflected);
        correl_reflected = get_dsss_correlation (opt, delay_replica3, doppler_reflected);
        phasor_reflected_post = bsxfun(@times, phasor_reflected_pre, correl_reflected);
        phasor_reflected_post_net = sum(phasor_reflected_post, 2);  % sum over all reflections.
    end
    phasor_replica = phasor_direct_post + phasor_reflected_post_net;
    %phasor_replica = phasor_direct_post + phasor_reflected_post;  % WRONG!
    %%DEBUG:
    %phasor_replica_old = evalin('caller', 'phasor_replica_old');
    %phasor_replica = phasor_replica ./ get_phase_inv(get_phase(phasor_replica_old));
end

function delay = get_dsss_discriminator (opt, ...
phasor_direct_pre, phasor_reflected_pre, ...
delay_reflected, doppler_reflected, ...
delay_replica)
    %phasor_replica_old = evalin('caller', 'phasor_replica_old');  % DEBUG
    if isfieldempty(opt, 'discriminator_type')
        opt.discriminator_type = '1';
    end
    if isfieldempty(opt, 'discriminator_normalized')
        opt.discriminator_normalized = true;
    end
    if isfieldempty(opt, 'correlator_spacing_in_chips')
        opt.correlator_spacing_in_chips = 1;
    end
    if (opt.correlator_spacing_in_chips > 1)
        warning('snr:snr_fwd_dsss:CorrSpTooLarge', ...
            ['Correlator spacing too large; it should be given '...
             'in multiples of dsss chip length, NOT in meters.']);
    end
    
    correlator_spacing_in_chips = opt.correlator_spacing_in_chips;
    correlator_spacing = correlator_spacing_in_chips * opt.chip_width;
%     function answer = correlator (sign, f)
%         if (nargin < 2),  f = @(x) x;  end
%         answer = get_dsss_correlation_composite (opt, ...
%             f(phasor_direct_pre), f(phasor_reflected_pre), ...
%             delay_reflected, doppler_reflected, ...
%             delay_replica, sign * correlator_spacing / 2);
%         % (correlator spacing is twice the early-prompt or late-prompt separation.)
%     end
    correlator2 = @(sign, f) get_dsss_correlation_composite (opt, ...
        f(phasor_direct_pre), f(phasor_reflected_pre), ...
        delay_reflected, doppler_reflected, ...
        delay_replica, sign * correlator_spacing / 2);
      % (correlator spacing is twice the early-prompt or late-prompt separation.)
    correlator = @(sign, varargin) iiff(nargin < 2, ...
        @()correlator2(sign, @itself), @()correlator2(sign, varargin{:}));
    
    if any(strcmpi(opt.discriminator_type, ...
    {'coherent dot product', 'simplified coherent'}))
        % no need to calculate imaginary components:
        phasor_early  = correlator(-1, @(x) real(x));
        phasor_late   = correlator(+1, @(x) real(x));
    else
        phasor_early  = correlator(-1);
        phasor_late   = correlator(+1);
    end
    
    % (notation and nomenclature as in Kaplan, Table 5.5, p.174.)
    %opt.discriminator_type = 1;  % DEBUG
    if ~ischar(opt.discriminator_type)
        opt.discriminator_type = num2str(opt.discriminator_type);
    end
    switch lower(opt.discriminator_type)
    case {'1', 'non-coherent early minus late envelope', 'early minus late envelope'}
        E = abs(phasor_early);
        L = abs(phasor_late);
        if opt.discriminator_normalized
            delay_in_chips = (1/2) * (E - L) ./ (E + L);
        else
            delay_in_chips = (1/2) * (E - L);
        end
    case {'2', 'non-coherent early minus late power', 'early minus late power'}
        E2 = get_power(phasor_early);
        L2 = get_power(phasor_late);
        if opt.discriminator_normalized
            %delay_in_chips = (1/2) * (E2 - L2) ./ (E2 + L2);  % WRONG!
            delay_in_chips = (1/4) * (E2 - L2) ./ (E2 + L2);
            % the 1/4 factor is necessary is case 2 is to agree with case 1.
            % neither 1/2 nor 1/4 is given in Kaplan, Table 5.5, p.174, but
            % 1/4 appears in entries of other normalized discriminators.
        else
            delay_in_chips = (1/2) * (E2 - L2);
        end
    case {'3', 'quasi-coherent dot product power', 'quasi-coherent'}
        phasor_prompt = correlator(0);
        IE = real(phasor_early);
        IL = real(phasor_late);
        IP = real(phasor_prompt);
        QE = imag(phasor_early);
        QL = imag(phasor_late);
        QP = imag(phasor_prompt);
        if opt.discriminator_normalized
            %delay_in_chips = (1/4) * ( (IE - IL) ./ IP + (QE - QL) ./ QP );
            % avoid division by zero:
            delay_in_chips = (1/4) * ( (IE - IL) ./ (IP+eps()) + (QE - QL) ./ (QP+eps()) );
        else
            %delay_in_chips = (1/4) * ( (IE - IL) .* IP + (QE - QL) .* QP );  % WRONG!
            delay_in_chips = (1/2) * ( (IE - IL) .* IP + (QE - QL) .* QP );
        end
    case {'4', 'coherent dot product', 'coherent'}
        phasor_prompt = correlator(0, @(x) real(x));
        IE = real(phasor_early);
        IL = real(phasor_late);
        IP = real(phasor_prompt);
        if opt.discriminator_normalized
            delay_in_chips = (1/4) * (IE - IL) ./ IP;
        else
            delay_in_chips = (1/2) * (IE - IL) .* IP;
        end
    case {'5', 'simplified coherent'}
        IE = phasor_early;
        IL = phasor_late;
        delay_in_chips = (1/2) * (IE - IL);
    otherwise
        error('snr:snr_fwd_dsss:unkDiscr', 'Unknown discrminator type "%s".', ...
            opt.discriminator_type);
    end
    
    delay = delay_in_chips .* opt.chip_width;
end

%!#test
%! % TODO: more than one reflected signal.

%!shared
%! doppler_reflected = [];

%!test
%! % test discriminator function in the absence of reflections.
%! % check against Kaplan, Fig. 5.14, p.175.
%! % They all agree, both inside and outside 0.5 chip, except for the 
%! % quasi-coherent dot product power discriminator, which is mirrored along
%! % the main diagonal.
%! 
%! discriminator_type = {...
%!   'non-coherent early minus late envelope'
%!   'coherent dot product'
%!   'quasi-coherent dot product power'
%!   'non-coherent early minus late power'
%! };
%! discriminator_normalized = [...
%!   true
%!   true
%!   true
%!   false
%! ];
%! symbol = {...
%!   'd-'
%!   '^-'
%!   'o-'
%!   's-'
%! };
%! order = [...
%!   4
%!   3
%!   2
%!   1
%! ];
%! 
%! opt = struct();
%! opt.correlator_spacing_in_chips = 1;
%! opt.frontend_bandwidth = Inf;
%! opt.chip_width = 1;
%! opt.iterate = false;  % CRITICAL!
%! opt.plotit = false;
%! 
%! phasor_direct_pre = 1;
%! %phasor_direct_pre = 1*exp(1i*pi);
%! phasor_reflected_pre = 0;
%! temp = linspace(-1.5*opt.chip_width, +1.5*opt.chip_width, 50)';
%! %delay_reflected = temp;  % WRONG!
%! delay_reflected = 0;
%! delay_replica = temp;
%! 
%! for i=1:numel(discriminator_type)
%!   opt.discriminator_type = discriminator_type{i};
%!   opt.discriminator_normalized = discriminator_normalized(i);
%!   [ignore, ignore, delay_update{i}] = snr_fwd_dsss (...
%!     opt, phasor_direct_pre, phasor_reflected_pre, delay_reflected, doppler_reflected, delay_replica);
%! end
%! 
%! h = [];
%! figure
%!   hold on
%!   for i=1:numel(discriminator_type)
%!     h(i)=plot(delay_replica./opt.chip_width, delay_update{i}./opt.chip_width, ...
%!       symbol{i}, 'Color','k', 'LineWidth',1, 'MarkerFaceColor','none');
%!     %pause  % DEBUG
%!   end
%!   xlim([-1,+1]*1.5)
%!   ylim([-1,+1]*1.5)
%!   xlabel('Replica delay (# chips)')
%!   ylabel('Discriminator output (# chips)')
%!   set(gca, 'XTick',-1.5:0.5:+1.5)
%!   set(gca, 'YTick',-1.5:0.5:+1.5)
%!   grid on
%!   maximize(gcf)
%!   temp = {'unnormalized ', 'normalized '};
%!   temp = strcat(temp(1+discriminator_normalized(:))', discriminator_type);
%!   legend(h(order), temp(order))
%! %error('stop!')  % DEBUG
%! %keyboard  % DEBUG

%!test
%! % test discriminator function in the absence of reflections.
%! % check against Borre, Akos, et al., Fig.7.15, p.100.
%! % They all agree, inside and outside +/- 0.5 chip.
%! discriminator_type = {...
%!   'simplified coherent'
%!   'non-coherent early minus late power'
%!   'non-coherent early minus late power'
%!   ...%'coherent dot product'
%!   'quasi-coherent dot product power'
%!   ...%'simplified coherent'
%! };
%! discriminator_normalized = [...
%!   false
%!   false
%!   true
%!   false
%! ];
%! % these factors are utilized in Borre et al., file figure_7_dll.m in the
%! % DVD accompanying the book.
%! factor = [...
%!   -2
%!   -2
%!   -4
%!   -2
%! ];
%! symbol = {...
%!   '-'
%!   '--'
%!   '-.'
%!   ':'
%! };
%! order = [...
%!   4
%!   3
%!   2
%!   1
%! ];
%! 
%! opt = struct();
%! opt.frontend_bandwidth = Inf;
%! opt.chip_width = get_gps_dsss_sizes('C/A');
%! opt.iterate = false;  % CRITICAL!
%! opt.plotit = false;
%! opt.correlator_spacing_in_chips = 1;
%! 
%! phasor_direct_pre    = 1;
%! phasor_reflected_pre = 0;
%! 
%! delay_reflected = 0;
%! delay_replica = linspace(-1.5,+1.5,100)' * opt.chip_width;
%! 
%! for i=1:numel(discriminator_type)
%!   opt.discriminator_type = discriminator_type{i};
%!   opt.discriminator_normalized = discriminator_normalized(i);
%!   [ignore, ignore, delay_update{i}] = snr_fwd_dsss (...
%!     opt, phasor_direct_pre, phasor_reflected_pre, delay_reflected, doppler_reflected, delay_replica);
%!   % snr_fwd_dsss doesn't return the discriminator output, rather that 
%!   % applied to correct the a priori delay:
%! end
%! 
%! figure
%! hold on
%! for i=1:numel(discriminator_type)
%!   h(i) = plot(delay_replica./opt.chip_width, factor(i)*delay_update{i}./opt.chip_width, ...
%!     symbol{i}, 'Color','k', 'LineWidth',3);
%!   %pause  % DEBUG
%! end
%! xlabel('Replica delay (# chips)')
%! ylabel('Discriminator output (# chips)')
%! grid on
%! ylim([-1.1,+1.1])
%! maximize(gcf)
%! temp = {'unnormalized ', 'normalized '};
%! temp = strcat(temp(1+discriminator_normalized(:))', discriminator_type);
%! legend(h(order), temp(order))
%! %error('stop!')  % DEBUG
%! %keyboard  % DEBUG

%!test
%! % Code error envelopes
%! % check against Borre, Akos et al., Fig. 7.17, p.103.
%! % 
%! % This is a significant test because we do not use their specialized 
%! % equations for dsss error envelopes, i.e., for dsss error at phase
%! % 0 and 180 degrees. Rather, we run the generic discriminator dsss, 
%! % iteratively until convergence.
%! 
%! correlator_spacing_in_chips = [1.0, 0.5, 0.1];
%! %correlator_spacing_in_chips = [1.0];  DEBUG
%! simple = true;  % DEBUG
%! simple = false;  % DEBUG
%! if simple
%!   discriminator_type = {...
%!     'non-coherent early minus late envelope'
%!     ...%'non-coherent early minus late power'
%!     ...%'quasi-coherent dot product power'
%!     ...%'coherent dot product'
%!     ...%'simplified coherent'
%!   };
%!   discriminator_normalized = [...
%!     false
%!   ];
%! else
%!   discriminator_type = {...
%!     'non-coherent early minus late envelope'
%!     'non-coherent early minus late power'
%!     'quasi-coherent dot product power'
%!     'coherent dot product'
%!     'simplified coherent'
%!   };
%!   discriminator_normalized = [...
%!     false
%!     true;  false
%!     false
%!     false
%!     false
%!   ];
%! end
%! 
%! opt = struct();
%! opt.frontend_bandwidth = Inf;
%! opt.chip_width = get_gps_dsss_sizes('C/A');
%! opt.iterate = false;  % WRONG!!!
%! opt.iterate = true;  % CRITICAL!!!
%! opt.plotit = true;
%! opt.plotit = false;
%! 
%! amplitude_direct = 1;
%! phase_direct = 0;
%! amplitude_reflected = 0.5 * amplitude_direct;
%! delay_reflected = linspace(0, 500)';
%! %phase_reflected = 360 * delay_reflected ./ get_gps_const('L1', 'wavelength');  % WRONG!
%! phase_reflected_in   = phase_direct + 0;  % IN-PHASE
%! phase_reflected_out  = phase_direct + 180;  % OUT-OF-PHASE
%! %phase_reflected_in   = phase_direct + 45;  % EXPERIMENTAL
%! 
%! phasor_direct_pre        = phasor_init(amplitude_direct,    phase_direct);
%! phasor_reflected_in  = phasor_init(amplitude_reflected, phase_reflected_in);
%! phasor_reflected_out = phasor_init(amplitude_reflected, phase_reflected_out);
%! 
%! show_steps = true;
%! show_steps = false;
%! for j=1:numel(discriminator_type)
%!   opt.discriminator_type = discriminator_type{j};
%!   opt.discriminator_normalized = discriminator_normalized(j);
%! for i=1:numel(correlator_spacing_in_chips)
%!   opt.correlator_spacing_in_chips = correlator_spacing_in_chips(i);
%!   if show_steps,  opt.plotit = true;  end
%!   delay_replica_in{i,j}  = snr_fwd_dsss (opt, phasor_direct_pre, phasor_reflected_in,  delay_reflected);
%!   if show_steps,  opt.plotit = false;  end
%!   delay_replica_out{i,j} = snr_fwd_dsss (opt, phasor_direct_pre, phasor_reflected_out, delay_reflected);
%!   if show_steps,  pause;  end
%! end
%! end
%! 
%! for j=1:numel(discriminator_type)
%! figure
%!   hold on
%!   for i=1:numel(correlator_spacing_in_chips)
%!     plot(delay_reflected, delay_replica_in{i,j},  '-k', 'LineWidth',2, 'MarkerFaceColor','k');
%!     plot(delay_reflected, delay_replica_out{i,j}, '-k', 'LineWidth',2, 'MarkerFaceColor','k');
%!     %pause  % DEBUG
%!   end
%!   xlim([0, 500])
%!   ylim([-80, +80])
%!   xlabel('Reflected delay (m)')
%!   ylabel('Replica delay (m)')
%!   grid on
%!   maximize(gcf)
%!   title(discriminator_type{j}, 'Interpreter','none')
%! end
%! %error('stop!')  % DEBUG
%! %keyboard  % DEBUG

%! % TODO: test discriminator function in the absence of reflections and 
%! %       in the presence of a non-zero phase tracking error.
%! % TODO: implement & test finite bandwidth against Kaplan, Fig. 6.13 & 6.14, p.290-291.
%! % TODO: make unnormalized and coherent cases work, by tracking carrier too.

