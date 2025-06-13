function x = list2cell (x, rowdist, varargin)
    x = mat2cell(x, rowdist+1, varargin{:});
    %assert(all(isnan(cellfun(@(xi) all(isnan(xi(end,:))), x))));
    x = cellfun2(@(xi) xi(1:end-1,:), x);
end

