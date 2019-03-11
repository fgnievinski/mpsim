function [DFTicks,DFLabel] = tlabel(varargin)
%TLABEL Full date formatted tick labels that works when ZOOM or PAN.
%
%   Syntax:
%      tlabel
%      tlabel(TICKAXIS)
%      tlabel(TICKAXIS,DATEFORM)
%      tlabel(TICKAXIS,DATEFORM,'keeplimits',...)
%      tlabel(TICKAXIS,DATEFORM,'keepticks',...)
%      tlabel(AX,...)
%      [DFTicks,DFLabel] = tlabel(...);
%
%   Input: (all optionals)
%      TICKAXIS     - Time axis, one of 'x' (default), 'y' or 'z'.
%      DATEFORM     - Numerical (see DATETICK) or string date form (see
%                     DATESTR for details).
%      'keeplimits' - Preservs the axis limits.
%      'keepticks'  - Constant ticks locations.
%      AX           - Uses the specified axis, rather than the current
%                     axes. The axes are automatically linked if more than
%                     one handle is specified: length(AX)>1 (see the
%                     example).
%   
%   Output: (all optionals)
%      DFTicks - Date format of the time axis ticks.
%      DFLabel - Date format of the time axis label.
%
%   Description:
%      This program uses DATETICK, i.e., puts date ticks in the time-axis
%      when serial date number is used as the axis data (see DATENUM for
%      details). When zooming or panning, the ticks labels are
%      automatically updated and changed the format from years (yyyy, for 
%      example) down to seconds (HH:MM:SS) but compleating the full date on
%      the label axis (the dd/mmm/yyyy of the day at the middle of the
%      time-axis). This is done by a modification of the function
%      DATETICKZOOM by Christophe Lauwerys (here included as subfunction). 
%
%      Allows the dateform input string different from the 0:28 defaults
%      formats of DATETICK and more than one axes handles, which will be
%      linked, i.e., if the user performs a zoom or a pan in any of the
%      linked axes, the others will do the same. With an internal default
%      option, the user can decide if the other axes (besides the time
%      axis) will be linked too, wich is usefull for 2D plots.  
%
%      Others internal options are the use of LOCAL dateforms (see DATESTR)
%      to write months in the local user language; the addition of date
%      ticks when less than 4 are drawn; and some others private options
%      that the user can easily check.
%
%   Example:
%      dt = 5*(1/60/24);                      % Sampling in days (5 min)
%      tini = datenum('2008/01/01 00:00:00'); % Initial date
%      tfin = datenum('2012/01/01 00:00:00'); % Final date
%      t = tini:dt:tfin;
%      z1 =   cos(t*2*pi/365.25*1-pi/4) + (rand(size(t))-0.5);
%      z2 =   cos(t*2*pi/365.25*2-pi/1) + (rand(size(t))-0.5);
%      z3 =   cos(t*2*pi/365.25*3-pi/2) + (rand(size(t))-0.5);
%      z4 =   z1 + z2 + z3              + (rand(size(t))-0.5);
%      h = zeros(2,1);
%
%      subplot(321)
%       plot(t,z1,'g'), axis tight
%       title('Annual')
%       tlabel
%
%      subplot(322);
%       plot(t,z2,'r'), axis tight
%       title('Semiannual')
%       tlabel('x','HH:MM dd')
%
%      h(1) = subplot(312);
%       plot(t,z3,'b'), axis tight
%       title('Terciannual (linked)')
%
%      h(2) = subplot(313);
%       plot(t,z4,'k'), axis tight
%       title('All (linked)')
%
%      tlabel(h)
%      zoom xon
%
%   See also DATETICK, DATESTR, DATENUM.

%   Copyright 2008 Carlos Adrian Vargas Aguilera
%   $Revision: 1.0 $  $Date: 2008/03/24 13:00:00 $

%   Written by
%   M.S. Carlos Adrian Vargas Aguilera
%   Physical Oceanography PhD candidate
%   CICESE 
%   Mexico, 2008
%   nubeobscura@hotmail.com
%
%   Download from:
%   http://www.mathworks.com/matlabcentral/fileexchange/loadAuthor.do?objec
%   tType=author&objectId=1093874


%% Parameters for private options
% Comment and uncomment as desire:

