function [elev_all, sin_elev_all, sin_elev_lim] = get_elev_regular_in_sine (num, elev_min, elev_max, ...
roundit, invit, order, uniqueit, fnc)
    if (nargin < 1) || isempty(num),       num =  7;  end
    if (nargin < 2) || isempty(elev_min),  elev_min =  3;  end
    if (nargin < 3) || isempty(elev_max),  elev_max = 90;  end
    if (nargin < 4) || isempty(roundit),   roundit = true;  end
    if (nargin < 5) || isempty(invit),     invit = true;  end
    if (nargin < 6) || isempty(order),     order = 'descend';  end
    if (nargin < 7) || isempty(uniqueit),  uniqueit = false;  end
    if (nargin < 8) || isempty(fnc),  fnc = {@sind @asind};  end
    %if (elev_min == 0),  elev_min = eps();  end
    if invit
        sin_elev_all = 1./linspace(1./fnc{1}(elev_max), 1./fnc{1}(elev_min), num);
    else
        sin_elev_all = linspace(fnc{1}(elev_max), fnc{1}(elev_min), num);
    end
    elev_all = fnc{2}(sin_elev_all);
    if roundit,  elev_all = round(elev_all);  end
    if uniqueit,  elev_all = unique(elev_all);  end
    elev_all = sort(elev_all, order);
    elev_all = elev_all(:);
    sin_elev_all = fnc{1}(elev_all);
    sin_elev_lim = [min(sin_elev_all), max(sin_elev_all)];
end

