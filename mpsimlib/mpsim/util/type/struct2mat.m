function mat = struct2mat (struct, fnc)
    cell = struct2cell(struct);
    if (nargin > 1),  cell = fnc(cell);  end
    mat = cell2mat(cell);
end