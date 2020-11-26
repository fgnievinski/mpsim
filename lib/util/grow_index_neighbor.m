function idx2 = grow_index_neighbor (idx)
  assert(isvector(idx))
  siz = size(idx);
  n = prod(siz);
  ind = find(idx);
  ind = ind(:);
  inda = ind+1;
  indb = ind-1;
  inda = min(inda, n);
  indb = max(indb, 1);
  ind2 = [ind; inda; indb];
  idx2 = false(siz);
  idx2(ind2) = true;
end

%!test
%! idx = [1 0 0 0 1 0 0];
%! idx2 = [1 1 0 1 1 1 0];
%! idx2b = grow_index_neighbor (idx);
%! myassert(idx2, idx2b);
