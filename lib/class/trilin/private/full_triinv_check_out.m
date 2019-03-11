function s = full_triinv_check_out (info, func)
    if (info == 0)
        s = [];
    elseif (info < 0)
        s.identifier = sprintf('trilin:%s:badInput', prefix);
        s.message = sprintf(...
            'Error calling LAPACK routine "%s", internal input parameter #%d.', func, -info);
    elseif (info > 0)
        s.identifier = 'trilin:triinv:badFactor';
        s.message = sprintf(...
            'Inverse could not be computed -- (%d,%d) element of the factor is zero.', info, info);
    end    
end

