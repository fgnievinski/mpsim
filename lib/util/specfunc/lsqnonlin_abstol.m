function varargout = lsqnonlin_abstol (fun, x0, lb, ub, optim)
    optim = optimset_abstol (optim);
    [varargout{1:nargout}] = lsqnonlin (fun, x0, lb, ub, optim);
end
