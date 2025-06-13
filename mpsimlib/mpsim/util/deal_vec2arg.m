function varargout = deal_vec2arg (f, vec, evalit)
    if (nargin < 3) || isempty(evalit),  evalit = false;  end
    myassert(isvector(vec))
    myassert(isa(f, 'function_handle'))
    if ~iscell(vec),  vec = num2cell(vec);  end
    if evalit
        [varargout{1:nargout}] = f(vec{:});
    else
        varargout{1} = @() f(vec{:});
    end
end

%!test 
%! in = rand(3,1);
%! f1 = @(a, b, c) a + b + c;
%! f2 = deal_vec2arg (f1, in);
%! out1 = f1(in(1), in(2), in(3));
%! out2 = f2();
%! myassert(out2, out1)

