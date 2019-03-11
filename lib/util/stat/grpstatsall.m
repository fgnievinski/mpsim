function varargout = grpstatsall (x, group, group_all, whichstats)
  if (nargin < 4) || isempty(whichstats),  whichstats = @mean;  end
  if ~iscell(whichstats),  whichstats = {whichstats};  end
  [varargout{1:max(1,nargout)}, group_present] = grpstats (x, group, [whichstats 'gname']);
  assert(isvector(group_all))
  if ~iscell(group_all)
    group_present = unique (group, 'first');
    group_present(isnan(group_present)) = [];
  end
  [is_present, loc] = ismember (group_all, group_present);
  %[is_present, loc] = ismember (group_present, group_all);  $ WRONG!
  m = numel(group_all);
  %p = size(x,2);
  p = size(varargout{1},2);
  A_allempty = NaN(m, p);
  loc_present = loc(is_present);
    myassert(group_all(is_present), group_present(loc_present))  % DEBUG
  present2all = @(A_present) setel(A_allempty, {is_present ':'}, A_present(loc_present,:));
  varargout = cellfun2(present2all, varargout);
end

%!test
%! n = 10;
%! m = 5;
%! p = 1;
%! x = rand(n,p);
%! group_all = rand(m,1);
%! group = group_all([round(randint(1, m, [n-m, 1])); (1:m)']);
%! group(group == group_all(round(randint(1, m)))) = NaN;  % make one group absent.
%! y = NaN(m,p);
%! for i=1:m
%!   idx = (group == group_all(i));
%!   y(i,:) = mean(x(idx,:),1);
%! end
%! y2 = grpstatsall (x, group, group_all);
%! [y, y2]  % DEBUG
%! myassert(y, y2)

%!test
%! n = 10;
%! x = rand(n,1);
%! group_all1 = {'b'; 'a'};
%! group = group_all1(round(randint(1, numel(group_all1), [n 1])));
%! for i=1:2
%!   switch i
%!   case 1,  group{1} = 'a';
%!   case 2,  group{1} = 'b';
%!   end
%!   y1 = grpstatsall (x, group, group_all1, 'mean');
%!   [y2, group_all2] = grpstats (x, group, {'mean' 'gname'});
%!   [group_all1b, ind1] = sort(group_all1);
%!   [group_all2b, ind2] = sort(group_all2);
%!   y1b = y1(ind1);
%!   y2b = y2(ind2);
%!     %group_all1b, group_all2b  % DEBUG
%!     [group_all1b, group_all2b]  % DEBUG
%!     [y1b, y2b]  % DEBUG
%!   myassert(group_all1b, group_all2b)
%!   myassert(y1b, y2b)
%! end
