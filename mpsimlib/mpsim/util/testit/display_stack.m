function display_stack (s)
    if (nargin < 1),  s = dbstack();  end
    if isa(s, 'MException')
        disp(getReport(s));
        return;
    end
    if ~is_octave()
        %s2 = MException(s.identifier, s.message);
        try rethrow(s)
        catch s2
        end
        disp(getReport(s2));
        return
    end
    disp(s.message);
    if ~isfield(s, 'stack'),  return;  end
    for i=1:length(s.stack)
        disp(s.stack(i))
    end
end

