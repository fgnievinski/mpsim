function answer = triuplow(answer, uplow)
    switch uplow
    case 'upper'
        answer = triu(answer);  % doesn't modify in-place.
        %idx = tril(true(size(answer)),-1);
    case 'lower'
        answer = tril(answer);  % doesn't modify in-place.
        %idx = triu(true(size(answer)),+1);
    otherwise
        error('MATLAB:triuplow:UplowBad', 'Unknown uplow = "%s".', uplow);
    end
    %answer(idx) = 0;  % modify in-place. %% not supported by @blockdiag.
end

