function s = nargchk2 (a, b, c, d, e)
    s = nargchk(a, b, c, d);
    if ~isempty(s)
        s.identifier = strrep(s.identifier, ...
        'MATLAB:nargchk', e);
    end
end

