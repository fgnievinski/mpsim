function h = legendtitle(legh,titlestr,varargin)
%LEGENDTITLE adds a title to a legend
% LEGENDTITLE(LEGH,TITLESTR) adds the title TITLESTR to the legend LEGH
% LEGENDTITLE(TITLESTR) adds the title to the current legend in the current
%  axes.
% LEGENDTITLE(...,Param1,Val1,Param2,Val2,...) sets the specified
%  properties for the text object.
% H = LEGENDTITLE(...) returns the handle for the text object used to
%  create the title string

% argument checking
if nargin < 1
    error([upper(mfilename) ' requires at least one argument.']);
elseif nargin == 1
    if ~ischar(legh) && ~iscellstr(legh)
        error([upper(mfilename) ' requires a string, if the legend handle is not specified.'])
    else
        titlestr = cellstr(legh);
        legh = legend;
        if isempty(legh)
            error('No legend found.');
        end
    end
elseif nargin == 2
    if ~ishandle(legh) || ~strcmp('axes',get(legh,'Type'))
        error('Invalid legend handle')
    end
    if ~ischar(titlestr) && ~iscellstr(titlestr)
        error('Invalid title string')
    end
else
    if ischar(legh) || iscellstr(legh) %(titlestr,varargin)
        varargin = [{titlestr} varargin];
        titlestr = legh;
        legh = legend; 
        if isempty(legh)
            error('No legend found.');
        end
    elseif ~ishandle(legh) || ~strcmp('axes',get(legh,'Type'))
        error('Invalid legend handle')        
    end
    if ~ischar(titlestr) && ~iscellstr(titlestr)
        error('Invalid title string')
    end
end

if mod(length(varargin),2) ~= 0
    error('Incorrect specification of parameter/value pairs')
end

% convert to pixel units for all calculations
legUnits = get(legh,'Units');
set(legh,'Units','pixels');
legPos = get(legh,'Position');

% determine current top of the legend axes
currentLegTop = legPos(2) + legPos(4);

% store the old legend position
oldLegPos = legPos;

% find the text objects in the legend
htxt = findobj(legh,'Type','text');

% set the text Units to pixels
txtUnits = get(htxt,'Units');
set(htxt,'Units','pixels');
txtExtent = get(htxt,'Extent');
txtPos = get(htxt,'Position');
txtStr = get(htxt,'String');

% determine height for each row of text
numRows = size(txtStr,1);
if iscell(txtExtent)
    % sort by y position
    txtExtent = sortrows(cat(1,txtExtent{:}),-2);        
    topTextTop = txtExtent(1,2) + txtExtent(1,4);
else
    topTextTop = txtExtent(2) + txtExtent(4);
end

% new height for the legend axes, based on number of rows in title

legPos(4) = max(legPos(4),topTextTop + 5);

newHeight = legPos(4);

newPos = [legPos(1), currentLegTop - newHeight, legPos(3:4)];

% determine new YLim for the legend axes
legYLim = get(legh,'YLim');
yLengthPerPixel = diff(legYLim)/oldLegPos(4);
newYLim = [legYLim(1) yLengthPerPixel * newHeight];

% change the YLim and Position of the axes, so it can contain the title
set(legh,'YLim',newYLim,'Position',newPos);

legXLim = get(legh,'XLim');

% see if there is already a legend title object:
holdtitle = getappdata(legh,'LegendTitleHandle');
if isempty(holdtitle)
    % create the text object
    htitletxt = text('Parent',legh,...
                     'Units','pixels',...
                     'Position',[diff(legXLim)/2, (topTextTop + 5)],...
                     'VerticalAlignment','bottom',...
                     'String',titlestr,...
                     'FontWeight','bold',...
                     'FontName',get(legh,'FontName'),...
                     'Tag','LegendTitle',...
                     'HandleVisibility','off',...
                     varargin{:});
else
    htitletxt = holdtitle;
    set(htitletxt,'String',titlestr,varargin{:})
end
                 
         
% make sure the title doesn't extend beyond the axes           
currentLegRight = newPos(1) + newPos(3);
xLengthPerPixel = diff(legXLim)/newPos(3);

newTxtExtent = get(htitletxt,'Extent');
if newTxtExtent(1)  < 0 || newTxtExtent(1) +  newTxtExtent(3) > newPos(3)        
    newWidth = max(newTxtExtent(3) + 10,txtExtent(1,1) + txtExtent(1,3));
    newPos = [currentLegRight - newWidth, newPos(2), newWidth, newPos(4)];
    newXLim = [legXLim(1) xLengthPerPixel*newWidth];
    set(legh,'Position',newPos,'XLim',newXLim);
elseif newTxtExtent(1) + newTxtExtent(3) < txtExtent(1,1) + txtExtent(1,3)  || newTxtExtent(3) + 10 < newPos(3)
    newWidth = max(newTxtExtent(3) + 10,txtExtent(1,1) + txtExtent(1,3));
    newPos = [ currentLegRight - newWidth, newPos(2), newWidth,newPos(4)];
    newXLim = [legXLim(1) xLengthPerPixel*newWidth];
    set(legh,'Position',newPos,'XLim',newXLim);
end

legYLim = get(legh,'YLim');
yLengthPerPixel = diff(legYLim)/newPos(4);
currentLegTop = newPos(2) + newPos(4);
if newTxtExtent(2) + newTxtExtent(4) + 10 > newPos(4)
   newHeight = newTxtExtent(2) + newTxtExtent(4) + 10;
   newPos = [newPos(1), currentLegTop - newHeight, newPos(3),newHeight];
   newYLim = [legYLim(1) yLengthPerPixel*newHeight];
   set(legh,'Position',newPos,'YLim',newYLim)
end

% now, make sure the title is centered
legXLim = get(legh,'XLim');
currentPos = get(legh,'Position');
txtPos = get(htitletxt,'Position');
set(htitletxt,'Position',[currentPos(3)/2 txtPos(2:3)],...
    'HorizontalAlignment','center');

% restore Units
set(legh,'Units',legUnits);
set(htxt,{'Units'},cellstr(txtUnits));

% store the legend title
setappdata(legh,'LegendTitleHandle',htitletxt)

% return handle to text
if nargout
    h = htitletxt;
end