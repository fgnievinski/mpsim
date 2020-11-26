function [phase_bias, delay_bias, height_bias] = snr_bias_chirp_eval (chirp_bias, indep_mid, indep, wavelength, graz, varargin)
    coeff2 = [0 chirp_bias];
    indep2 = indep - indep_mid;
    [phase_bias, delay_bias, height_bias] = snr_bias_height_eval (coeff2, indep2, wavelength, graz, varargin{:});
    %if ~isempty(chirp_bias) && (chirp_bias ~= 0),  keyboard();  end  % DEBUG
end

% function [phase_bias, delay_bias] = snr_bias_chirp_eval_old (chirp, indep_mid, indep, wavelength, ~, varargin)
%     coeff2 = [0 0 chirp];
%     indep2 = indep - indep_mid;
%     [phase_bias, delay_bias] = snr_bias_phase_eval (coeff2, indep2, wavelength, varargin{:});
% end
