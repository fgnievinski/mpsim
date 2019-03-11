function [answer, t] = is_in_parallel ()
    try
        t = getCurrentTask();
        answer = ~isempty(t);
    catch err
        if ~strcmp(err.identifier, 'MATLAB:UndefinedFunction')
            rethrow(err);
        end
        answer = false;
    end
end
