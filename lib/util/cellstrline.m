function cs = cellstrline (str, lt, algo)
%CELLSTRLINE: Convert string to cell array breaking at line terminators.

  if (nargin < 2),  lt = [];  end
  if (nargin < 3) || isempty(algo),  algo = 'default';  end
  
  if any(strcmp(algo, {'default','textscan','faster'}))
    opt = {};  if ~isempty(lt),  opt = {'EndOfLine',lt};  end
    cs = textscan(str, '%s', 'Delimiter','', 'WhiteSpace','', opt{:});
    cs = cs{1};
    return;
  end
  
  str = rowvec(str);
  lt_default = sprintf('\n');
  if isempty(lt)
      str = strrep(str, sprintf('\r\n'), lt_default);
      str = strrep(str, sprintf('\r'), lt_default);
      lt = lt_default;
  end
  if (numel(lt) > 1)
      str = strrep(str, lt, lt_default);
      lt = lt_default;
  end
  if (str(end)~=lt),  str(end+1) = lt;  end
  ind = find(str==lt);
  num = diff([0 ind]);
  cs = mat2cell(str, 1, num)';
  %cs = deblank(cs);
  cs = cellfun2(@(csi, indi) csi(1:indi-1), cs, num2cell(num'));
end

%!test
%! str = sprintf('abc\ndef\ngh\ni');
%! cs = {'abc';'def';'gh';'i'};
%! cs2 = cellstrline(str);
%! celldisp(cs2)
%! myassert(cs{1}, cs2{1})
%! myassert(cs, cs2)

%!test
%! str = sprintf('abc\ndef\ngh\ni\n');
%! cs = {'abc';'def';'gh';'i'};
%! cs2 = cellstrline(str);
%! celldisp(cs2)
%! myassert(cs{1}, cs2{1})
%! myassert(cs, cs2)


