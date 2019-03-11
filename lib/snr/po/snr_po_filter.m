function answers = snr_po_filter (answers, fresnel_zone_cutoff, filter_shape, nulify_invalid)
    if (nargin < 2),  fresnel_zone_cutoff = [];  end    
    if (nargin < 3),  filter_shape = [];  end    
    if (nargin < 4),  nulify_invalid = [];  end    
    for i=1:numel(answers)
        answer = answers(i);
        answer.info.kernel = snr_po_filter_kernel (...
            answer, fresnel_zone_cutoff, filter_shape);
        answer.map.mphasor = snr_po_filter_aux (...
            answer.map.phasor, answer.info.kernel, nulify_invalid);
        answer.map.cmphasor = snr_po_accum (answer.map.mphasor, ...
            answer.map.ind_delay, answer.map.ind_delay_inv, answer.map.contiguous);
        answers(i) = answer;
    end
end

function kernel = snr_po_filter_kernel (answer, fresnel_zone_cutoff, shape)
    if (nargin < 2) || isempty(fresnel_zone_cutoff),  fresnel_zone_cutoff = 2;  end
    if (nargin < 3) || isempty(shape),  shape = 'ellipse';  end    
    
    temp = get_fresnel_zone(answer.info.height_ant, ...
        answer.info.elev, answer.info.azim, answer.info.wavelength, fresnel_zone_cutoff);
    radius_nominal = [temp.a temp.b]; %#ok<NASGU>

    idx = (answer.map.fresnel_zone <= fresnel_zone_cutoff);
    %idx = bwmorph(idx, 'thicken');
    switch lower(shape)
    case {'disk','gaussian'}
        radius = 1/2*max(max(get_dist([answer.map.x(idx), answer.map.y(idx)])));
    case 'ellipse'
        temp = regionprops(idx, {'MajorAxisLength', 'MinorAxisLength','Orientation'});
        radius = 1/2*[temp.MajorAxisLength temp.MinorAxisLength] .* answer.info.step;
        bearing = -90 - temp.Orientation;
    case 'ellipse-diff'
        temp1 = get_fresnel_zone(answer.info.height_ant, ...
            answer.info.elev, answer.info.azim, answer.info.wavelength, 1);
        temp1 = [temp1.a temp1.b];
        temp2 = get_fresnel_zone(answer.info.height_ant, ...
            answer.info.elev, answer.info.azim, answer.info.wavelength, 2);
        temp2 = [temp2.a temp2.b];
        radius = 2*(temp2 - temp1);
        bearing = 0;
    otherwise
        error('SNR:snr_po_filter:unkFilterType', ...
            'Unknown filter type "%s" (should be "disk" or "ellipse").', shape);
    end
    %disp([radius; radius_nominal; (radius_nominal - radius); answer.info.step([1 max(1,end)])])
        
    radius_in_pixels = radius ./ answer.info.step;
    switch lower(shape)
    case 'disk'
        kernel = fspecial('disk', radius_in_pixels);
    case 'gaussian'
        kernel = fspecial('gaussian', round(radius_in_pixels*10), radius_in_pixels);
    case {'ellipse','ellipse-diff'}
        kernel = fspecial3('ellipsoid', [radius_in_pixels 1]);
    end
    
    %if (abs(azimuth) > 10)
    if any(strcmpi(shape, {'ellipse','ellipse-diff'})) ...
    && (min(abs(azimuth_diff(bearing, [0, 180]))) > 10)
        %min(abs(azimuth_diff(bearing, [0, 180])))  % DEBUG
        warning('SNR:snr_po_filter:azimNotZero', ...
            'Non-zero azimuth not supported.');
    end
    %TODO: rotate kernel (hint: it'll be larger).
end

function out = snr_po_filter_aux (in, kernel, nulify_invalid)
    if (nargin < 3) || isempty(nulify_invalid),  nulify_invalid = true;  end    
    out = filter2(kernel, in, 'same');
    if ~nulify_invalid,  return;  end
    if all(size(in) > size(kernel))
        out(get_border_ind(in, ceil(max(size(kernel))/2))) = NaN;
    else
        out = [];
    end
end
