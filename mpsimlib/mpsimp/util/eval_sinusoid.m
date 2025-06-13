function [sinus_val, phase_val, dS_dA_val, dS_dp_val, dS_df_val] = eval_sinusoid (A, p, f, t)
    if (nargin < 3),  f = 0;  end
    if (nargin < 4),  t = 0;  end
    [sinus_fnc, phase_fnc, dS_dA_fnc, dS_dp_fnc, dS_df_fnc] = get_sinusoid ();
    Apft = {A, p, f, t};
    sinus_val = sinus_fnc(Apft{:});
    if (nargout < 2),  return;  end
    phase_val = phase_fnc(Apft{:});
    if (nargout < 3),  return;  end
    dS_dA_val = dS_dA_fnc(Apft{:});
    dS_dp_val = dS_dp_fnc(Apft{:});
    dS_df_val = dS_df_fnc(Apft{:});
end
