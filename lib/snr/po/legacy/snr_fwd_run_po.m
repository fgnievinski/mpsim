% (this is just an interface)
function varargout = snr_fwd_run_po (varargin)
    [varargout{1:nargout}] = snr_po_run (varargin{:});
end

%!test
%! % snr_fwd_run_po()
%! test('snr_po_run')

