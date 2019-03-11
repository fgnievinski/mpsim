function [color_lim2, color_lim, ch] = colorlim (data, factor, ah, ch, color_lim, color_label, tit)
    if (nargin < 1),  data = [];  end
    if (nargin < 2) || isempty(factor),  factor = 1;  end
    if (nargin < 3) || isempty(ah),  ah = gca();  end
    if (nargin < 4) || isempty(ch),  ch = colorbar();  end
    if (nargin < 5),  color_lim = [];  end
    if (nargin < 6),  color_label = [];  end
    if (nargin < 7),  tit = '';  end
    if isempty(color_label),  color_label = 'tight';  end
    if isempty(data),  data = get(findobj2(ah), 'CData');  end
    
    data = reshape(data, [],1);
    data_lim = [min(data), max(data)];
    if (data_lim(2)==data_lim(1)),  data_lim(2) = data_lim(1) + eps();  end
    data_lim_symm   = [-1,+1] *  max(abs(data_lim)) * factor;
    data_lim_tight  = [-1,+1] * abs(diff(data_lim)) * (factor-1) + data_lim;
    idx = (abs(data_lim_tight) > max(abs(data_lim_symm)));
    data_lim_zeroed = setel(data_lim_tight, idx, data_lim_symm(idx));

    switch lower(color_label)
    case {'symm', 'symmetrical', 'symmetric'}
        color_lim1 = data_lim_symm;
        color_lim2 = data_lim_symm;
    case {'tight', 'data'}
        color_lim1 = data_lim_symm;
        color_lim2 = data_lim_zeroed;
    end
    if ~isempty(color_lim),  color_lim1 = color_lim;  end
    %color_lim1, color_lim2  % DEBUG
    
    set(ah, 'CLim',color_lim1)
    set_clim2 (ch, color_lim2)
    title(ch, tit)
    
    if (nargout < 1),  clear ch color_lim2 color_lim;  end  % so that they don't display.
end

%%
function oh = findobj2 (ah)
    %if is_octave()
    %  oh = findobj(ah, '-regexp','Type','image|surf|hggroup');
    %else
    %  oh = findobj(ah, 'Type','image', '-or', 'Type','surf', '-or', 'Type','hggroup');
    %end
    oh = [...
      findobj(ah, 'Type','image');
      findobj(ah, 'Type','surf');
      findobj(ah, 'Type','hggroup');
    ];
    if isempty(oh)
        error('MATLAB:colorlim:badObjHandle', 'Data not found.');
    end
end
%%
function set_clim2 (ch, color_lim2)
    try
        temp = get(ch, 'Orientation');
    %catch err  % not in octave
    catch %#ok<CTCH>
        err = lasterror(); %#ok<LERR>
        if strcmp(err.identifier, 'MATLAB:class:InvalidProperty') ...
        || (is_octave() && strcmp(err.message, 'get: unknown axes property Orientation'))
            temp = 'vertical';  % make an assumption
        else
            rethrow(err)
        end
    end
    if strstarti('vertical', temp)
        set(ch, 'YLim',color_lim2)
    elseif strstarti('horizontal', temp)
        set(ch, 'XLim',color_lim2)
    else
        warning('MATLAB:colorlim:badOrientation', ...
            'Unknown orientation "%s".', temp)
    end
end    
