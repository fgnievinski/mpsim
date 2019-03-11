function [const, units_symbol, units_name] = get_standard_constant (label)
    switch lower(label)
    case {'c0', 'c', 'light', 'speed of light', 'speed of light in vaccum'}
        const = 299792458;
        units_symbol = 'm/s';
        units_name = 'meters per second';
    case {'mu0', 'vacuum permeability', 'permeability of free space', ...
        'magnetic constant'}
        const = 4 * pi * 1e-7;
        units_symbol = 'N/A^2';
        units_name = 'newton per ampere squared';
    case {'epsilon0', 'vacuum permittivity', 'permittivity of free space', ...
        'electric constant'}
        const = 1 / ( ...
              get_standard_constant('mu0') ...
            * get_standard_constant('c0')^2 ...
        );
        units_symbol = 'F/m';
        units_name = 'farad per meter';
    case {'z0', 'impedance of free space', 'vacuum impedance'}
        const = get_standard_constant('mu0') * get_standard_constant('c0');
        units_symbol = '\Omega';
        units_name = 'ohm';
    case {'r', 'gas', 'gas constant'}
        const = 8.314472;
        units_symbol = 'J / (K mol)';
        units_name = 'joule per kelvin per mol';        
    case {'na', 'avogrado', 'avogrado constant'}
        const = 6.02214179e23;
        units_symbol = '1/mol';
        units_name = 'reciprocal of mol';
    case {'k', 'boltzmann', 'boltzmann''s', 'boltzmann''s constant', 'boltzman'}
        const = get_standard_constant('gas constant') ...
              / get_standard_constant('Avogrado constant');
        units_symbol = 'J/K';
        units_name = 'joule per kelvin';
    case {'iacs', 'copper conductivity'}
        % conductivity of the International Annealed Copper Standard:
        const = 5.8108e7;
        units_symbol = 'S/m';
        units_name = 'Siemens per meter';
    otherwise
        error('matlab:get_standard_constant:badLabel', ...
            'Unknown label "%s".', label);
    end
end

