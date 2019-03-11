function A = reshape (A, varargin)
    A.data = frontal_reshape(A.data, varargin{:});
end