%%% Sets default months language.
%language = 'en_us';   
 language = 'local';                                   
 
%%% Link the other axes (besides the time-axis):
%linknottime = 1;         % This is usefull when ploting 2D surface
 linknottime = 0;         % This is usefull when ploting 1D lines
 
%%% Add more ticks when there are just few ticks days:
fixlow  = 1;
%fixlow = 0;                                

%%% When there are many ticks days, only the odd ones are used:
 fixhigh = 1;
%fixhigh = 0;             

%%% Change the default formatdate #6 in the ticks to string months:
%df6 = 6;
 df6 = 'dd/mmm';                                       
 
%%% Change the default formatdate #17 in the ticks to:
%df17 = 17;               % This format is QQ-YY, very ugly for me
 df17 = 12;                          
 
%%% Default formats in time axis label:
%dfy   = 10;
%dfmy  = 12;
%dfdmy = 24;
 dfy   = 'yyyy';                                         
 dfmy  = 'mmm yyyy';                                    
 dfdmy = 'dd/mmm/yyyy';
 
%%% Default date to be considered on the time axis label:
 datef = @mean;      % The middle date in the time axis
%datef = @min;       % The first  date in the time axis

%% Datetickzoom 
% Program written by Christophe Lauwerys:
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=
% 15029&objectType=file
[axh,ax,keep_limits,dfunknown] = datetickzoom(varargin{:});
if isempty(axh)
 return
end

%% Write if needed the year (and month (and day)) on time axis label:
[dateform,labelform] = ...
              timelabel(axh(1),ax,language,dfy,dfmy,dfdmy,datef,dfunknown);

%% Fix if few day ticks and tick labels language:
dateform = ...
 fixticks(axh(1),ax,language,dateform,keep_limits,fixlow,fixhigh,df6,df17);
 
