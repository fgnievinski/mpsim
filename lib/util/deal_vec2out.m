function varargout = deal_vec2out (argin, mynum2cell)
    if (nargin < 2),  mynum2cell = @num2cell;  end
    if isa(argin, 'function_handle')
        vec = argin();
    else
        vec = argin;
    end
    cel = mynum2cell(vec);
    varargout = cel;
end

%!test
%! f = @() polyfit(1:4, 1:4, 1);
%! vec = f();
%! out1 = vec(1);
%! out2 = vec(2);
%! [out1b, out2b] = deal_vec2out (f);
%! myassert(out2b, out2)
%! myassert(out1b, out1)

