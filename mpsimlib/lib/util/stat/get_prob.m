function [prob, conf, tail] = get_prob (conf, tail)
    if (nargin < 1) || isempty(conf),  conf = 0.95;  end
    if (nargin < 2) ||isempty(tail),  tail = 'both';  end

    if any(conf < 0.5) ...  % it seems a significance level
    || any(conf > 1.0)      % it seems a percentage
        warning('MATLAB:get_var_lim:badConfLevel', ...
            ['Confidence level seems erroneous -- '...
             'usually it''s 0.95 or 0.99.'])
    end

    switch tail
    case 'left',   prob = conf;
    case 'right',  prob = 1 - conf;
    case 'both',   prob = [(1-conf)/2, 1-(1-conf)/2];
    case 'two',    prob = 1-(1-conf)/2;
    case 'max',    prob = 1-(1-conf)/2;
    % (definition below is inconsistent w/ stats vartest*)
    %case 'left',   prob = 1 - conf;
    %case 'right',  prob = conf;
    otherwise
        error('stats:internal:getParamVal:BadValueListChoices', ...
            ['''%s'' is not a valid value for the TAIL argument.  '...
             'The value must be ''left'', ''right'', ''both'', or ''''.'], tail);
    end
    %prob  % DEBUG
end
