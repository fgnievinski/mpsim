function avg = nanavgr (obs, dim, ignore_nans, robustify)
    if (nargin < 2) || isempty(dim),  dim = finddim(obs);  end
    if (nargin < 3) || isempty(ignore_nans),  ignore_nans = true;  end
    if (nargin < 4) || isempty(robustify),  robustify = true;  end 
    if      robustify &&  ignore_nans,  myavg = @nanmedian;
    elseif ~robustify &&  ignore_nans,  myavg = @nanmean;
    elseif  robustify && ~ignore_nans,  myavg = @median;
    elseif ~robustify && ~ignore_nans,  myavg = @mean;
    end
    avg = myavg (obs, dim);
end

