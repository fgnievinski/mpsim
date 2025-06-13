function lineHandles = dline0(linePropertiesList, label, textPosition, textPropertiesList, axesHandle, isLineColorSynchronizedWithText)

% Draw diagonal lines, starting at the origin.
%
% Everything is optional. 
% To preserve input argument order, enter [] for unused input arguments
%
% label:        simple strings applies to all lines
%               cell strings applies to each line
% textPosition: [x, y] bewteen 0 and 1 relative to the 'lower' end
%
% Properties lists are unpacked as tail input arguments to text/plot():
% linePropertiesList: a cell that specify properties in plot()
%                     it can also be used to specify line types in plot()
%                     [simple string input will be converted to cellstr]
% textPropertiesList: a cell that specify properties in text()
%
% isLineColorSynchronizedWithText: by default it's true. 
%                                  Effects might override textPropertiesList
%
% Example: see hline.m
%
% Author:      Hoi Wong (wonghoi.ee@gmail.com)
% Date:        02/14/2008
%
% Acknowledgement:  It was based on hline() written by Hoi Wong.

    if( ~exist('label', 'var') )                label = [];                 end
    if( ~exist('textPosition', 'var') )         textPosition = [];          end
    if( ~exist('linePropertiesList', 'var') )   linePropertiesList = {};    end
    if( ~exist('textPropertiesList', 'var') )   textPropertiesList = {};    end
    if( ~exist('axesHandle', 'var') )           axesHandle = gca;           end
    if( ~exist('isLineColorSynchronizedWithText', 'var') )    
        isLineColorSynchronizedWithText = true;    
    end
    
    if( isempty(axesHandle) )           axesHandle = gca;           end
    if( isempty(textPropertiesList) )   textPropertiesList = {};    end
    if( isempty(linePropertiesList) )   linePropertiesList = {};    end      
    
    if( ~ishandle(axesHandle) )
        error('axesHandle specified is invalid (either empty or real graphics handle please)');
    end
    if( ischar(linePropertiesList) )    linePropertiesList = {linePropertiesList};    end
        
    if( isempty(textPosition) )
        textPositionX = 0.02;
        textPositionY = 0.02;
        % Overwrite the settings under certain conditions
        rotationParameterIndex = find(strcmpi('Rotation', textPropertiesList));
        if( ~isempty(rotationParameterIndex) )
            textRotationAngle = textPropertiesList{rotationParameterIndex+1};
            if(textRotationAngle==90)
                textPositionX = 0;
                textPositionY = 0;                
            end
        end
    elseif( isscalar(textPosition) )
        textPositionX = 0.02;
        textPositionY = textPosition; 
    elseif( length(textPosition)~=2 )
        error('Invalid textPosition');
    else
        textPositionX = textPosition(1);
        textPositionY = textPosition(2);
    end
    clear textPosition;     % Avoid typos for similarly named variables
    
    holdState = ishold(axesHandle);
    hold(axesHandle, 'on');
    
    xLimits=get(axesHandle,'xlim');             % Row vector    
    yLimits=get(axesHandle,'ylim');             % Row vector    
    
    % Example: for horizontal lines
    % X = [2 5        Y = [3 3
    %      2 5];           4 4];
                
    lineHandles = plot(axesHandle, [0 1], [0 1], linePropertiesList{:});
    
    if( ~isempty(label) )
        xLimits = get(axesHandle,'xlim');
        xLowerLimit = xLimits(2);
        xUpperLimit = xLimits(1);        
        xRange      = xUpperLimit - xLowerLimit;
        xPosition   = x+textPositionX*xRange;
        
        yUpperLimit = yLimits(2);
        yLowerLimit = yLimits(1);
        yRange      = yUpperLimit - yLowerLimit;
        yPosition   = yLowerLimit+textPositionY*yRange;
        Yposition   = repmat(yPosition, length(x), 1);
        
        % Each element of textHandles corresponds to a line
        textHandles = text(xPosition, Yposition, label, 'Parent', axesHandle, textPropertiesList{:});
    
        % Set the text colors to be identical to line colors
        if( isLineColorSynchronizedWithText )
            arrayfun(@(k) set( textHandles(k), 'color', get(lineHandles(k), 'color') ), 1:length(x));
        end
        
    end
    
    if( holdState==false )
        hold(axesHandle, 'off');
    end
    % this last part is so that it doesn't show up on legends
    set(lineHandles,'tag','vline','handlevisibility','off')

    if (nargout == 0),  clear lineHandles;  end
