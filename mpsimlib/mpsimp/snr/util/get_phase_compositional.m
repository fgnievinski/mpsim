% return compositional phase component
% see also: get_height_compositional.
function phase_compos = get_phase_compositional (varargin)
% Usage 1:  get_phase_compositional (result)
% Usage 2:  get_phase_compositional (phasor_interf, phasor_delay)
% Usage 3a: get_phase_compositional (result, [], unwrapit)
% Usage 3b: get_phase_compositional (phasor_interf, phasor_delay, unwrapit)

  switch nargin
  case 1
    result = varargin{1};
    unwrapit = [];
  case 2
    result = struct();
    result.phasor_interf = varargin{1};
    result.reflected.phasor_delay = varargin{2};
    unwrapit = [];
  case 3
    unwrapit = varargin{3};
    if isempty(varargin{2})
      result = varargin{1};
    else
      result = struct();
      result.phasor_interf = varargin{1};
      result.reflected.phasor_delay = varargin{2};
    end
  end
  phase_compos = get_phase_compositional_aux (result, unwrapit);
end

%%
function phase_compos = get_phase_compositional_aux (result, unwrapit)
  if isempty(unwrapit),  unwrapit = true;  end
  %phase_interf = unwrapd(get_phase(result.phasor_interf));
  %phase_geom   = unwrapd(get_phase(result.reflected.phasor_delay));
  %phase_compos = phase_interf - phase_geom;
  % more reliable:
  if isfield(result.reflected, 'phasor_nongeom')
    phase_compos = get_phase(result.reflected.phasor_nongeom);
  else
    phase_compos = get_phase(result.phasor_interf./result.reflected.phasor_delay);
  end
  if ~unwrapit,  return;  end
  phase_compos = unwrapd(phase_compos);
end
