function A = trifull (A, opt)
    if issparse (A),  return;  end

    if ~isfield(opt, 'type') || isempty(opt.type)
        error ('trilin:tricond:missingType', ...
            'Missing matrix type.');
    end    
    switch opt.type(1)
    case 'd'  % diagonal
        A = diag (A);
    case 't'  % triangular
        A = triuplow (A, opt.uplow);
    case 'p'  % positive-definite
        A = makeitsymm (A, opt.uplow);
    case 's'  % symmetric indefinite
        A = makeitsymm (A, opt.uplow);
    case 'g'  % general
        A = A;
    otherwise
        error ('trilin:triinv:unknownOpt', ...
            'Unknown opt.type (%s).', opt.type);
    end
end

