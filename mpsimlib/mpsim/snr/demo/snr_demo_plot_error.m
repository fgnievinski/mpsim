% (this is just an interface)
function varargout = snr_demo_plot_error (result)
    [varargout{1:nargout}] = snr_fwd_plot_error (result, [], @plotsin);
end

