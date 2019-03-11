function ind = sub2ind_vec (siz, subvecnum)
    ind = sub2ind_cell (siz, num2cell(subvecnum));
end

