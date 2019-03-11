function answer = isa (inPar2, class_name) %#ok<INUSL>
    answer = any(strcmp(class_name, {'inputParser2','inputParser1'}));
end

