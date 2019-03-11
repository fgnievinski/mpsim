% (this is just an interface)
function varargout = mydategps (epoch)
    switch nargout
    case {0, 1}
        [~, sow] = mydategpsw (epoch);
        varargout = {sow};
    case 2
        [week, sow] = mydategpsw (epoch);
        varargout = {week, sow};
    case 3
        [week, dow, sod] = mydategpsw (epoch);
        varargout = {week, dow, sod};
    end
end
