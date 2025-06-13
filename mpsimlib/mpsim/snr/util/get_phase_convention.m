function convention = get_phase_convention (convention)
    conventions = {'engineering','physics'};
    convention_default = 'physics';
    %convention_default = 'engineering';  % DEBUG
    if (nargin < 1) || isempty(convention),  convention = convention_default;  end
    if any(strcmpi(convention, conventions)),  return;  end
    error('snr:get_phase_convention:unkConvention', ...
      'Unknown convention "%s"; must be one of %s.', ...
      convention, str2list(conventions, [], [], '"'));
end
