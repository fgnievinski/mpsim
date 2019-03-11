function [H_rc,V_rc] = my_refl_mlm (thickness,eps,fr,angle)
    re_eps = real(eps);
    im_eps = imag(eps);
    
    num = numel(thickness) + 2;  % number of layers plus two half-spaces
    depth = [0; cumsum(thickness(:))];
    
    % As per original refl_mlm: "We start from the bottom[most] layer 1"
    depth = flipud(depth);
    re_eps = flipud(re_eps(:));
    im_eps = flipud(im_eps(:));
    
    [H_rc,V_rc] = refl_mlm(depth,num,re_eps,im_eps,fr,angle);
end
