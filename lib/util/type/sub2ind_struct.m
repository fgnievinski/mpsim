function ind = sub2ind_struct (siz, substruct, fn)
    ind = sub2ind_cell(siz, struct2cell(getfields(substruct, fn)));
end
