function s = full_check_out (info, func, prefix)
    s = [];
    if (info >= 0),  return;  end
    s.identifier = sprintf('trilin:%s:badInput', prefix);
    s.message = sprintf(...
        'Error calling LAPACK routine "%s", internal input parameter #%d.', ...
        func, -info);
end