%% Link axes (saved on the firts axis and label handle:
if length(axh)>1
 link_axes(axh,ax,linknottime)
end
 
%% Output arguments
if nargout
 DFTicks = dateform;
 if nargout>1
  DFLabel = labelform;
 end
end

 
%% Subfunctions (inlcuded a modification of DATETICKZOOM)

function [dateform,labelform] = ...
                  timelabel(axh,ax,language,dfy,dfmy,dfdmy,datef,dfunknown)
% TIMELABEL:
% Include what is left of the date by the ticks,
% on the date-axis label by Carlos Vargas.

%% Get dateformats that not include year (and months (and days)):
%    0 'dd-mmm-yyyy HH:MM:SS'    15 'HH:MM'               
%    1 'dd-mmm-yyyy'             16 'HH:MM PM'            
%    2 'mm/dd/yy'                17 'QQ-YY'               
%    3 'mmm'                     18 'QQ'                  
%    4 'm'                       19 'dd/mm'               
%    5 'mm'                      20 'dd/mm/yy'            
%    6 'mm/dd'                   21 'mmm.dd,yyyy HH:MM:SS'
%    7 'dd'                      22 'mmm.dd,yyyy'         
%    8 'ddd'                     23 'mm/dd/yyyy'          
%    9 'd'                       24 'dd/mm/yyyy'          
%   10 'yyyy'                    25 'yy/mm/dd'            
%   11 'yy'                      26 'yyyy/mm/dd'          
%   12 'mmmyy'                   27 'QQ-YYYY'             
%   13 'HH:MM:SS'                28 'mmmyyyy'             
%   14 'HH:MM:SS PM'       
f{1} = [3:6 18:19]; % not years
f{2} = 7:9;         % not (years +) month
f{3} = 13:16;       % not ((years +) month +) days
f{4} = [1:2 10:12 17 20:28]; % others 

%% Get time limits, ticks and labels:
slim = [ax 'lim'];
tick = get(axh,[slim(1) 'Tick']);      tick = tick(1);
tlab = get(axh,[slim(1) 'TickLabel']); tlab = tlab(1,:);
Nlab = length(tlab);

%% Search the dateform for the current ticks and label
labelform = [];
dateform = dfunknown;

if isempty(dateform) 
 
 % Search the dateform for the current ticks:
 for k = 1:4
  for m = f{k}
   nlab = datestr(tick,m);
   if Nlab==length(nlab) && strcmp(tlab,nlab)
    dateform = m; break
   end
  end
  if ~isempty(dateform), break, end
 end
 
 if ~isempty(dateform)
 % Search and write the labelform if any: 
  if ismember(dateform,f{1})       % puts year in the date-axis label
   labelform = dfy;
  elseif ismember(dateform,f{2})   % puts year and month
   labelform = dfmy;
  elseif ismember(dateform,f{3})   % puts year, month and day
   labelform = dfdmy;
  end
 end
 
elseif ischar(dateform)           % From a string dateform
 isformat = [0 0 0 0 0 0];
 if ~isempty(strfind(dateform,'yy')), isformat(1) = 1; end
 if ~isempty(strfind(dateform,'mm')), isformat(2) = 1; end
 if ~isempty(strfind(dateform,'dd')), isformat(3) = 1; end
 if ~isempty(strfind(dateform,'HH')), isformat(4) = 1; end
 if ~isempty(strfind(dateform,'MM')), isformat(5) = 1; end
 if ~isempty(strfind(dateform,'SS')), isformat(6) = 1; end
 ii = min(find(isformat));
 if ~isempty(ii)
  switch ii 
   case 2, labelform = dfy;
   case 3, labelform = dfmy;
   case 4, labelform = dfdmy;
   case 5, labelform = [dfdmy ' HH'];
   case 6, labelform = [dfdmy ' HH:MM'];
  end
 else
  labelform = [dfdmy ' HH:MM:SS'];
 end
elseif ~ismember(dateform,[0:28])
 warning('Tlabel:IncorretDateForm','Incorrect DateForm.')
 dateform = [];  
end

%% Write label:
if isempty(labelform)
 labeltext = '';
else
 date0 = datef(get(axh,slim));
 labeltext = datestr(date0,labelform,language); 
end
labelf = str2func([ax 'label']);
labelf(axh,labeltext)


function [dateform] = ...
     fixticks(axh,ax,language,dateform,keep_limits,fixlow,fixhigh,df6,df17)
% FIXTICKS:
%   Add some ticks when DATETICKS puts less than 4 days ticks, wich is very
%   low (this because it tries to write one for each week). Also, puts the
%   label in the specified language. By Carlos Vargas 

%% Default:
MinDayTicks = 4;
if ~fixlow
 MinDayTicks = -Inf;
end
MaxDayTicks = 11;
if ~fixhigh
 MaxDayTicks = Inf;
end
if isempty(df6)
 df6 = 6;
end
if isempty(df17)
 df17 = 17;
end
return17 = 0;
returndf = 0;
% Ignores fixlow if dateform is provided as unusual string:
if ischar(dateform)
 fixlow = 0; fixhigh = 0;
end
% Change dateform 17
if dateform==17 
 if df17~=17
  [return17,dftemp,dateform] = change_dateform(axh,ax,df17,keep_limits);
 end
end

%% Get axis limits and ticks:
tlim  = get(axh,[ax 'lim']);
ticks = get(axh,[ax 'Tick']);
inticks = sum(((ticks>=tlim(1))+(ticks<=tlim(2)))>1);

%% If MinDayTicks and add some multiple ticks:
if fixlow
 %    0 'dd-mmm-yyyy HH:MM:SS'    15 'HH:MM'               
 %    1 'dd-mmm-yyyy'             16 'HH:MM PM'            
 %    2 'mm/dd/yy'                17 'QQ-YY'               
 %    3 'mmm'                     18 'QQ'                  
 %    4 'm'                       19 'dd/mm'               
 %    5 'mm'                      20 'dd/mm/yy'            
 %    6 'mm/dd'                   21 'mmm.dd,yyyy HH:MM:SS'
 %    7 'dd'                      22 'mmm.dd,yyyy'         
 %    8 'ddd'                     23 'mm/dd/yyyy'          
 %    9 'd'                       24 'dd/mm/yyyy'          
 %   10 'yyyy'                    25 'yy/mm/dd'            
 %   11 'yy'                      26 'yyyy/mm/dd'          
 %   12 'mmmyy'                   27 'QQ-YYYY'             
 %   13 'HH:MM:SS'                28 'mmmyyyy'             
 %   14 'HH:MM:SS PM'  
 isformat = [0 0 0 0 0 0];
 if     ismember(dateform,[0 13:14 21])    % Seconds
  isformat(6) = 1;
 elseif ismember(dateform,15:16)           % Hours and minutes
  isformat(4) = 1;
 elseif ismember(dateform,[1:2 6:9 19:26]) % Days
  isformat(3) = 1;
 elseif ismember(dateform,[3:5 12 28])     % Months
  isformat(2) = 1;
 elseif ismember(dateform,10:11)           % Years
  isformat(1) = 1;
 end
 
 if inticks<MinDayTicks 
  
  if isformat(6) % Add seconds
   ticks = datevec(ticks);
   dt = (datenum(ticks(2,1:6))-datenum(ticks(1,1:6)))*24*60*60;
   dtf = factor(round(dt)); dtf = dtf(1); 
   dt = dt/dtf; 
   nticks = size(ticks,1); nticks = dtf*(nticks+1); 
   yyt = repmat(ticks(1,1),nticks,1);
   mmt = repmat(ticks(1,2),nticks,1);
   ddt = repmat(ticks(1,3),nticks,1);
   HHt = repmat(ticks(1,4),nticks,1);
   MMt = repmat(ticks(1,5),nticks,1);
   SSt = ((0:nticks-1)'-dtf)*dt + ticks(1,6);
   ticks = datenum([yyt mmt ddt HHt MMt SSt]);
   inticks = (((ticks>=tlim(1))+(ticks<=tlim(2)))>1);
   ticks = ticks(inticks);
   inticks = sum(inticks(inticks));
   
  elseif isformat(4) | isformat(5)  % Add hours:minutes
   ticks = datevec(ticks+0.1/60/60/24);
   if ticks(2,4)~=ticks(1,4)
    dt = (datenum([ticks(2,1:4) 0 0])-datenum([ticks(1,1:4) 0 0]))*24;
    dtf = factor(round(dt)); dtf = dtf(1);
    dt = dt/dtf;
    nticks = size(ticks,1); nticks = dtf*(nticks+1); 
    yyt = repmat(ticks(1,1),nticks,1);
    mmt = repmat(ticks(1,2),nticks,1);
    ddt = repmat(ticks(1,3),nticks,1);
    HHt = ((0:nticks-1)'-dtf)*dt + ticks(1,4);
    MMt = zeros(nticks,1);
    SSt = MMt;
    ticks = datenum([yyt mmt ddt HHt MMt SSt]);
    inticks = (((ticks>=tlim(1))+(ticks<=tlim(2)))>1);
    ticks = ticks(inticks);
    inticks = sum(inticks(inticks));
   elseif ticks(2,5)~=ticks(1,5)
    dt = (datenum([ticks(2,1:5) 0])-datenum([ticks(1,1:5) 0]))*24*60;
    dtf = factor(round(dt)); dtf = dtf(1);
    dt = dt/dtf;
    nticks = size(ticks,1); nticks = dtf*(nticks+1); 
    yyt = repmat(ticks(1,1),nticks,1);
    mmt = repmat(ticks(1,2),nticks,1);
    ddt = repmat(ticks(1,3),nticks,1);
    HHt = repmat(ticks(1,4),nticks,1);
    MMt = ((0:nticks-1)'-dtf)*dt + ticks(1,5);
    SSt = zeros(nticks,1);
    ticks = datenum([yyt mmt ddt HHt MMt SSt]);
    inticks = (((ticks>=tlim(1))+(ticks<=tlim(2)))>1);
    ticks = ticks(inticks);
    inticks = sum(inticks(inticks));
   end
   if inticks<MinDayTicks
    [returndf,df,dateform] = change_dateform(axh,ax,13,keep_limits);
    ticks = get(axh,[ax 'Tick']);
    inticks = (((ticks>=tlim(1))+(ticks<=tlim(2)))>1);
    ticks = ticks(inticks);
    inticks = sum(inticks(inticks));   
   end
   
  elseif isformat(3) % Add days
   ticks = datevec(ticks);
   dt = datenum([ticks(2,1:3) 0 0 0])-datenum([ticks(1,1:3) 0 0 0]);
   if dt>27 & dt<32
    nticks = 2*size(ticks,1);
    yyt = ticks(:,1);
    mmt = ticks(:,2);
    yyt = [yyt yyt].'; yyt = yyt(:);
    mmt = [mmt mmt].'; mmt = mmt(:);
    ddt = [ones(nticks/2,1) repmat(15,nticks/2,1)].'; ddt = ddt(:);
   else
    dtf = factor(round(dt)); dtf = dtf(1);
    dt = dt/dtf;
    nticks = size(ticks,1); nticks = dtf*(nticks+1); 
    yyt = repmat(ticks(1,1),nticks,1);
    mmt = repmat(ticks(1,2),nticks,1);
    ddt = ((0:nticks-1)'-dtf)*dt + ticks(1,3);
   end
   HHt = zeros(nticks,1);
   MMt = HHt;
   SSt = MMt;
   ticks = datenum([yyt mmt ddt HHt MMt SSt]);
   inticks = (((ticks>=tlim(1))+(ticks<=tlim(2)))>1);
   ticks = ticks(inticks);
   inticks = sum(inticks(inticks));
   if dt<=27
    if inticks<MinDayTicks 
     [returndf,df,dateform] = change_dateform(axh,ax,15,keep_limits);
     ticks = get(axh,[ax 'Tick']);
     inticks = (((ticks>=tlim(1))+(ticks<=tlim(2)))>1);
     ticks = ticks(inticks);
     inticks = sum(inticks(inticks));   
    end
   end
   
  elseif isformat(2) % Add months
   ticks = datevec(ticks);
   dt = ticks(2,2) - (ticks(1,2))+12*(ticks(2,1)-ticks(1,1));
   dtf = factor(round(dt)); dtf = dtf(1);
   dt = dt/dtf;
   nticks = size(ticks,1); nticks = dtf*(nticks+1);
   yyt = repmat(ticks(1,1),nticks,1);
   mmt = ((0:nticks-1)'-dtf)*dt + ticks(1,2);
   ddt = ones(nticks,1);
   HHt = zeros(nticks,1);
   MMt = HHt;
   SSt = MMt;
   ticks = datenum([yyt mmt ddt HHt MMt SSt]);
   inticks = (((ticks>=tlim(1))+(ticks<=tlim(2)))>1);
   ticks = ticks(inticks);
   inticks = sum(inticks(inticks));
   if inticks<MinDayTicks
    [returndf,df,dateform] = change_dateform(axh,ax,6,keep_limits);
    ticks = get(axh,[ax 'Tick']);
    inticks = (((ticks>=tlim(1))+(ticks<=tlim(2)))>1);
    ticks = ticks(inticks);
    inticks = sum(inticks(inticks));   
   end
   
  elseif isformat(1) % Add years
   ticks = datevec(ticks);
   dt = ticks(2,1) - ticks(1,1);
   dtf = factor(round(dt)); dtf = dtf(1);
   dt = dt/dtf; 
   nticks = size(ticks,1); nticks = dtf*(nticks+1); 
   yyt = ((0:nticks-1)'-dtf)*dt + ticks(1,1);
   mmt = ones(nticks,1);
   ddt = mmt;
   HHt = zeros(nticks,1);
   MMt = HHt;
   SSt = MMt;
   ticks = datenum([yyt mmt ddt HHt MMt SSt]);
   inticks = (((ticks>=tlim(1))+(ticks<=tlim(2)))>1);
   ticks = ticks(inticks);
   inticks = sum(inticks(inticks));
   if inticks<MinDayTicks
    [returndf,df,dateform] = change_dateform(axh,ax,12,keep_limits);
    ticks = get(axh,[ax 'Tick']);
    inticks = (((ticks>=tlim(1))+(ticks<=tlim(2)))>1);
    ticks = ticks(inticks);
    inticks = sum(inticks(inticks));   
   end
  end
 end
end

%% Only odd ticks:
if fixhigh
 while inticks>MaxDayTicks 
  ticks = ticks(1:2:end);
  inticks = sum(((ticks>=tlim(1))+(ticks<=tlim(2)))>1);
 end 
end

%% Return to previous dateform:
if returndf 
 datetickdata = getappdata(axh,'datetickdata');
 datetickdata.dateform = df;
 setappdata(axh,'datetickdata',datetickdata);
end

%% Return to previous dateform:
if return17 
 datetickdata = getappdata(axh,'datetickdata');
 datetickdata.dateform = dftemp;
 setappdata(axh,'datetickdata',datetickdata);
end

%% New labels with other language months (dateform==6)
if dateform==6
 dateform = df6;
 labels = datestr(ticks,dateform,language);
else
 labels = datestr(ticks,dateform,language);
end

%% Sets new ticks: 
if keep_limits
   set(axh,[ax,'tick'],ticks,[ax,'ticklabel'],labels)
else
   set(axh,[ax,'tick'],ticks,[ax,'ticklabel'],labels, ...
      [ax,'lim'],[min(ticks) max(ticks)])
end


function [returndf,df,dateform] = change_dateform(axh,ax,newdf,keep_limits)
% Just to change the dateform
returndf = 1;
datetickdata = getappdata(axh,'datetickdata');
df = datetickdata.dateform;
if isempty(df)
 dateform = newdf;
 datetickdata.dateform = dateform;
 setappdata(axh,'datetickdata',datetickdata);
 if keep_limits
  tlabel(axh,ax,dateform,'keeplimits')
 else
  tlabel(axh,ax,dateform)
 end
else
 dateform = df;
end


function link_axes(axh,ax,linknottime)
% Links the time axes.

key = 'graphics_linkprop';
tlink = linkprop(axh, {[ax 'Tick'], [ax 'TickLabel'], [ax 'Lim']});
if linknottime
 xyz = 'xyz';
 xyz = xyz(xyz~=ax);
 addprop(tlink,[xyz(1) 'Lim'])
 if length(xyz)>1
  addprop(tlink,[xyz(2) 'Lim'])
 end
end
llink = linkprop(cell2mat(get(axh,[ax 'Label'])), 'String');
setappdata(axh(1),key,tlink);
setappdata(get(axh(1),[ax 'Label']),key,llink);
datetickdata = getappdata(axh(1),'datetickdata');
for k = 2:length(axh)
 datetickdata.axh = axh(k);
 setappdata(axh(k),'datetickdata',datetickdata);
end


function [axh,ax,keep_limits,dfunknown] = datetickzoom(varargin)
%function datetickzoom(varargin)
%DATETICKZOOM Date formatted tick labels, automatically updated when zoomed or panned. 
%   Arguments are completely identical to does of DATETICK. The argument
%   DATEFORM is reset once zoomed or panned.
%
%   See also datetick, datestr, datenum

% Modified by Carlos Vargas March 2008

% Added by Carlos Vargas
keep_limits = 0; 
dfunknown = [];

% Do this when ZOOM or PAN:
if nargin==2 && isstruct(varargin{2}) && isfield(varargin{2},'Axes') && isscalar(varargin{2}.Axes)
    datetickdata = getappdata(varargin{2}.Axes,'datetickdata');
    if isstruct(datetickdata) && isfield(datetickdata,'axh') && datetickdata.axh==varargin{2}.Axes
        axh = datetickdata.axh;
        ax = datetickdata.ax;
        dateform = datetickdata.dateform;
        
        % Added by Carlos Vargas
        if ischar(dateform)
         dfunknown = dateform;
         dateform = [];
        end
         
        keep_ticks = datetickdata.keep_ticks;
        if keep_ticks
            set(axh,[ax,'TickMode'],'auto')
            if ~isempty(dateform)
                datetick(axh,ax,dateform,'keeplimits','keepticks')
            else
                datetick(axh,ax,'keeplimits','keepticks')
            end
        else
            if ~isempty(dateform)
                datetick(axh,ax,dateform,'keeplimits')
            else
                datetick(axh,ax,'keeplimits')
            end
        end
        
    % Added by Carlos Vargas
        keep_limits = 1;     
    else
     axh = []; ax = []; keep_limits = [];
     
    end

% Do this when using TLABEL:
else        
 
    % Modified by Carlos Vargas:
    % [axh,ax,dateform,keep_ticks] = parseinputs(varargin);
    [axh,ax,ax,dateform,keep_ticks,keep_limits] = parseinputs(varargin);
    
    datetickdata = [];
    
    % Modified by Carlos Vargas:
    % datetickdata.axh = axh;
    datetickdata.axh = axh(1);
    datetickdata.ax = ax;
    datetickdata.dateform = dateform;
    datetickdata.keep_ticks = keep_ticks;
    
    % Modified by Carlos Vargas:
    % setappdata(axh,'datetickdata',datetickdata);
    % set(zoom(axh),'ActionPostCallback',@datetickzoom)
    % set(pan(get(axh,'parent')),'ActionPostCallback',@datetickzoom)
    % datetick(varargin{:})
    setappdata(axh(1),'datetickdata',datetickdata);
    set(zoom(axh(1)),'ActionPostCallback',@tlabel) 
    set(pan(get(axh(1),'parent')),'ActionPostCallback',@tlabel)
    if length(axh)>1, varargin{1} = axh(1); end
    try % Try for dateform thiferent from 0:29 
     datetick(varargin{:})
    catch ME
     if isequal(ME.identifier,'MATLAB:datetick:UnknownDateFormat')
      dfunknown = dateform;
      if keep_limits
       if keep_ticks
        datetick(axh(1),ax,'keeplimits','keepticks')
       else
        datetick(axh(1),ax,'keeplimits')
       end
      elseif keep_ticks
       datetick(axh(1),ax,'keepticks')
      else
       datetick(axh(1),ax)
      end
     else
      error(ME)
     end
    end
end

% Added by Carlos Vargas
if ~nargout
 clear axh
end


function [axh,nin,ax,dateform,keep_ticks,keep_limits] = parseinputs(v)
%Parse Inputs

% Copied from DATETICK by Carlos Vargas

% Defaults;
dateform = [];
keep_ticks = 0;
keep_limits = 0;
nin = length(v);

% check to see if an axes was specified
% Modified by Carlos Vargas
% if nin > 0 & ishandle(v{1}) & isequal(get(v{1},'type'),'axes') %#ok ishandle return is not scalar
if nin > 0 & ishandle(v{1}) & isequal(get(v{1}(1),'type'),'axes') %#ok ishandle return is not scalar
    % use the axes passed in
    axh = v{1};
    v(1)=[];
    nin=nin-1;
else
    % use gca
    axh = gca;
end

% check for too many input arguments
error(nargchk(0,4,nin,'struct'));

% check for incorrect arguments
% if the input args is more than two - it should be either
% 'keeplimits' or 'keepticks' or both.
if nin > 2
    for i = nin:-1:3
        if ~(strcmpi(v{i},'keeplimits') || strcmpi(v{i},'keepticks'))
            % Modified by Carlos Vargas:
            % error('MATLAB:datetick:IncorrectArgs', 'Incorrect arguments');
            error('Datetickzoomall:IncorrectArgs', 'Incorrect arguments');
        end
    end
end


% Look for 'keeplimits'
for i=nin:-1:max(1,nin-2),
   if strcmpi(v{i},'keeplimits'),
      keep_limits = 1;
      v(i) = [];
      nin = nin-1;
   end
end

% Look for 'keepticks'
for i=nin:-1:max(1,nin-1),
   if strcmpi(v{i},'keepticks'),
      keep_ticks = 1;
      v(i) = [];
      nin = nin-1;
   end
end

if nin==0, 
   ax = 'x';
else
 
  % Added by Carlos Vargas
  if isempty(v{1}), ax = 'x'; else
   
    switch v{1}
   case {'x','y','z'}
      ax = v{1};
   otherwise
      % Modified by Carlos Vargas:
      %error('MATLAB:datetick:InvalidAxis', 'The axis must be ''x'',''y'', or ''z''.');
      error('Datetickzoomall:InvalidAxis', 'The axis must be ''x'',''y'', or ''z''.');
   end
   
  end
 
end


if nin > 1
     % The dateform (Date Format) value should be a scalar or string constant
     % check this out
     dateform = v{2}; 
     if (isnumeric(dateform) && length(dateform) ~= 1) && ~ischar(dateform)
         % Modified by Carlos Vargas:
         % error('MATLAB:datetick:InvalidInput', 'The Date Format value should be a scalar or string');
         error('Datetickzoom:InvalidInput', 'The Date Format value should be a scalar or string');
     end 
end