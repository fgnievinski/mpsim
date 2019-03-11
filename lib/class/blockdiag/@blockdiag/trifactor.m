function [Q, opt] = trifactor (A, opt)
    if (nargin < 2),  opt = [];  end
    [Q, opt] = cellfun(@(a) trifactor (a, opt), diag(cell(A)), ...
        'UniformOutput', false);
    Q = blockdiag(Q);
    if ~all(cellfun(@(o) isequal(o, opt{end}), opt))
        error('blockdiag:trifactor', ...
            'Blocks of different trifactor opt not supported.');
        % If you change this, you shall update tricond, trisolve, triinv.
    end
    opt = opt{end};
end
