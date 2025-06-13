function method = interp1_contin2method (contin)
    if isempty(contin),  contin = 1;  end
    switch contin
    case 0
        method = 'nearest';
    case 1
        method = 'linear';
    case 2.5
        %method = 'cubic';
        method = 'pchip';  % avoid warning 'MATLAB:interp1:UsePCHIP'
    case 3
        method = 'spline';
        %method = 'cubic';  % WRONG!
        % For the theory behind matlab's implementation, see Cleve Moler's 
        % textbook, available at <http://www.mathworks.com/moler/interp.pdf>.
    otherwise
        error('raytracer:interp1_contin2method:badInput', ...
            'Bad value for contin; should be any of 0, 1, 2.5, or 3.');
    end
end

