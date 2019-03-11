function yi = interp1_fastest (X, Y, xi, method, extrap_input)
    if (nargin < 4) || isempty(method),  method = 'linear';  end
    if (nargin < 5) || isempty(extrap_input),  extrap_input = NaN;  end

    %if (any(isnan(X) | isnan(any(Y,2))) || any(isnan(xi)))  % WRONG!
    if (any(isnan(X) | any(isnan(Y),2)) || any(isnan(xi)))
        yi = naninterp1(X, Y, xi, method, extrap_input);
        return;
    end

    %myinterp1 = @interp1;
    myinterp1 = @interp1nonunique;  % safer        
    if ~any(strcmp(method, {'linear','*linear'})) || ~issorted(X)
        yi = myinterp1(X, Y, xi, method, extrap_input);
        return;
    end
         
    if (isempty(X) && isempty(Y))
        yi = interp1nonemptynorscalar(X, Y, xi, method, extrap_input);
        return;
    end
        
    if strcmp(extrap_input, 'extrap')
        extrapolateit = true;
        outsideval = [];
    elseif isscalar(extrap_input) && isnumeric(extrap_input)
        extrapolateit = false;
        outsideval = extrap_input;
    else
        error('interp1_fastest:badExtrap', ...
            ['Extrapolation input argument should be either a numeric '...
             'scalar value or the character string "extrap".']);
    end
    
    irs = is_regularly_spaced(X);
    if  irs && (method(1) ~= '*')
        method = ['*' method];  % take advantage of it.
    end
    if ~irs && (method(1) == '*')
        warning('interp1_fastest:notRegSpaced', ...
            'Input is not regularly spaced; ignoring "*" flag.');
        method(1) = [];
    end

    %assert(strcmp(method, 'linear') || strcmp(method, '*linear'))
    %TODO: if (numel(Y) == 2),  interp1lerp...
    if (method(1) == '*') && isvector(Y)
        X = double(X);
        Y = double(Y);
        xi = double(xi);
        yi = interp1_linear_c(X, Y(:).', xi);
        %yi = interp1_linear_c(X, Y(:).', xi);  % WRONG!
    else
        if isvector(Y),  Y = Y(:);  end
        yi = interp1q(X(:), Y, xi(:));
        %yi = lininterp1f(X, Y, xi, outsideval);  yi = reshape(yi, size(xi));
    end

    idx = any(isnan(yi),2) & ~isnan(xi);
    if ~any(idx),  return;  end
    if extrapolateit
        yi(idx,:) = myinterp1(X, Y, xi(idx), method, 'extrap');
    elseif ~isnan(outsideval)
        yi(idx,:) = outsideval;
    end
end

