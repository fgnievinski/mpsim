function out = sum (A, dim)
    if (nargin < 2),  dim = 1;  end
    D = diag(cell(A));
    out = cellfun(@(d) sum(d, dim), D, 'UniformOutput',false);
    if (dim == 1)
        out = cell2mat(out(:)');
    elseif (dim == 2)
        out = cell2mat(out(:));
    end
end

