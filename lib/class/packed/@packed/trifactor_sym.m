function [answer, ipiv, info] = trifactor_sym (A, uplow)
    if isempty(A)
        answer = packed([]);
        info = 0;
        return;
    end

    if ~strncmpi(uplow, A.uplow, 1)
        error ('packed:trifactor_sym:badUplow', ...
            '"uplow" asked is different than matrix''s uplow property.');
    end

    if ~any(strcmp(get_caller_name, {'trifactor', 'bk'}))
        error ('packed:trifactor_sym:privFunc', 'This is a private function.');
    end
    
    [info, temp, ipiv] = call_lapack ('sp', 'trf', ...
        A.uplow, A.order, A.data);

    myassert (info >= 0);
    answer = packed(temp, 'tri', A.uplow);
end

%TODO: test it; B-K factorization is not available in Matlab, though, so we must come up with a way of doing it (perhaps via the solution of a linear system?).

