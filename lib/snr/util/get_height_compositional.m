% return compositional height:
function [height_compos, phase_compos, vertwavenum] = get_height_compositional (varargin)
% Usage 1: get_height_compositional (phase_compos, elev, wavelen)
% Usage 2: get_height_compositional (result, setup)

  switch nargin
  case 3
      [phase_compos, elev, wavelen] = deal(varargin{:});
  case 2
      [result, setup] = deal(varargin{:});
      if ~isfield(result, 'phase_compos')
          result.phase_compos = get_phase_compositional (result);
      end
      phase_compos = result.phase_compos;
      elev = result.sat.elev;
      wavelen = setup.opt.wavelength;
  case 1
      error('MATLAB:maxrhs', 'Not enough input arguments.');
  otherwise
      error('MATLAB:maxrhs', 'Too many input arguments.');
  end
  
  [height_compos, vertwavenum] = get_height_from_phase (phase_compos, elev, wavelen);
end
