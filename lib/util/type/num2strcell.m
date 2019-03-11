function cell = num2strcell (num, varargin)
    cell = arrayfun(@(x) num2str(x, varargin{:}), num, 'UniformOutput',false);
end

%!test
%! num = [1; 10];
%! cell = {'1'; '10'};
%! cell2 = num2strcell (num);
%! %cell2, cell  % DEBUG
%! myassert(cell2, cell)

