function str_out = str2list (str_in, sep, end_pt, quote)
    if (nargin < 2) || isempty(sep),  sep = ', ';  end
    if (nargin < 3),  end_pt = '';  end
    if (nargin < 4),  quote = '';  end
    if ~iscell(str_in)
        str_out = str2list ({str_in}, sep, end_pt, quote);
        %str_out = [str_in end_pt];  % WRONG!
        return;
    end
    format = [quote '%s' quote];
    str_out = sprintf([format sep], str_in{:});
    str_out(end-numel(sep)+1:end) = [];  % remove dangling ', '
    str_out = [str_out, end_pt];
end

%!test
%! str_in = {'a' 'b'};
%! str_out = 'a, b';
%! str_out2 = str2list(str_in);
%! %str_out2, str_out  % DEBUG
%! myassert(str_out2, str_out)

%!test
%! str_in = {'a' 'b'};
%! str_out = '"a"; "b".';
%! str_out2 = str2list(str_in, '; ', '.', '"');
%! %str_out2, str_out  % DEBUG
%! myassert(str_out2, str_out)

%!test
%! str_in = 'a';
%! str_out = '"a".';
%! str_out2 = str2list(str_in, '; ', '.', '"');
%! %str_out2, str_out  % DEBUG
%! myassert(str_out2, str_out)
