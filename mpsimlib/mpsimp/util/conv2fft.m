function [out, Xfft] = conv2fft (h, X, shape, Xfft, get_pow2)
    %if (nargin < 3) || isempty(shape),  shape = 'same';  end  % WRONG!
    if (nargin < 3) || isempty(shape),  shape = 'full';  end
    if (nargin < 4) || isempty(get_pow2),  get_pow2 = false;  end
    if ~any(strcmp(shape, {'same', 'full', 'valid'}))
        error('MATLAB:conv2fft:InvalidParam', 'Unknown shape parameter.'); 
    end
    siz_h = size(h);
    siz_X = size(X);
    siz = siz_h + siz_X - 1;
    siz2 = siz;
    if get_pow2
        %siz2 = pow2(nextpow2(siz));  % WRONG!
        siz2(1) = pow2(nextpow2(siz(1)));
        siz2(2) = pow2(nextpow2(siz(2)));
    end
    if (nargin < 4) || isempty(Xfft)
        Xfft = fft2(X, siz2(1), siz2(2));
    else
        if ~isequal(size(Xfft), siz2)
            error('MATLAB:conv2fft:badSize', ...
                'Fourth argument must be of size %d-by-%d.', ...
                siz2(1), siz2(2));
        end
    end
    hfft = fft2(h, siz2(1), siz2(2));
    out = hfft .* Xfft;
    out = ifft2(out);
    %out = ifft2(out, siz(1), siz(2));  % doesn't seem to speed up.
    switch shape
    case 'full'
        ind1 = 1:siz(1);
        ind2 = 1:siz(2);
    case 'same'
        ind1 = (1:siz_X(1)) + ceil((siz_h(1)-1)/2);
        ind2 = (1:siz_X(2)) + ceil((siz_h(2)-1)/2);
    case 'valid'
        ind1 = siz_h(1):siz_X(1);
        ind2 = siz_h(2):siz_X(2);
    end
    out = out(ind1,ind2);
end

%!test
%! % conv2fft()
%! test('filter2fft');

