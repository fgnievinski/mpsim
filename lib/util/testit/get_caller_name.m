function func_caller = get_caller_name ()
    ST = dbstack();
    % ST(1) is get_func_caller itself
    % ST(2) is the function that called get_func_caller
    % ST(3) is the function that called ST(2), which we have to get its name.
    switch length(ST)
    case 1
        % this function itself is being called at the command prompt.
        error ('get_caller_name:promptCall', ...
        'Function cannot be called at command prompt.');
    case 2
        % that function is being called at the command prompt.
        func_caller = [];
    otherwise
        assert (length(ST) >= 3)
        func_caller = ST(3).name;
        if is_octave()
            func_caller(1:find(func_caller == '>', 1)) = [];
        end
    end
end

%!test
%! afunc;
%! function afunc
%!     bfunc;
%!     function bfunc
%!         temp = get_caller_name;
%!         assert (strfind(temp, 'afunc'));
%!     end
%! end

