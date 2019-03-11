function [phase_bias, delay_bias, height_bias] = snr_bias_height_eval (coeff, indep, wavelength, graz, varargin)
    height_bias = snr_bias_poly_eval (coeff, indep, varargin{:});
    if isequal(height_bias, 0)  % (return scalar if possible)
        phase_bias = 0;
        delay_bias = 0;
        return;
    end
    delay_bias = 2 * height_bias .* sind(graz);
    phase_bias = delay2phase (delay_bias, wavelength);
%     if (nargin > 3) && ~isempty(sfc) && ~iscell(sfc) && ~(...
%        isequal(sfc.fnc_snr_setup_sfc_geometry, @snr_setup_sfc_geometry_horiz) ...
%     ...%||(isequal(sfc.fnc_snr_setup_sfc_geometry, @snr_setup_sfc_geometry_tilted) && sfc.slope == 0)  % WRONG! let it warn.
%     )
%         warning('snr:bias:heightNonHoriz', ...
%             ['Applying locally horizontal approximation to non-horizontal surface; \n' ...
%              'consider using "sett.ref.height_off" instead of "sett.bias.height".']);
%     end
end

