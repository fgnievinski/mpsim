function [phasor_direct, phasor_reflected, delay_reflected, doppler_reflected, geom, extra] = ...
snr_fwd_direct_and_reflected (setup)
    N = [];
    %N = 2;  % EXPERIMENTAL!!!
    if ~isempty(N)
        warning('snr:fwd:expOn', 'Experimental feature turned on!');
        setup.opt.num_specular_max = N;
    end
    
    geom = snr_fwd_geometry (setup);

    incident = snr_fwd_incident (geom, setup);

    [phasor_direct, extra_direct] = snr_fwd_direct (incident, geom, setup);
        
    temp = NaN(geom.num_dirs, geom.num_reflections);
    phasor_reflected  = temp;
    delay_reflected   = temp;
    doppler_reflected = temp;
    visible_reflected = temp;
    for i=1:geom.num_reflections
        geom.reflection = geom.reflections(i);
        [phasor_reflected(:,i), extra_reflected(i)] = snr_fwd_reflected (...
            incident, geom, setup); %#ok<AGROW>
        delay_reflected(:,i)   = geom.reflection.delay;
        doppler_reflected(:,i) = geom.reflection.doppler;
        visible_reflected(:,i) = geom.reflection.visible;
    end
    if (geom.num_reflections > 1),  geom = rmfield(geom, 'reflection');  end
    %if ~isempty(N),  phasor_reflected = phasor_reflected./N;  end  

    if ~setup.opt.disable_visibility_test
        %phasor_reflected(~visible_reflected) = NaN;  % WRONG!
        phasor_reflected(~visible_reflected) = 0;  % allow for partial visibility.
        temp = visible_reflected;
        if ~isempty(geom.direct.visible)
            phasor_direct(~geom.direct.visible) = 0;
            temp = bsxfun(@and, visible_reflected, geom.direct.visible);
        end
        visible_any = any(temp, 2);
        phasor_direct(~visible_any) = NaN;  % disable completely invisible dir.
    end
    
    extra = struct();
    extra.direct    = extra_direct;
    extra.reflected = extra_reflected;
    extra.incident  = incident;
    
    %dbstack()  % DEBUG
    %disp(mfilename())  % DEBUG
end

