function h = cdfplot2(X, varargin)

hold on
for i=1:size(X,2)
    h(i) = cdfplot(X(:,i), varargin{:});
end

if (nargout < 1),  clear h;  end

end
