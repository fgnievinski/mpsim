function s = nargoutchk2 (a, b, c, d, e)
    s = nargoutchk(a, b, c, d);
    if ~isempty(s)
        s.identifier = strrep(s.identifier, ...
        'MATLAB:nargoutchk', e);
    end
end

