% number of duplicates for a complete set.
function cnt2 = unique2b (group, group_all)
    myassert (isvector(group));
    myassert (isvector(group_all));
    myassert (issorted(group_all));
    [group_present, cnt] = unique2 (group);
    
    [is_present, loc] = ismember (group_all, group_present);
    %[is_present, loc] = ismember (group_present, group_all);  $ WRONG!
    
    if all(is_present)
        cnt2 = cnt;
        return;
    end
    
    cnt2 = zeros(size(group_all));
    loc_present = loc(is_present);
    cnt2(is_present) = cnt(loc_present);
end

%!test
%! A = [1 1 5 6 2 3 3 9 8 6 2 4];
%! cnt = unique2b (A, 1:9);
%! myassert (cnt, [2 2 2 1 1 2 0 1 1]);
