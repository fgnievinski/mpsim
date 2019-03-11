function J = cedgetaper (I, PSF)
    if isreal(I)
        J = edgetaper(I, PSF);
    else
        J = complex(...
          edgetaper(real(I), PSF), ...
          edgetaper(imag(I), PSF)  ...
        );
    end
end
