function str_modif = strrep_inplace (str_orig, str_old, str_new)
%STRREP_INPLACE: Fast string replacement when the size doesn't change.
  assert(numel(str_old) == numel(str_new))
  str_orig(:,end+1) = sprintf('\n');
  str_orig_row = rowvec(str_orig', 'force');
  str_modif_row = regexprep(str_orig_row, str_old, str_new);
  %str_modif_row = strrep(str_orig_row, str_old, str_new);  % WRONG! see overlapping patterns in doc strrep
  str_modif = reshape(str_modif_row, size(str_orig'))';
  str_modif(:,end) = [];
end

%!test
%! answer = strrep_inplace (['1234';'1344'], '34', 'ab')
%! myassert(answer, ['12ab';'1ab4'])
