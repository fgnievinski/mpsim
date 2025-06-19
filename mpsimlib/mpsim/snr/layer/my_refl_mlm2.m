function [H_rc,V_rc] = my_refl_mlm2 (thickness,eps,fr,angle)
    % As per original refl_mlm: "We start from the bottom[most] layer 1"
    thickness = flipud(thickness);
    eps = flipud(eps(:));
    [H_rc,V_rc] = refl_mlm2(thickness,eps,fr,angle);
end
