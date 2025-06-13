function answer2 = snr_po_cross_coherence (answer, tol, step2, lim2, flt_radius, diagnose, resize_original_domain)
    if (nargin < 2) || isempty(tol),  tol = +Inf;  end
    if (nargin < 3) || isempty(step2),  step2 = answer.step;  end
    if (nargin < 4) || isempty(lim2),  lim2 = answer.lim;  end
    if (nargin < 5) || isempty(flt_radius),  flt_radius = answer.flt_radius;  end
    if (nargin < 6) || isempty(diagnose),  diagnose = false;  end
    if (nargin < 7) || isempty(resize_original_domain),  resize_original_domain = false;  end
    get_pow2 = false;
    tune_fftw = true;
    if get_pow2
        tune_fftw = false;  %#ok<UNRCH>
        % when input dimension is a power of 2 there is no potential speed up in tuning the FFTW library.    
    end
    %myfilter2 = @(h, X, shape, Xfft) filter2(h, X, shape);
    myfilter2 = @(h, X, shape, Xfft) filter2fft(h, X, shape, Xfft, get_pow2);

    %% setup domain:
    switch numel(step2)
    case 1
        x_step2 = step2;
        y_step2 = step2;
    case 2
        x_step2 = step2(1);
        y_step2 = step2(2);
    end
    switch numel(lim2)
    case 1
        x_lim2 = [-lim2,+lim2];
        y_lim2 = [-lim2,+lim2];
    case 2
        x_lim2 = [-lim2(1),+lim2(1)];
        y_lim2 = [-lim2(2),+lim2(2)];
    case 4
        x_lim2 = lim2(1:2);
        y_lim2 = lim2(3:4);
    end
    if (x_lim2(1) < answer.x_lim(1)) || (x_lim2(2) > answer.x_lim(2)) ...
    || (y_lim2(1) < answer.y_lim(1)) || (y_lim2(2) > answer.y_lim(2))
        error('snr:snr_po_cross_coherence:badLim2', ...
            'lim2 shouldn''t be greater than answer.lim');
    end
    x_domain2 = x_lim2(1):x_step2:x_lim2(2);
    y_domain2 = y_lim2(1):y_step2:y_lim2(2);
    M2 = numel(y_domain2);
    N2 = numel(x_domain2);
    i_domain2 = 1:M2;
    j_domain2 = 1:N2;
    [M,N] = size(answer.map.phasor);
    i_domain10 = 1:M;
    j_domain10 = 1:N;
    i_domain12 = interp1(answer.y_domain, i_domain10, y_domain2, 'nearest');
    j_domain12 = interp1(answer.x_domain, j_domain10, x_domain2, 'nearest');
    if ~resize_original_domain
        i_domain11 = i_domain10;
        j_domain11 = j_domain10;        
        i_domain13 = i_domain12;
        j_domain13 = j_domain12;
    else
        i_domain11 = i_domain12(1):1:i_domain12(end);
        j_domain11 = j_domain12(1):1:j_domain12(end);
        i_domain13 = i_domain12 - i_domain12(1) + 1;
        j_domain13 = j_domain12 - j_domain12(1) + 1;
    end
    x_domain11 = answer.x_domain(j_domain11);
    y_domain11 = answer.y_domain(i_domain11);
    % for use in plotit:
    answer2.map = struct('x_domain',x_domain11, 'y_domain',y_domain11);

    %% setup filter:
    %flt_radius_pixel = ceil(flt_radius/step2);  % WRONG!
    flt_radius_pixel = ceil(flt_radius/answer.step);
    flt_shape = fspecial('disk',flt_radius_pixel);
    filterit = @(in) myfilter2(flt_shape, in, 'same', []);
    
    %% prepare data:
    phasor = answer.map.phasor(i_domain11, j_domain11);
    mphasor = filterit(phasor);
    power = get_power(phasor);
    %mpower = get_power(mphasor);  % WRONG!
    mpower = filterit(power);
    mpowersqrt = sqrt(mpower);  % NOT the same as mean amplitude.
    %mampl = filterit(abs(phasor));  % unnecessary.
    phasor_conj = conj(phasor);
    answer.direct.power = get_power(answer.direct.phasor);
    answer.direct.powersqrt = sqrt(answer.direct.power);  % same as ampl.
    %answer.direct.ampl = abs(answer.direct.phasor);  % unnecessary.
    coh = filterit( answer.direct.phasor .* phasor_conj ) ...
        ./ ( answer.direct.powersqrt .* mpowersqrt );
    
    %% make a padded version of the map:
    flt_shapeb = flt_shape;
    flt_shapeb(:) = 0;
    flt_shapeb((end+1)/2,(end+1)/2) = 1;  % now it's a Dirac's delta.
    phasor_padded = myfilter2(flt_shapeb, phasor, 'full', []);
      %if diagnose
      %  plotit (answer2, @(map) get_power(phasor_padded), 'jet')
      %end

    %% pre-process convolution:
    % timing was as follows:
    % get_pow2 = false,  tune_fftw = false: 0.788 s
    % get_pow2 = true,   tune_fftw = false: 0.693 s
    % get_pow2 = false,  tune_fftw = true:  0.560 s
    fftw('planner', 'estimate');  % fftw lib will not use run-time tuning.
    phasor_conj_fft = [];
    if strfind(func2str(myfilter2), 'filter2fft')
        %[ignore, phasor_conj_fft] = filter2fft(1, phasor_conj, 'same', [], get_pow2); % WRONG!
        [ignore, phasor_conj_fft] = filter2fft(flt_shape, phasor_conj, 'same', [], get_pow2);
    end       
    if tune_fftw && ~isempty(phasor_conj_fft)
        tic
        method = 'measure';
        %method = 'exhaustive';
        fftw('planner', method);  fft(phasor_conj_fft(:,1));
        fftw('planner', method);  fft(phasor_conj_fft(1,:));
        toc
    end

    %% loop over:
    ccoh_all = cell(M2,N2);
    interfcontrib = NaN(M2,N2);
    for i2=i_domain2
    for j2=j_domain2
        %if diagnose,  fprintf('i2=%d, j2=%d\n', i2, j2);  end
        fprintf('i2=%d, j2=%d\n', i2, j2);

        %% extract region around pixel of interest:
        i3 = i_domain13(i2);
        j3 = j_domain13(j2);
        i3_lim = i3 + [-1,+1] * flt_radius_pixel;
        j3_lim = j3 + [-1,+1] * flt_radius_pixel;
        i3_domain = (i3_lim(1):i3_lim(2));
        j3_domain = (j3_lim(1):j3_lim(2));
        i4_domain = i3_domain + flt_radius_pixel;
        j4_domain = j3_domain + flt_radius_pixel;
          assert(numel(i4_domain)*numel(i4_domain) == numel(flt_shape))
        phasor_kernel = phasor_padded(i4_domain, j4_domain);

        %% calculate numerator:
        phasor_kernel = phasor_kernel .* flt_shape;  % equiv to dividing sum by number of elements
        num = myfilter2(phasor_kernel, phasor_conj, 'same', phasor_conj_fft);
          if diagnose
            plotit (answer2, @(map) get_phase(num), 'hsv')
              hold on,  plot(x_domain2(j2), y_domain2(i2), '+w','MarkerFaceColor','w', 'LineWidth',2)
            plotit (answer2, @(map) get_power(num), 'jet')
              hold on,  plot(x_domain2(j2), y_domain2(i2), '+w','MarkerFaceColor','w', 'LineWidth',2)
          end

        %% calculate denominator:
        %den = mpowersqrt(i2, j2) .* mpowersqrt;  % WRONG!
        den = mpowersqrt(i3, j3) .* mpowersqrt;
          %if diagnose
          %  plotit (answer2, @(map) den, 'jet')
          %    hold on,  plot(x_domain2(j2), y_domain2(i2), '+w','MarkerFaceColor','w', 'LineWidth',2)
          %end

        %% calculate cross coherence:
        ccoh = num ./ den;
          temp = max(abs(ccoh(:)));
            assert( temp <= (1 + sqrt(eps())) )
          temp = ccoh(i3, j3);
            assert( abs(real(temp) - 1) <= sqrt(eps()) );  % DEBUG
            assert( abs(imag(temp) - 0) <= sqrt(eps()) );  % DEBUG
          %if (tol > 0),  ccoh(get_border_ind(ccoh, flt_radius_pixel)) = 0;  end
          if diagnose
            plotit (answer2, @(map) get_phase(ccoh), 'hsv')
              hold on,  plot(x_domain2(j2), y_domain2(i2), '+w','MarkerFaceColor','w', 'LineWidth',2)
            plotit (answer2, @(map) abs(ccoh), 'jet')
              hold on,  plot(x_domain2(j2), y_domain2(i2), '+w','MarkerFaceColor','w', 'LineWidth',2)
          end
        
        %% interferometric contribution:
        interfcontrib(i2, j2) = -mpower(i3, j3) + 2 * mpowersqrt(i3, j3) * (...
            answer.direct.powersqrt * coh(i3, j3) + sum(mpowersqrt(:) .* ccoh(:)) );

        %% store only significant values:
        if isinf(tol)
            ccoh = sparse(size(ccoh));
        elseif (tol > 0)
            %ccoh(ccoh < tol) = 0;  % WRONG!
            ccoh(abs(ccoh) < tol) = 0;
            ccoh = sparse(ccoh);
            if diagnose
              fprintf('%.1f%%\n', 100*nnz(ccoh)/numel(ccoh));
              plotit (answer2, @(map) abs(ccoh) > tol, 'jet')
                hold on,  plot(x_domain2(j2), y_domain2(i2), '+w','MarkerFaceColor','w', 'LineWidth',2)
            end
        end
        ccoh_all{i2,j2} = ccoh;
        
        if diagnose,  pause;  end
        if diagnose,  close all;  end
    end
    end
    if diagnose,  disp(roundn(cellfun(@(ccoh) 100*nnz(ccoh)/numel(ccoh), ccoh_all), -1));  end
    if diagnose
        plotit (answer2, @(map) get_phase(interfcontrib), 'hsv')
          hold on,  plot(x_domain2(j2), y_domain2(i2), '+w','MarkerFaceColor','w', 'LineWidth',2)
        plotit (answer2, @(map) abs(interfcontrib), 'jet')
          hold on,  plot(x_domain2(j2), y_domain2(i2), '+w','MarkerFaceColor','w', 'LineWidth',2)
    end
    answer2 = struct();
    answer2.ccoh_all = ccoh_all;
    answer2.map2.interfcontrib = interfcontrib;
    answer2.map2.x_domain = x_domain2;
    answer2.map2.y_domain = y_domain2;
    answer2.map.phasor = phasor;
    answer2.map.mphasor = mphasor;
    answer2.map.mpower = mpower;
    answer2.map.mpowersqrt = mpowersqrt;
    answer2.map.coh = coh;
    answer2.map.x_domain = x_domain11;
    answer2.map.y_domain = y_domain11;
    answer2.x_domain = x_domain2;
    answer2.y_domain = y_domain2;
    answer2.x_lim = x_lim2;
    answer2.y_lim = y_lim2;
    answer2.lim = lim2;
    answer2.step = step2;
end

