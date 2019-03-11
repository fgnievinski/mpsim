function answer = any_obj_in_base (class_name, ws)
    if (nargin < 2),  ws = 'base';  end
        
    s = evalin(ws, 'whos;');
    
    answer = any(strcmp({s(:).class}, class_name));
    if (answer == true),  return;  end

    % Some user-classes cheat in their overloaded class.m,
    % so that their reported class name is not necessarily true.
    var_name = {s(:).name};
    
    i = 1;  answer = false;
    while (i <= length(var_name) & answer == false)
        fcall = sprintf('isa(%s, ''%s'');', var_name{i}, class_name);
        answer = evalin(ws, fcall);
        i = i + 1;
    end
end

%!shared
%! ws = 'caller';
 
%!test
%! a = double(0);
%! myassert ( any_obj_in_base ('double', ws));
%! myassert (~any_obj_in_base ('single', ws));

%!test
%! a = single(0);
%! myassert (~any_obj_in_base ('double', ws));
%! myassert ( any_obj_in_base ('single', ws));

