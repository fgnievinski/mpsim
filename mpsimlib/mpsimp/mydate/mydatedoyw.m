function [doyw, wyear] = mydatedoyw (varargin)
%MYDATEDOYW: Convert epoch to (decimal) day of water-year.
    [num, num0, wyear] = mydatedoyw_aux (varargin{:});
    doyw = mydateday(num - num0);
end

%!test
%! for i=1:4
%! switch i
%! case 1,  vec_correct = [2000 10  1 0 0 0];  doyw_correct = 1;  wyear_correct = 2001;
%! case 2,  vec_correct = [2001  1  1 0 0 0];  doyw_correct = 1+31+30+31;  wyear_correct = 2001;
%! case 3,  vec_correct = [2000 10 30 0 0 0];  doyw_correct = 30;  wyear_correct = 2001;
%! case 4,  vec_correct = [2001  9 29 0 0 0];  doyw_correct = 364;  wyear_correct = [2001];
%! end
%! num_correct = mydatenum(vec_correct);
%! [doyw_answer, wyear_answer] = mydatedoyw(num_correct);
%! num_answer = mydatedoywi(doyw_answer, wyear_answer);
%! %doyw_correct, doyw_answer  % DEBUG
%! %wyear_correct, wyear_answer  % DEBUG
%! %num_correct, num_answer  % DEBUG
%! myassert (doyw_answer, doyw_correct);
%! myassert (wyear_answer, wyear_correct);
%! myassert (num_answer, num_correct);
%! end

