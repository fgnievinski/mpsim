function out = frontal_reshape (in, varargin)
    if isempty(in)
        out = reshape(in, varargin{:});
        return;
    end
    [m_in, n_in, o] = size(in);
    % let matlab's reshape deal with input format:
    [m_out, n_out] = size(reshape(in(:,:,1), varargin{:}));
    out = reshape(in, [m_out, n_out, o]);
end

%!test
%! o = ceil(10*rand);
%! m_in = 2 * ceil(10*rand);
%! n_in = ceil(10*rand);
%! m_out = m_in / 2;
%! n_out = m_in * n_in / m_out;
%! in = rand(m_in,n_in,o);
%! out = zeros(m_out,n_out,o);
%! for k=1:o
%!     out(:,:,k) = reshape(in(:,:,k), m_out, n_out);
%! end
%! out2 = frontal_reshape(in, m_out, n_out);
%! out3 = frontal_reshape(in, [m_out, n_out]);
%! out4 = frontal_reshape(in, m_out, []);
%! out5 = frontal_reshape(in, [], n_out);
%! %out, out2, out2-out  % DEBUG
%! %out, out3, out3-out  % DEBUG
%! myassert(out2, out);
%! myassert(out3, out);
%! myassert(out4, out);
%! myassert(out5, out);

