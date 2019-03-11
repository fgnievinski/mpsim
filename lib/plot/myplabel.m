function [ht, hp] = myplabel (h, t, p, merge_duplicates, varargin)
  if isempty(h),  h = flipud(get(gca(), 'Children'));  end
  if (nargin < 3),  p = [];  end
  if (nargin < 4) || isempty(merge_duplicates),  merge_duplicates = true;  end
  if isnumeric(t),  t = num2str(t);  end
  if ~iscell(t),    t = cellstr(t);  end
  if isvector(p),   p = rowvec(p);   end
  N = numel(h);
  assert(numel(t)==N)
  % text length:
  tl = cellfun(@numel, t);
  % make up a number with as many digits as characters in the text label:
  v = 10.^(tl-1);
  % create dummy countour labels:
  [ht, hp, ind] = plabelv (h, v, p, varargin{:});
  % replace content of dummy labels:
  if ~isempty(ht),  arrayfun(@(i) set(ht(i), 'String',t{ind(i)}), 1:numel(ind));  end
  if merge_duplicates,  [ht, hp] = plabeld (ht, hp);  end
  if (nargout < 1),  clear ht;  end
  if (nargout < 2),  delete(hp);  clear hp;  end  % discard plus signs
end

function [ht, hp, ind] = plabelv (h, v, p, varargin)
  h = h(:);
  v = v(:);
  [x, y] = plabelp (h, p);
  n = cellfun(@numel, x);
  idx0 = (n == 0);  ind = find(~idx0);
  x(idx0) = [];
  y(idx0) = [];
  v(idx0) = [];
  n(idx0) = [];
  n = num2cell(n);
  v = num2cell(v);
  vx = interleave(v, x);
  ny = interleave(n, y);
  vx = cell2mat(vx);
  ny = cell2mat(ny);
  C = [vx'; ny'];
  if isempty(C),  ht = [];  hp = [];  return;  end
  h = clabel(C, varargin{:});
  if isempty(h),  ht = [];  hp = [];  return;  end
  idx = strcmp(get(h, 'Type'), 'text');
  ht = h(idx);
  hp = h(~idx);
end

function [x, y] = plabelp (h, p)
  x = get(h, 'XData');
  y = get(h, 'YData');
  if isscalar(h),  x = {x};  y = {y};  end
  x = cellfun(@(x) x(:), x, 'UniformOutput',false);
  y = cellfun(@(y) y(:), y, 'UniformOutput',false);
  %keyboard
  if isempty(p),  return;  end
  N = numel(x);
  if (size(p,1) == 1),  p = repmat(p, [N 1]);  end
  x0 = p(:,1);
  dx = p(:,2);
  for i=1:N
    idx = (abs(x{i} - x0(i)) < dx(i));
    x{i} = x{i}(idx);
    y{i} = y{i}(idx);
  end
end

function [ht2, hp2] = plabeld (ht, hp)
  ht2 = ht;  hp2 = hp;
  if (numel(ht) < 2),  return;  end
  [a,b,m,n] = unique2(cell2mat(get(ht, 'Position')), 'rows'); %#ok<ASGLU>
  idx = (b>1);
  if none(idx),  return;  end
  ht2 = ht(m);  hp2 = hp(m);
  %c = m(idx);  % WRONG!
  c = find(idx);
  t = get(ht, 'String');
  for i=1:numel(c)
    idx2 = (n == c(i));
      assert(sum(idx2)>1)
    t2 = str2list(strtrim(t(idx2)), ', ');
    set(ht2(c(i)), 'String',t2);  
  end
  idx3 = ~ismember(ht, ht2);
  delete(ht(idx3));
  delete(hp(idx3));
end

%!test
%! x = linspace(0,1,25)'; 
%! y = sin(x*2*pi);
%! y = [y, -y];
%! figure
%!   h = plot(x,y);
%!   plabel(h, {'y','-y'})
%!   plabel(h, {'y','-y'}, [0.9 0.1], 'FontSize',14)
%!   grid on
