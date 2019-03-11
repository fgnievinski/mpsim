function out = sum (A, dim)
    if (nargin < 2),  dim = 1;  end
    %TODO: if isvector(A)...
    out = cellfun(@(d) sum(d, dim), A.data, 'UniformOutput',false);
    out = cell2mat(out);
    out = sum(out, dim);
end

