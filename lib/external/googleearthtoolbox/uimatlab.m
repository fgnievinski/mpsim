function uiIsMatLab = uimatlab

uiIsMatLab = false;
LIC = license('inuse');
for elem = 1:numel(LIC)
    envStr = LIC(elem).feature;
    if strcmpi(envStr,'matlab')
        uiIsMatLab = true;
        break
    end
end
