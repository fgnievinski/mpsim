function out = cell2matifiscell (in)
    if iscellstr(in)
        out = char(in);
    elseif iscell(in)
        out = cell2mat(in);
    else
        out = in;
    end
    %in, out  % DEBUG
end

