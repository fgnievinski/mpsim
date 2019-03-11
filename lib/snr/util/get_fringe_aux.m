function [phasor_reflected, phasor_composite] = get_fringe_aux (...
phasor_direct, phasor_reflected, special_fringes)
    if isempty(special_fringes) || strcmpi(special_fringes, 'common')
        return;
    end
    
    switch special_fringes
    case {'sup','superior','max','maximum'}
        phase_interf = 0;  % such that cos(phi_i)=1.
    case {'disable','disabled','trend'}
        phase_interf = 90;  % such that cos(phi_i)=0.
    case {'inf','inferior','min','minimum'}
        phase_interf = 180;  % such that cos(phi_i)=-1.
    end
    
    phase_direct = get_phase(phasor_direct);
    phase_reflected = phase_direct + phase_interf;
    phasor_reflected = phasor_init(abs(phasor_reflected), phase_reflected);
    if (nargout < 2),  return;  end
    phasor_composite = phasor_direct + phasor_reflected;
end
