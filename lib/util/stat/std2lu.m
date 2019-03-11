function [l, u] = std2lu (s, x)
    if iscell(s)
        l = s{1};
        u = s{2};
    elseif isvector(s)
        l = s;
        u = s;
    else
        if isrow(x)
            l = s(1,:);
            u = s(2,:);
        else
            l = s(:,1);
            u = s(:,2);
        end            
    end
end
