function set_tick_label_asind2 (XY, format, etick, eticktolabel, elim, fnc)
    if (nargin < 1) || isempty(XY),      XY = 'X';  end
    if (nargin < 2) || isempty(format),  format = '%.1f';  end
    if (nargin < 3) || isempty(etick),   etick = 10/4;  end  % elev ticks.
    if (nargin < 4) || isempty(eticktolabel),  eticktolabel = 'full';  end  % elev ticks to be labeled (not the labels themselves).
    if (nargin < 5) || isempty(elim),  elim = [0 90];  end
    if (nargin < 6) || isempty(fnc),  fnc = @sind;  end
    
    if isscalar(etick),  etick = elim(1):etick:elim(2);  end
    if ischar(eticktolabel),  switch lower(eticktolabel) %#ok<ALIGN>
    case 'full',  eticktolabel = [0 5 10 15 20 30 45 60 90];
    case 'wide',  eticktolabel = 0:15:90;
    case 'avg',   eticktolabel = [0:10:60,90];
    otherwise,  error('MATLAB:set_tick_label_asind2:badLab', ...
        'Unknown eticktolabel = "%s"', eticktolabel);
    end,  end
    %format  % DEBUG    
    
    eticklabel = num2str(colvec(etick), format);
    eticklabel = cellstr(eticklabel);
    eticklabel(~ismember(etick, eticktolabel)) = {''};
    eticklabel = strrep(eticklabel, '.0', '');    

    %set(gca, [XY 'Lim'],      fnc(elim))
    %set(gca, [XY 'Tick'],     fnc(etick))
    %set(gca, [XY 'TickLabel'],eticklabel)
    set(gca, [XY 'Lim'],      sort(fnc(elim)))
    [tmp, ind] = sort(fnc(etick));
    set(gca, [XY 'Tick'],     tmp)
    set(gca, [XY 'TickLabel'],eticklabel(ind))

    %set(gcf, 'ResizeFcn',{@(src, eventdata) set_tick_label_asind2(XY)});
end

