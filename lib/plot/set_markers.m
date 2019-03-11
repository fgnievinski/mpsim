function set_markers (h)
    markers = {...
        '+'
        'o'
        '*'
        '.'
        'x'
        's'
        'd'
        '^'
        'v'
        '>'
        '<'
        'p'
        'h'
    };
    for i=1:length(h)
        j = mod(i-1, length(markers)) + 1;
        set(h(i), 'Marker',markers{i});
    end
end

