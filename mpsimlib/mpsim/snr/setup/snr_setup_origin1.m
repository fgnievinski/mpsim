function ref = snr_setup_origin1 (...
dist_arp_pivot, ignore_vec_apc_arp, vec_apc_arp_upright, ant_rot)
    if (nargin < 1) || isempty(dist_arp_pivot),  dist_arp_pivot = 0;  end
    if (nargin < 2) || isempty(ignore_vec_apc_arp),  ignore_vec_apc_arp = false;  end
    if (nargin < 3) || isempty(vec_apc_arp_upright),  vec_apc_arp_upright = [0 0 0];  end
    if (nargin < 4) || isempty(ant_rot),  ant_rot = eye(3);  end
    if ignore_vec_apc_arp && ~isequal(vec_apc_arp_upright, [0 0 0])
        %warning('snr:snr_setup_origin:IgnoreVecApcArp', ...
        %    'Ignoring non-zero offset vector between APC and ARP.');
        vec_apc_arp_upright = [0 0 0];
    end    
    vec_arp_pivot_upright = [0 0 dist_arp_pivot];
    vec_apc_pivot_upright = vec_apc_arp_upright + vec_arp_pivot_upright;
    ref = struct();
    ref.vec_apc_pivot = (ant_rot * vec_apc_pivot_upright(:)).';
    ref.vec_arp_pivot = (ant_rot * vec_arp_pivot_upright(:)).';
end

