function optim = optimset_abstol (optim)
    if isfieldempty(optim, 'TolXAbs')
        warning('MATLAB:lsqnonlin_abstol:optimset_abstol:notSet', ...
            '"TolXAbs" not set.');
        return;
    end
    %myoptimset = @optimset;  % WRONG! deletes TolXAbs field.
    myoptimset = @setfields;
    outfun2 = @(varargin) outfun(optim.TolXAbs, varargin{:});
    optim = myoptimset(optim, 'OutputFcn',outfun2, 'TolX',0, 'TolFun',0);
end

%%
function stop = outfun (TolXAbs, x, optimValues, state) %#ok<INUSL>
    if ~strcmp(state, 'iter') ...
    || isempty(optimValues.searchdirection)
        stop = false;
        return;
    end
    deltaX = optimValues.stepsize .* optimValues.searchdirection;
    temp = ( abs(deltaX) < TolXAbs );
    %[deltaX, temp]  % DEBUG
    stop = all(temp);
end
