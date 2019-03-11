function [num0, vec0] = mydatebom (epoch)
%MYDATEBOD: Return epoch at beginning of the month containing input epoch.
    if isempty(epoch),  num0 = [];  vec0 = [];  return;  end
    if (size(epoch,2) == 1)
        % epoch is in mydatenum format
        num = epoch;
        vec = mydatevec(num);
    else
        % epoch is in mydatevec format
        vec = epoch;
    end
    %% define the epoch corresponding to the beginning of that month:
    vec0 = vec(:,1:2);
    num0 = mydatenum(vec0);
end

