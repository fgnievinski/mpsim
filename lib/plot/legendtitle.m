%  legendTitle  - add a title to a legend
%
%   Add a title to a legend 
%
%      hTitle = legentTitle ( hLegend, string, argPairs )
%
%      hLegent = handle to the legend for the title to be added
%      string  = text string of title
%      argPairs = all valid arg pairs for a title object
%
%   example:
%    % To add a title:
%    plot(x,besselj(1,x),x,besselj(2,x),x,besselj(3,x));
%    hLegend = legend('First','Second','Third','Location','NorthEastOutside');
%    hTitle = legendTitle ( hLegend, 'Leg Title', 'FontWeight', 'bold' );
%
%    % To remove a title:
%    hTitle = legendTitle ( hLegend )
%       
%  see also legend, title, axes
%   
% Copyright Robert Cumming @ Matpi Ltd.
% www.matpi.com
%
function h = legendTitle ( hLegend, string, varargin )
  h = [];
  % check if HG2
  if ~verLessThan('matlab', '8.4')
    if nargin == 1; % method for deleting the title
      delete ( hLegend.UserData.legendTitle.ax ); 
      return
    end
    % check if this is a subsequent call to the legend
    if ~isfield ( hLegend.UserData, 'legendTitle' )
      % get the position on the legend
      initPosition = hLegend.Position;
      % set the height to be very small
      initPosition(4) = 1e-2;
      % create an axes (we do it this way to mimick the original method)
      ax = axes ( 'parent', hLegend.Axes.Parent, 'position', initPosition, 'HandleVisibility', 'off' );  
      % store the axes in the legend user data
      hLegend.UserData.legendTitle.ax = ax;
      % add listeners for figure position, legend position & location and legend being deleted
      addlistener ( ancestor ( hLegend, 'figure' ), 'SizeChanged', @(obj,event)UpdateLegendTitlePosition( hLegend, ax ));
      addlistener ( hLegend, 'Position', 'PostSet', @(obj,event)UpdateLegendTitlePosition( hLegend, ax ));
      addlistener ( hLegend, 'Location', 'PostSet', @(obj,event)UpdateLegendTitlePosition( hLegend, ax ));
      addlistener ( hLegend, 'ObjectBeingDestroyed', @(obj,event)legendTitle( hLegend ));
    else
      % extract the pointer to the  axes
      ax = hLegend.UserData.legendTitle.ax;
    end
    % give the axes a title, passing in all the extra args
    h = title ( ax, string, varargin{:} );    
    % update the position
    UpdateLegendTitlePosition( hLegend, ax );
  else
    % to give both methods the same appearance - delete the title by
    % setting the string to '';
    if nargin == 1
      h = get ( hLegend, 'title' );
      set ( h, 'string', '' );
    else
      % get the handle tot he title
      h = get ( hLegend, 'title' );
      % set the string properties.
      set ( h, 'string', string, varargin{:} );
    end
  end
end
% callback to update the legend position.
function UpdateLegendTitlePosition( hLegend, hAxes )
  % flag for changing positions or not
  changeUnits = false;
  % Check legend units
  if ~strcmp ( hLegend.Units, 'normalized' )
    % take a copy of the user units
    userUnits = hLegend.Units;
    % update the internal flag
    changeUnits = true;
    % change the units to normalised
    hLegend.Units = 'normalized';
  end
  % extract the legend position
  position = hLegend.Position;
  % update the position of the axes
  hAxes.Position(1:3) = [position(1) position(2) + position(4) position(3)];
  % hide the axes
  hAxes.Visible = 'off';
  % show the title
  hAxes.Title.Visible = 'on';
  % if we changed the units set them back
  if changeUnits
    hLegend.Units = userUnits;
  end
end