function [h] = pp(varargin)

%PP  Plots and manipulates polar plots
%
%   PP(THETA,R) plots the polar representation of THEATA and R with the 
%   centre and max values being the minimum and maximum values of R.
%
%   PP(THETA,R,S) plots as above, where S is a character string made from
%   standard plotting formatting in the PLOT function. See HELP PLOT.
%
%   PP(THETA,R,A) plots as above, but within the axis limits of A. A is 
%   a 1x2 or 2x1 array containing the centre value and maximum value of 
%   the polar plot ring axes.
%
%   PP(THETA,R,'Property 1',...) plots as above with the selected 
%   properties. See below for propterties. 
%
%   PP('Property 1',...) edits the current figure (if it is a polar plot 
%   figure) to the assigned properties.
%
%   PP('Trace', 3, 'Property 1', ... , 'Trace', 1, 'Property 10', ... )
%   changes properties of trace 3 and trace one. Any properties defined
%   after the trace belong to that trace until a new trace number is 
%   defined.
%
%             PROPERTIES:            DEFAULT          POSSIBLE
%           ---------------        -----------       ----------
%
%   GENERAL PLOTTING:
%          'ThetaDirection'            'ccw'          'cw','ccw'
%          'LineStyle'                 '-'             see PLOT 
%          'LineWidth'                  1              1,2,...
%          'LineColor'                 'b'             see PLOT or RGB vector
%          'Marker'                    'none'          see PLOT
%          'ThetaStartAngle'            0              0-360
%          'ppStyle'                    0              0,1,2
%
%   AXES RANGE:
%          'MaxValue'                  'max'           numeric value (greater than CetreValue)
%          'CentreValue'               'min'           numeric value (less than MaxValue)
%
%   ANGLE AXIS:
%          'AngleAxis'                 'on'           'on','off','none'
%          'AngleStep'                  30             numeric value
%          'AngleAxisStyle'            ':'             see PLOT
%          'AngleAxisColor'             black          see PLOT or RGB vector
%          'AngleLineWidth'             1              1,2,...
%          'AngleLabel'                'on'           'on','off','none'
%          'AngleLabelStep'             same as axis   numeric value
%          'AngleFontSize'              10             numeric value
%          'AngleFontColor'             black          see PLOT or RGB vector
%          'AngleFontWeight'           'normal'       'normal','bold','light','demi'
%          'AngleDegreeMark'           'off'          'off',0, 'on',1
%
%   RING AXIS:
%          'NumRings'                   4              integer value >= 0    
%          'RingAxis'                  'on'           'on','off','none'
%          'RingAxisStyle'             ':'             see PLOT
%          'RingAxisColor'              black          see PLOT or RGB vector
%          'RingStep'            cal. from No. rings   integer value > 0
%          'RingTick'           
%          'RingTickLabel'           
%          'RingLineWidth'              0.1            1,2,...
%          'RingLabel'                 'on'           'on','off','none'
%          'RingFontSize'               10             numeric value
%          'RingFontWeight'            'normal'       'normal','bold','light','demi'
%          'RingFontColor'              black          see PLOT or RGB vector
%          'AxisOuterRingStyle'        '-'             see PLOT
%          'RingUnits'                 ''              Some String Value
%          'MagMarkAngle'               45             0-360
%
%   FIGURE PROPERTIES:
%          'FigurePosition'                      
%          'FigureBackgroundColor'    
%          'PlotBackgroundColor'              
%          'PlotBorderColor'                  
%          'PlotBorderLineColor'      
%
%   TRACE:
%          'Trace'                      1              any trace number
%          'LineStyle'                 '-'             see PLOT 
%          'LineWidth'                  1              1,2,...
%          'LineColor'                 'b'             see PLOT or RGB vector
%          'Marker'                    'none'          see PLOT
%          'RhoData'                   
%          'ThetaData'
%
%   OTHER:
%          'SetupVariables'
%          'Axes'                     
%

% Author:         Robert Schlub
% Last Modified:  4th December 2002


%Setup global variables that will be used within function blocks
clear global DB args oc NewTrace Traces CreateNewFigure r theta tc axis_limits HoldWasOn ErrorFlag ppStyle;
global DB args oc NewTrace Traces CreateNewFigure r theta tc axis_limits HoldWasOn ErrorFlag ppStyle;

%default settings
tc = struct( 'line_color',    [0 0 1]            ,...   % RGB or PLOT value of line color
    'line_style',             '-'                ,...   % line style string same as PLOT function
    'line_width',             1                  ,...   % line width of trace
    'line_marker',            'none'             ,...   % line marker style
    'trace_index',            1                  ,...   % trace number identifier
    'trace_string',           ''                 );%    % trace string identifier


oc = struct( 'theta_start',            0         ,...   % theta start angle in degrees
    'angle_step',             30                 ,...   % number of theta markers                   
    'angle_label_step',       0                  ,...   % number of theta labels
    'number_of_rings',        4                  ,...   % number of magnitude rings
    'max_mag',                'max'              ,...   % maximum ring magnitude ('max' makes data's max value it)
    'centre_value',           'min'              ,...   % minimum ring value (centre value)
    'background_color',       [0.8 0.8 0.8]      ,...   % background color
    'theta_direction',        'ccw'              ,...   % direction of theta increment
    'ring_step',              0                  ,...   % step size of rings
    'ring_tick',              []                 ,...   % 
    'mag_mark_angle',         45                 ,...   % angle of magnitude labels
    'axes_hold',              'off'              ,...   % flag to tell whether axis hold is on or off
    'ring_color',             'k'                ,...   % ring axis color
    'ring_style',             ':'                ,...   % ring axis style
    'ring_line_width',       0.1                 ,...   % ring axis line width
    'ring_border_line_width',0.5                 ,...   % ring border line width
    'angle_axis',             ''                 ,...   % angle axis is ON or OFF
    'angle_color',            'k'                ,...   % angle axis color
    'angle_style',            ':'                ,...   % angle axis style
    'angle_label',            ''                 ,...   % angle axis labels are ON or OFF
    'angle_line_width',      0.1                 ,...   % angle axis line width
    'angle_font_size',        10                 ,...   % angle axis font size
    'angle_font_color',       'k'                ,...   % angle axis font color
    'angle_font_weight',      'normal'           ,...   % angle axis font weight
    'angle_tick_label',        []                ,...   % user-defined angle tick labels
    'angle_degree_mark',      'off'              ,...   % degree symbol placed with angle text
    'angle_units',            ''                 ,...   % angle units string
    'check_voids',            'on'               ,...   % 
    'ring_axis',              ''                 ,...   % ring axis is ON or OFF
    'ring_label',             ''                 ,...   % ring axis labels are ON or OFF
    'ring_tick_label',        []                 ,...   % user-defined ring axis tick labels
    'ring_font_size',         10                 ,...   % ring axis font size
    'ring_font_color',        'k'                ,...   % ring axis font color
    'ring_font_weight',       'normal'           ,...   % ring axis font weight
    'figure_position',        [300 150 583 500]  ,...   % figure position and size
    'outer_ring_style',       '-'                ,...   % ring axis border style
    'ring_units',             ''                 ,...   % ring axis units string
    'plot_area_color',        [1 1 1]            ,...   % color inside ring axes (the plot area)
    'circ_border_color',      ''                 ,...   % color of circular border
    'circ_border_line_color', ''                 );%    % color of line defining circular border



%First Argument defines what is expected as the user input to say which option is wanted
%First Flag is: 1 if there is data expected after the argurment
%               0 if no data expected but contents of third column gets copied into 4th column variable
%Second Flag is : s if string data only is expected
%                 v if numerical data only is expected (values) 
%                 vs if numerical or string data can be accepted
%                 st if structure data expected
%Final string variable points to which variable which the corresponding data is to be assigned to

%           Argument        flag flag  variable to alter
args = {'SetupVariables'           1 'st'  'oc'                          %initial setup variables
    'ThetaDirection'       1 's'   'oc.theta_direction'          %theta direction (CW/CCW)
    'CentreValue'              1 'vs'  'oc.centre_value'             %centre value of graph
    'MaxValue'                 1 'vs'  'oc.max_mag'                  %max value of graph
    'LineStyle'                1 's'   'Traces{TraceIndex*2}.line_style'               %trace style
    'LineWidth'                1 'v'   'Traces{TraceIndex*2}.line_width'               %trace width
    'LineColor'                1 'vs'  'Traces{TraceIndex*2}.line_color'               %trace color
    'Marker'                   1 's'   'Traces{TraceIndex*2}.line_marker'              %trace marker style
    'ThetaStartAngle'          1 'v'   'oc.theta_start'              %theta start angle (refer note below)
    'AngleAxis'                1 's'   'oc.angle_axis'               %angle axis is ON or OFF
    'AngleStep'                1 'v'   'oc.angle_step'               %angle axis step size (between axes)
    'AngleAxisStyle'           1 's'   'oc.angle_style'              %angle axis style
    'AngleAxisColor'           1 'vs'  'oc.angle_color'              %angle axis color
    'AngleLineWidth'           1 'vs'  'oc.angle_line_width'         %angle axis line width
    'AngleLabel'               1 's'   'oc.angle_label'              %angle axis label is ON or OFF
    'AngleLabelStep'           1 'v'   'oc.angle_label_step'         %angle axis label step size
    'AngleFontSize'            1 'v'   'oc.angle_font_size'          %angle axis label font size
    'AngleFontColor'           1 'vs'  'oc.angle_font_color'         %angle axis font color
    'AngleFontWeight'          1 's'   'oc.angle_font_weight'        %angle axis label font weight
    'AngleDegreeMark'          1 'vs'  'oc.angle_degree_mark'        %marks the degrees character with angle text
    'AngleTickLabel'           1 'v'   'oc.angle_tick_label'         %user-defined angle tick labels
    'AngleUnits'               1 's'   'oc.angle_units'              %user-defined angle units
    'CheckVoids'               1 's'   'oc.check_voids'              %
    'NumRings'                 1 'v'   'oc.number_of_rings'          %ring axes number
    'RingAxis'                 1 's'   'oc.ring_axis'                %ring axis is on or off
    'RingAxisStyle'            1 's'   'oc.ring_style'               %ring axis style
    'RingAxisColor'            1 'vs'  'oc.ring_color'               %ring axis color
    'RingStep'                 1 'v'   'oc.ring_step'                %ring axis step size
    'RingTick'                 1 'v'   'oc.ring_tick'                %ring axis step size
    'RingBorderLineWidth'      1 'v'   'oc_ring_border_line_width'   %ring border line width
    'RingLineWidth'            1 'vs'  'oc.ring_line_width'          %ring axis line width
    'RingLabel'                1 's'   'oc.ring_label'               %ring axis labeling is ON or OFF
    'RingTickLabel'            1 'v'   'oc.ring_tick_label'          %user-defined ring axis tick labels
    'RingFontSize'             1 'v'   'oc.ring_font_size'           %ring axis label font size
    'RingFontWeight'           1 's'   'oc.ring_font_weight'         %ring axis label font size
    'RingFontColor'            1 'vs'  'oc.ring_font_color'          %ring axis font color
    'AxisOuterRingStyle'       1 's'   'oc.outer_ring_style'         %ring axis border (circumference) style
    'RingUnits'                1 's'   'oc.ring_units'               %ring axis label units
    'MagMarkAngle'             1 'v'   'oc.mag_mark_angle'           %ring axis label angle
    'FigurePosition'           1 'vs'  'oc.figure_position'          %position and size of figure on screen
    'FigureBackgroundColor'    1 'vs'  'oc.background_color'         %figure background color (outside plot area)
    'PlotBackgroundColor'      1 'vs'  'oc.plot_area_color'          %plot area background color
    'PlotBorderLineColor'      1 'vs'  'oc.circ_border_line_color'   %circular border line color
    'PlotBorderColor'          1 'vs'  'oc.circ_border_color'        %circular border color
    'Axis'                     1 'vs'  'axis_limits'                 %limits of axis
    'Axes'                     1 'vs'  'axis_limits'                 %limits of axes (as in plural spelling but same result)
    'Trace'                    1 'v'   'TraceIndex'                  %current trace number - used to edit plot parameters of the trace
    'ThetaData',               1 'v'   'Traces{TraceIndex*2-1}(:,2)'     %Theta data
    'RhoData',                 1 'v'   'Traces{TraceIndex*2-1}(:,1)'     %Rho Data
    'ppStyle',                 1 'v'   'ppStyle'                     %A style of axes presentation
};
%NOTES:
%ThetaStartAngle is relative to the direction of theta. ie, a start angle of 90 will be 180 differnt between
%clock wise and counter clock wise direction of theta.

%Setup a space for Traces
Traces = '';

%set up the variable axis limits. It is a 1x2 array whose first element contains the centre value and second
%element contains the max magnitude. 
axis_limits = [0 0];

%If ErrorFlag ever goes to 1 then will be quitting out
ErrorFlag = 0;

%Set default value of ppStyle
%Style Types:
%              0: No Changes
%              1: Default
%              2: Grey solid axes with 'dB' as ring units and degree marks present
%
ppStyle = 0;














%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                       %
%                                         MAIN                                          %
%                                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%First check all input arguments and ensure they are valid. Also get back a flag to say whether the new data 
%is being added or not (if not, then simple figure/axes/current_trace properties are being changed
CheckInput(varargin);
if ErrorFlag, return; end

%if NewTrace == 0 or hold is on, then load the user_data from the current figure and fill 'oc' and 'Traces'
LoadExistingData;
if ErrorFlag, return; end

%Assign input arguments to their corresponding variables
AssignInput(varargin); %this will overwrite any varibales in oc etc that have been updated
if ErrorFlag, return; end

AssignStyle(ppStyle);
if ErrorFlag, return; end

CheckAxisLimits;
if ErrorFlag, return; end

CheckPlotLimits;
if ErrorFlag, return; end

SetupFigure;

%Save Userdata to figure
UserData{1} = 'Bobs Polar Plot';
UserData{2} = oc;
UserData = [UserData Traces];
set(gcf,'UserData', UserData);      %save updated trace data into figure

PlotAxes;
for i=1:2:length(Traces)
    ThetaPlot = SetupTheta(  Traces{i}(:,2)  );
    DB = 0;
    if(i>1)
        DB = 1;
%       keyboard
    end

    [RPlot ThetaPlot PlotProperties] = SetupR(  Traces{i}(:,1)  ,  ThetaPlot  );
    h=PlotTrace(ThetaPlot, RPlot, PlotProperties, Traces{i+1});
    if (nargout < 1),  clear h;  end
end

if HoldWasOn == 0
    hold off
end















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                       %
%                                     CHECK INPUT                                       %
%                                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This function will go through the input string entered into pp(). It will simply ensure
%valid ordering of commands and will assign NewTrace a value depending on if Trace Data
%is present or not in the input arguments

function CheckInput(VariableArgIn)

global args NewTrace ErrorFlag;

%find the number or inputs and the number of possible arguments
num_inputs = length(VariableArgIn);

m = 0;
NewTrace = 0;   %This is set if there is data (in the form of a trace) to be added to the plot

%now, step through all the arguments and compare them to valid arguments
while m < num_inputs   %number of inputs into function (ie number of variables separated by commas)
    m = m + 1;
    n = 0;
    
    %if the first element is numeric check the second element to ensure it is also numberic and the same length
    %as theta and r must be the same sizes
    if m == 1 & isnumeric(VariableArgIn{m})
        %check to make sure there is a second input argument
        if num_inputs < 2
            DispError('No Rho values Present');
            return
        end
        if isnumeric(VariableArgIn{m+1}) & max(length(VariableArgIn{m+1})) == max(length(VariableArgIn{m}))
            m = 2;   %move to after the RHO element which was just analysed
            %now check to see if the next input is the axes limits (it will be if its a numeric value)
            %this is the only case the third input can be numeric (without a property identifier)
            if num_inputs > 2
                if isnumeric(VariableArgIn{m+1})     %m = 3 now 
                    m = 3;  %move to after the AXIS LIMITS variable which was just analysed
                end
            end              
        else
            DispError('THETA and R must be an equal length 1xm or mx1 array or variables');
            return
        end
        
        %if we have got here without error then there is a valid new trace being added or created
        NewTrace = 1;
        continue; %skip through to start of while loop again
    end
    
    %search for the string in the args array and return the args index
    index = FindArgsIndex(VariableArgIn{m});
    
    %if an index was found and another agument is expected to complete it, then ensure that 
    %the input after it is valid (string, value of struct)
    if index > 0 & args{index,2} == 1              %if another argument is expected to complete this one
            if m + 1 > num_inputs       %if there is no more completeing argument    
                DispError(['No input argument for "' VariableArgIn{m} '"'])  %exit
                return
            end
            %check 2nd flag of args to see if string or number is expected
            switch args{index,3}
            case 'v'                                         %assign variable with number       
                if ischar(VariableArgIn{m+1})
                    DispError(['The input argument for "' VariableArgIn{m} '" must be numerical']);
                    return
                end        %note the lack of break sends the case through to string check
            case 's'                                         %assign variable with string
                if ischar(VariableArgIn{m+1}) == 0
                    DispError(['The input argument for "' VariableArgIn{m} '" must be a string']);
                    return
                end         
            case 'vs'
                if (ischar(VariableArgIn{m+1}) == 0 & isnumeric(VariableArgIn{m+1}) == 0)
                    DispError(['The input argument for "' VariableArgIn{m} '" must be either numerical, or a string (not a cell, struct etc.)']);
                    return
                end
            case 'st'  %the only structure  is the 'SetupVariables' cell
                if isstruct(VariableArgIn{m+1}) == 0
                    DispError(['The input argument for "' VariableArgIn{m} '" must be a structure']);
                    return
                end
            end
            m = m+1;  %increment the m counter so that input of the argument is not checked as an argument
        
    %in the case that the string wasn't found in args, it might be a standard plotting string. This will only
    %happen if m = 3 and a trace is being added. If thats the case then ensure then ensure the string is valid
    elseif index == 0 & m == 3 & NewTrace & length(VariableArgIn{m}) <= 4
        CheckStandardPlot(VariableArgIn{m});     %this will quit out if there is a syntax error in the string
        if ErrorFlag, return; end

        %Otherwise the string is not valid
    else
        DispError(['The argument "' VariableArgIn{m} '" is not valid. See help']);
        return
    end 
end














%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                       %
%                      LoadExistingData - LOAD EXISTING DATA                            %
%                                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%If hold is on or existing figure properties are being modified, then load the existing figures user_data
function LoadExistingData

global Traces oc NewTrace CreateNewFigure HoldWasOn;

%Default is to Create a new figure
CreateNewFigure = 1;

%Default HoldWasOn flag is 0 (ie hold was not on)
HoldWasOn = 0;

if max(findobj) ~= 0
    %if hold is on then set the HoldWasOn flag so it can be turned on after all plotting complete

    if ishold
        HoldWasOn = 1;
    end
    
    %if the current figure has hold on or we are editing an existing figure then we need to check to make sure its valid
    if ishold | NewTrace==0    
        user_data = get(gcf, 'UserData');
        if ~strcmp(user_data{1}, 'Bobs Polar Plot')
            DispError('Current figure is not a valid polar plot figure - it must be created using the pp function');
            return
        end

        %If the figure is valid, then load the oc structure from it
        oc = user_data{2};

        %Load the existing Traces
        if(length(user_data)>2)
            Traces = cell(1,length(user_data)-2);
            for i=1:length(user_data)-2
                Traces{i} = user_data{i+2};
            end
        end
        
        %if hold is on, or just properties are being added then we don't want to be creating a new figure later on
        CreateNewFigure = 0;
    end
    %Otherwise if no figure is present but no new trace data exists then there is an error
elseif NewTrace == 0
    DispError('No figure to modify properties of');
    return
end





















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                       %
%                                     ASIGN INPUT                                       %
%                                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function AssignInput(VariableArgIn)

global theta r args axis_limits NewTrace Traces tc oc ppStyle;

num_inputs = length(VariableArgIn);

%set default trace
TraceIndex = 1;

m = 0; %needs to be zero for the while loop 35 lines below

%First assign theta, r and axis_limits if a new trace is being entered
if NewTrace

    %If a trace is being added append two cells on the end of Traces (one for the r/theta values
    %and the other for tc)
    Traces = [Traces cell(1,2)];
    
    %set the trace number an unassigned number
    TraceIndex = length(Traces)/2;
    
    %setup the default trace properties structure;
    tc.trace_index = TraceIndex;
    Traces{TraceIndex*2} = tc;

    m = 1;    %Look at the first element of VariableArgIn (which should be the theta data)

    theta = VariableArgIn{m};  %Get the Theta Data
    
    r = VariableArgIn{m+1};   %Get the Rho Data

    %set theta, rho and original theta to be column vectors if they aren't already
    [rows cols] = size(theta);
    if rows == 1
        theta = theta';
    end
    [rows cols] = size(r);
    if rows == 1
        r = r';
    end

    %assign the theta and r values to the appropriate trace
    Traces{TraceIndex*2-1} = [r theta];

    m = 2;   %move to the RHO element which was just analysed
    
    %now check to see if the next input is the axes limits (it will be if its a numeric value) or
    %the standard plot string (it will be if its a string that can't be found)
    if num_inputs > 2
        %if numeric, then must be axis limits
        if isnumeric(VariableArgIn{m+1})     %m = 2 now (3 lines up)
            axis_limits = VariableArgIn{m+1};
            m = 3;  %move to the axis limits variable which was just analysed
                          
        %if string and non existant in args, then must be standard plotting values
        elseif FindArgsIndex(VariableArgIn{m+1}) == 0
            [Color, Marker, Style] = CheckStandardPlot(VariableArgIn{m+1});     
            %Assign the color, marker and style if they were defined

            if ~isempty(Color)
                Traces{TraceIndex*2}.line_color = Color;
            end
            if ~isempty(Marker)
                Traces{TraceIndex*2}.line_marker = Marker;
            end
            if ~isempty(Style)
                Traces{TraceIndex*2}.line_style = Style;
            end              
            m = 3;
        end 
    end
end

%now, step through all the remaining string arguments and compare them to valid arguments (in args)
while m < num_inputs   %number of inputs into function (ie number of variables separated by commas)
    m = m + 1;
    
    %find the index in args of the current input argument - we know the index exists as error checking
    %has been done previously
    index = FindArgsIndex(VariableArgIn{m});
    
    %if another argument is expected to complete this one then assign it (error checking has already
    %been performed)
    if args{index,2} == 1
        eval([args{index,4} '= VariableArgIn{m+1};'])
        m = m+1;  %increment the m counter so that input of the argument is not checked as an argument
    else   %if no other arugument is needed assign third colum of args to variable in 4th column
        eval([args{index,4} '= args{index,3}']);
    end         
end   

%NOTES:
%
%     TaceIndex:       The user must enter the argument "..., 'Trace', 3, ..." for trace parameters
%                      of trace 3 to be altered. In doing so, the while loop above will set TraceIndex
%                      to 3. Afterwards, when line style/color etc are altered the evaluation
%                      'Traces{TraceIndex*2}.line_style' (see args) will be used so trace 3 will have
%                      its properties successfully altered.






















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                       %
%                                FIND ARGS INDEX                                        %
%                                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [index] = FindArgsIndex(StringToFind)
global args;
index = 1;    %start at the first row

%search through the args struct till find index varibale in StringToFind
while ~strcmp(args{index,1},StringToFind) 
    index = index + 1;
    
    %if searched through entire args rows and couldn't find a match then break and return 0
    if index > length(args(:,1))
        index = 0;
        break;
    end
end




















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                       %
%                             CHECK AXIS LIMITS                                         %
%                                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function CheckAxisLimits
global oc axis_limits args

%check to see if the axis_limits array elments are empty. If they are not, then it means they have been
%filled by the user in the arguments of the function call. Therefore, change the appropriate centre value 
%and/or maximum magnitude. Because this happens after the assigning of arguments and their variables (above),
%then if the 'CentreValue' or 'MaxMag' arguments were used, then they will be overwritten by the axis_limits
if isnumeric(axis_limits) & (size(axis_limits) == [1 2] | size(axis_limits) == [2 1])
    %if both are zero then user hasn't changed axis (or if they have entered [0 0], then its invalid 
    %because you can't have centre value and max mag equal and therefore this pretends that they haven't 
    %been this stupid on purpose)   
    if axis_limits(1) ~= 0 | axis_limits(2) ~= 0
        %but sometimes, you just have to protect the users from themselves
        if axis_limits(1) == axis_limits(2) 
            disp(' ');disp('Cannot make centre value and maximum mag value the same');disp(' ');
        else
            %if valid then assign the centre and max variables to their vew values 
            oc.centre_value = axis_limits(1);                      %set the center value to the first element
            oc.max_mag = axis_limits(2);                           %set the max value to the second element
        end
    end
elseif ischar(axis_limits) & (strcmpi(axis_limits,'off') | strcmpi(axis_limits,'none'))
    oc.ring_axis = 'off';
    oc.angle_axis = 'off';
elseif ischar(axis_limits) & strcmpi(axis_limits,'on')
    oc.ring_axis = 'on';
    oc.angle_axis = 'on';
else
    DispError('"Axis" must be followed by 1x2 or 2x1 numerical vector, or by "on", "off" or "none" strings');
    return
end

















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                       %
%                                  SETUP FIGURE                                         %
%                                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetupFigure

global CreateNewFigure oc

%If creating a new figure (flag set in LoadExistingData) then create one
%if CreateNewFigure
%    figure;
%else
    clf reset;   %Otherwise if hold is on, or property modification only, then reset
    %end              %the current figure for full redraw

%Set the figure properties
set(gcf,'Color',oc.background_color,'Position',oc.figure_position)

%Turn hold on for drawing of axes and traces
hold on


















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                       %
%                                     PLOT AXES                                         %
%                                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PlotAxes

global oc r

%check to see if the degrees character is supposed to be plotted or not
%degrees_string = '';
degrees_string = oc.angle_units;
if(min(oc.angle_degree_mark == 1) == 1 | strcmp(oc.angle_degree_mark, 'on'))
    degrees_string = '^{\o}';
end

%angle system for all corresponding axis
phi = 0:0.01:2*pi;

%make a circle for the plot's circular border
if ~isempty(oc.circ_border_line_color) | ~isempty(oc.circ_border_color)
    border_line = 1.3;
    x = border_line*cos(phi);
    y = border_line*sin(phi);
    if ~isempty(oc.circ_border_color)
        fill(x,y,oc.circ_border_color,'LineStyle','none','HandleVisibility','off');
    end
    if ~isempty(oc.circ_border_line_color)
        plot(x,y,'Color',oc.circ_border_line_color,'LineWidth',2,'HandleVisibility','off');
    end
    axis([-1.55 1.55 -1.55 1.55])
else
    axis([-1.2 1.2 -1.2 1.2])
end

%Make up maximum magnitudes and minimum magnitudes
if strcmp(oc.max_mag,'max')
    oc.max_mag = max(r);
end

if strcmp(oc.centre_value, 'min')
    oc.centre_value = min(r);
end
plot_range = oc.max_mag - oc.centre_value;

%Draw the concentric circles (rings)
rings = 1;           %outer ring
if ~isempty(oc.ring_tick)
    rings = oc.ring_tick;
elseif oc.ring_step == 0       %if number of rings defined (default) and not ring step then...
    for i = 1:1:oc.number_of_rings
        rings = [rings (oc.number_of_rings-i)/oc.number_of_rings];
    end
else
    if oc.ring_step > plot_range
        disp('Warning: Ring step is larger than plotting range (max_mag - centre_value)');
    end
    for i = 1-oc.ring_step/plot_range:-oc.ring_step/plot_range:0  %If user define ring step then...
        rings = [rings i];
    end
    
end   

%draw the plot fill circle only if one of the axes are on
if (~strcmpi(oc.ring_axis,'off') & ~strcmpi(oc.ring_axis,'none')) |...
        (~strcmpi(oc.angle_axis, 'none') & ~strcmpi(oc.angle_axis, 'off'))
    fill(cos(phi),sin(phi),oc.plot_area_color,'HandleVisibility','off')
end

%only draw the ring axis and its labels if axis is not set of 'OFF'
if ~strcmpi(oc.ring_axis, 'off') & ~strcmpi(oc.ring_axis, 'none')    
    for i = 1:1:length(rings)     %plot the rings
        x = rings(i)*cos(phi);
        y = rings(i)*sin(phi);
        if(rings(i) == 1)      %if on the outer ring, then make a solid line unless user specifies otherwise
            plot(x,y,'Color',oc.ring_color,'LineStyle',oc.outer_ring_style,'LineWidth',oc.ring_border_line_width,...
                'HandleVisibility','off');  
        else
            plot(x,y,'Color',oc.ring_color,'LineStyle',oc.ring_style,'LineWidth',oc.ring_line_width,...
                'HandleVisibility','off');  
        end
    end
    
    %Draw on the text labeling the magnitude
    angle_of_mark = oc.mag_mark_angle*pi/180;
    if ~strcmpi(oc.ring_label,'off') & ~strcmpi(oc.ring_label,'none')  %the strcmpi is case insensitive        
        for i = 1:1:length(rings)
            x = (rings(i)+0.0*oc.max_mag)*cos(angle_of_mark);
            y = (rings(i)+0.0*oc.max_mag)*sin(angle_of_mark);
            if ~isempty(oc.ring_tick_label)
                if iscell(oc.ring_tick_label)
                    temp = oc.ring_tick_label{i};
                else
                    temp = num2str(oc.ring_tick_label(i));
                end
            else
                temp = num2str(round(rings(i)*plot_range*1000)/1000+round(oc.centre_value*1000)/1000);
            end            
            if(rings(i) == 1)   %if on the outer ring's value, then insert units if user has defined them
                text(x,y,[temp oc.ring_units],...
                    'FontSize',oc.ring_font_size,  'FontWeight',oc.ring_font_weight,...
                    'HorizontalAlignment','left',  'VerticalAlignment','bottom','Color',oc.ring_font_color,...
                    'HandleVisibility','off')
            else
                text(x,y,temp,...
                    'FontSize',oc.ring_font_size,  'FontWeight',oc.ring_font_weight,...
                    'HorizontalAlignment','left','VerticalAlignment','bottom','Color',oc.ring_font_color,...
                    'HandleVisibility','off')
            end
        end
    end
end

%Draw the angle markers
if strcmp(oc.angle_step,'')   %if angle step not defined
    phi = (oc.theta_start:360/no_angle_marks:oc.theta_start+359)*pi/180;   %angle of marks
    phit = oc.theta_start:360/no_angle_marks:oc.theta_start+359;           %angle of labels
else                       %if angle step defined
    phi = (oc.theta_start:oc.angle_step:oc.theta_start+359)*pi/180;
    phit = oc.theta_start:oc.angle_step:oc.theta_start+359;
end

%only draw the angle axis and its labels if axis is not set of 'OFF'
if ~strcmpi(oc.angle_axis, 'off') & ~strcmpi(oc.angle_axis, 'none')
    for i = 1:1:length(phi)
        x = 1*cos(phi(i));
        y = 1*sin(phi(i));
        plot([0 x],[0 y],'Color',oc.angle_color,'LineStyle',oc.angle_style,'LineWidth',oc.angle_line_width,...
            'HandleVisibility','off')
    end
    
    %if labels should not be put on every anlge mark then change the text anlges accordingly
    if oc.angle_label_step ~= 0
        phit = oc.theta_start:oc.angle_label_step:oc.theta_start+359;
    end 
    
    if strcmp(oc.theta_direction,'cw')
        phit = -phit;
    end
    
    %Draw on text labeling the angles
    if ~strcmpi(oc.angle_label,'off') & ~strcmpi(oc.angle_label,'none')
        for i = 1:1:length(phit)
            x = 1*1.15*cos(phit(i)*pi/180);
            y = 1*1.15*sin(phit(i)*pi/180);
            if ~isempty(oc.angle_tick_label)
                if iscell(oc.angle_tick_label)
                    temp = oc.angle_tick_label{i};
                else
                    temp = num2str(oc.angle_tick_label(i));
                end
            else
                temp = num2str(abs(phit(i))-oc.theta_start);
            end           
            text(x,y,[temp degrees_string],...
                'FontSize',oc.angle_font_size,'FontWeight',oc.angle_font_weight,...
                'HorizontalAlignment','center','VerticalAlignment','middle',...
                'Color',oc.angle_font_color,'HandleVisibility','off')
        end
    end
end
axis off



























%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                       %
%                                     SETUP THETA                                       %
%                                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%transform the input to plot out correctly in cartesian coordinates
function theta = SetupTheta(theta)
global oc
theta = theta + oc.theta_start/180*pi;
if strcmp(oc.theta_direction,'cw')
    theta = -theta;   
end
                                         






















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                       %
%                                     SETUP R                                           %
%                                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [norm_r, theta, PlotProperties] = SetupR(r, theta)
global oc DB

%make a note of the original maximum and minimum values of r
max_r = max(r);
min_r = min(r);

plot_range = oc.max_mag - oc.centre_value;

%shift r values so minimum is at 0 + centre value difference
norm_r = r - oc.centre_value;
norm_r = norm_r/plot_range;     %normalise r values between 0 and 1 where 0 is centre 
%value and 1 is max distance from centre (plot_range)
%check all values and any that are negative (and therefore less than the centre value) are made
%equal to the centre value
for i = 1:1:length(norm_r)
    if norm_r(i) < 0
        norm_r(i) = 0;
    end
end

%These normalised r values now need to be examined and any values outiside of the 
%the maximum magnitude need to be discarded. However, if there is interpolation between
%2 points (one inside the max and one outside) then a new point on this interpolation needs
%to be added in so the line from the point inside the axis still extends out to the outer
%ring. Therefore, a new array of r values which only contain plottable values and additional
%points that are needed is made.

PlotNumCounter = 0;          %Number of plots (ie number of sections within the unity circle)
InPlotFlag = 0;           %if 1, this flag means that current points are in a plotting section
PlotStartFlag = [];       %This will be an array containing the start points for the plot sections
PlotBreakFlag = [];       %This will be an array containing the break points for the plot sections

for i = 1:1:length(norm_r)
    %the first point that is on or in the unity circle is allocated as the first section's start point
    if isempty(PlotStartFlag) & (norm_r(i)<=1 || isnan(norm_r(i)))
        PlotStartFlag = i;
        InPlotFlag = 1;
        PlotNumCounter = 1;
    else        
        %If a point is outside the unity circle and not in the void between a break point 
        %and start point then allocate the break point to the point previous to this one
        if(norm_r(i) > 1 & InPlotFlag == 1)
            PlotBreakFlag = [PlotBreakFlag i-1];
            InPlotFlag = 0;
        end
        
        %If a point is on or in the unity circle and currently is in the void between a break
        %point and start point then allocate this point as the start point of a new section
        if(norm_r(i) <= 1 & InPlotFlag == 0)
            PlotStartFlag = [PlotStartFlag i];
            InPlotFlag = 1;
            PlotNumCounter = PlotNumCounter + 1;
        end
    end
end

%finally, if the last point was in a plotting section then have to define it as the break point
%Bugfixed as per Dr. Thomas Patzelts suggestion from 2/12-08.
if(InPlotFlag == 1) 
    if isempty(PlotBreakFlag) 
        PlotBreakFlag = length(norm_r); 
    else  
        PlotBreakFlag = [PlotBreakFlag length(norm_r)]; 
    end 
end 

if (ischar(oc.check_voids) && strcmpi(oc.check_voids, 'on')) ...
|| (islogical(oc.check_voids) && oc.check_voids)
%go through each of the start and end points and for each go to the point next to it that is in 
%the void (between start and break points) and calculate the gradient and then add in a point between
%the void point and the valid point that lies on this gradient AND the unity circle. This procedure is
%therefore only needed it a plot exists and it exceeds the unity boundary (ie the only break flag doesn't
%index the last point in the set of data)
if(PlotNumCounter > 0)
    for i = 1:1:PlotNumCounter
        if PlotStartFlag(i) ~= 1   %only look at section starts if its not the first point
            x = norm_r.*cos(theta);   %need to recalculate x and y every time incase norm_r and
            y = norm_r.*sin(theta);   %theta were changed in the previous loop
            
            %if the gradient between the void and valid points is infinity (ie x1=x2) then the line equation
            %simple becomes x=b, where b is the x coordinate of both points. We also know that for our wanted
            %point to be on the unity circle we need 1=sqrt(x^2+y^2) => 1=x^2+y^2. Therefore, as x=b, we can 
            %find y as:
            %             y = 1-x^2 = 1-b^2
            %
            %Now, if the void point is in the y>0 quadrants, then the crossing point must occur in the y>0 part
            %of the unity circle. Conversely, if the void point has y<0, then the cross point must occur in the
            %y<0 semicircle of the unty circle
            if x(PlotStartFlag(i))==x(PlotStartFlag(i)-1)
                Voidx = x(PlotStartFlag(i));
                Voidy = 1-Voidx^2; 
                if(y(PlotStartFlag(i)-1)<0)
                    Voidy = -Voidy;
                end
                %however, if the gradient is defined, then we need to calc the gradient to find the point on the 
                %unity circle
            else  
                if x(PlotStartFlag(i)-1)<x(PlotStartFlag(i))
                    gradient = (y(PlotStartFlag(i)) - y(PlotStartFlag(i)-1))/(x(PlotStartFlag(i)) - x(PlotStartFlag(i)-1));
                elseif x(PlotStartFlag(i)-1)>x(PlotStartFlag(i))
          %          x(PlotStartFlag(i)) 
         %           y(PlotStartFlag(i)) 
        %            keyboard
        %            r(PlotStartFlag(i)) 
                    gradient = (y(PlotStartFlag(i)-1) - y(PlotStartFlag(i)))/(x(PlotStartFlag(i)-1) - x(PlotStartFlag(i)));
                else
                    gradient = 0;
                end    
                %C is y intercept of y=mx+c eqation for a straign line
                C = y(PlotStartFlag(i)) - gradient*x(PlotStartFlag(i));
                m = gradient;

                %at the crossing point between line bewteen void and valid and unity circle we know the x,y
                %coordinates must satisfy the straight line eqn y=mx+c and 1=sqrt(x^2+y^2) => 1=x^2+y+2.
                %Rearranging this yeilds           
                %                         0 = (m^2+1)x^2 + (2mc)x + (c^2-1)
                %
                %the roots of this can be solved and x found. Note that there will always be one or two
                %real roots as this procedure is only being implemented when the line DOES cross the unity
                %circle (there will only be one root when the line is a tangent to the unit circle).
                Voidx = roots([m^2+1 2*m*C C^2-1]);
                Voidy = m*Voidx+C;
                %if there are two roots, check which x coordinate is between the void point and valid point 
                %and then use that as the true coordinate
                x_limits = [x(PlotStartFlag(i)-1) x(PlotStartFlag(i))];
                y_limits = [y(PlotStartFlag(i)-1) y(PlotStartFlag(i))];
                if length(Voidx) == 2
                    if Voidx(1)>min(x_limits) &  Voidx(1)<max(x_limits) &  Voidy(1)>min(y_limits) &  Voidy(1)<max(y_limits)
                        Voidx = Voidx(1);
                        Voidy = Voidy(1);
                    else 
                        Voidx = Voidx(2);
                        Voidy = Voidy(2);
                    end
                end
            end

            %insert new point into array or points
            norm_r = [norm_r(1:PlotStartFlag(i)-1); sqrt(Voidx^2+Voidy^2); norm_r(PlotStartFlag(i):length(norm_r))];
            
            %insert new angle into array of angles
            if(Voidx == 0)
                new_theta = pi/2*sign(Voidy);   %this puts the point in the correct quadrant (CA or ST)
            else
                new_theta = atan(Voidy/Voidx);
                %if x is negative then the definition of atan needs to be added to 180 degrees
                if(Voidx < 0)
                    new_theta = pi+new_theta;
                end
            end
            theta = [theta(1:PlotStartFlag(i)-1); new_theta; theta(PlotStartFlag(i):length(theta))];
            
            %increment appropiate indecies in PlotStart and PlotBreak flags to take into accout the new points
            %(remembering you want the new points to be within the plotting segement)
            if(i < PlotNumCounter)  %if not at the last PlotStartFlag
                PlotStartFlag(i+1:PlotNumCounter) = PlotStartFlag(i+1:PlotNumCounter) + 1;
            end
            PlotBreakFlag(i:PlotNumCounter) = PlotBreakFlag(i:PlotNumCounter) + 1;
        end
        
        %now do the same thing for the break flags, ie going from valid point to void
        %But only consider if the break is NOT the first element, or the break is NOT the last element
        if  (PlotBreakFlag(i) ~= length(norm_r))
            x = norm_r.*cos(theta);  %need to recalc x and y incase norm_r and theta were changed in previous
            y = norm_r.*sin(theta);  %if statement (for PlotStartFlag) or previous loop
            
            %refer to previous IF statement (for PlotStartFlag) for full explanation
            if x(PlotBreakFlag(i))==x(PlotBreakFlag(i)+1)
                Voidx = x(PlotBreakFlag(i));
                Voidy = 1-Voidx^2; 
                if(y(PlotBreakFlag(i)+1)<0)
                    Voidy = -Voidy;
                end
            else
                if x(PlotBreakFlag(i)+1)<x(PlotBreakFlag(i))
                    gradient = (y(PlotBreakFlag(i)) - y(PlotBreakFlag(i)+1))/(x(PlotBreakFlag(i)) - x(PlotBreakFlag(i)+1));
                elseif x(PlotBreakFlag(i)+1)>x(PlotBreakFlag(i))
                    gradient = (y(PlotBreakFlag(i)+1) - y(PlotBreakFlag(i)))/(x(PlotBreakFlag(i)+1) - x(PlotBreakFlag(i)));
                else
                    gradient = 0;
                end
                %C is y intercept of y=mx+c eqation for a straign line
                C = y(PlotBreakFlag(i)) - gradient*x(PlotBreakFlag(i));
                m = gradient;
                
                temp = [m^2+1 2*m*C C^2-1];
                if any(isnan(temp))
                    Voidx = NaN;
                    Voidy = NaN;
                else
                    Voidx = roots([m^2+1 2*m*C C^2-1]);
                    Voidy = m*Voidx+C;
                end
                %if there are two roots, check which x coordinate is between the void point and valid point 
                %and then use that as the true coordinate
                x_limits = [x(PlotBreakFlag(i)+1) x(PlotBreakFlag(i))];
                y_limits = [y(PlotBreakFlag(i)+1) y(PlotBreakFlag(i))];
                if length(Voidx) == 2
                    if Voidx(1)>min(x_limits) &  Voidx(1)<max(x_limits) &  Voidy(1)>min(y_limits) &  Voidy(1)<max(y_limits)
                        Voidx = Voidx(1);
                        Voidy = Voidy(1);
                    else 
                        Voidx = Voidx(2);
                        Voidy = Voidy(2);
                    end
                end
            end
            %insert new point into array or points

            norm_r = [norm_r(1:PlotBreakFlag(i)); sqrt(Voidx^2+Voidy^2); norm_r(PlotBreakFlag(i)+1:length(norm_r))];
            
            %calculate and insert new angle into array of angles
            if(Voidx == 0)
                new_theta = pi/2*sign(Voidy);
            else
                new_theta = atan(Voidy/Voidx);
                %if x is negative then the definition of atan needs to be added to 180 degrees
                if(Voidx < 0)
                    new_theta = pi+new_theta;
                end
            end
            theta = [theta(1:PlotBreakFlag(i)); new_theta; theta(PlotBreakFlag(i)+1:length(theta))];
            
            %increment appropiate indecies in PlotBreak and PlotBreak flags to take into accout the new points
            %(remembering you want the new points to be within the plotting segement)
            if(i < PlotNumCounter)  %if not at the last PlotBreakFlag
                PlotStartFlag(i+1:PlotNumCounter) = PlotStartFlag(i+1:PlotNumCounter) + 1;
            end
            PlotBreakFlag(i:PlotNumCounter) = PlotBreakFlag(i:PlotNumCounter) + 1;
        end
    end
end
end

PlotProperties{1} = PlotNumCounter;
PlotProperties{2} = PlotStartFlag;
PlotProperties{3} = PlotBreakFlag;




















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                       %
%                                     PLOT TRACE                                        %
%                                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=PlotTrace(theta, norm_r, PlotProperties, TraceProps)

PlotNumCounter = PlotProperties{1};
PlotStartFlag = PlotProperties{2};
PlotBreakFlag = PlotProperties{3};

x = norm_r.*cos(theta);
y = norm_r.*sin(theta);

handle_visibility = 'on';  %first segment trace is to have a handle that can be access by prompt

%(eg - to use to make the legend)
%if there are any plot sections to plot then go ahead and plot
h = [];
if(PlotNumCounter > 0)
    for i = 1:1:PlotNumCounter     %for each plot section redefine x and y between the start and break flags
        x = norm_r(PlotStartFlag(i):PlotBreakFlag(i)).*cos(theta(PlotStartFlag(i):PlotBreakFlag(i)));
        y = norm_r(PlotStartFlag(i):PlotBreakFlag(i)).*sin(theta(PlotStartFlag(i):PlotBreakFlag(i)));
        %plot the thing - FINALLY

        h(i)=plot(x,y,'LineWidth', TraceProps.line_width, 'LineStyle',TraceProps.line_style,'Color',TraceProps.line_color,...
            'Marker',TraceProps.line_marker, 'HandleVisibility',handle_visibility);
        handle_visibility = 'off';  %once the first trace segment is plotted, want the remaining handles hidden so 
    end                             %the legend doesn't display them, but moves straight onto the next trace
end























%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                       %
%                                CHECK PLOT LIMITS                                      %
%                                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CheckPlotLimits

global oc Traces

%Make up maximum magnitudes and minimum magnitudes
if ~isnumeric(oc.max_mag)
    if strcmp(lower(oc.max_mag),'max')
        TraceMax = '';
        for i = 1:2:length(Traces)
            TraceMax = [TraceMax max(Traces{i}(:,1))];
        end
        oc.max_mag = max(TraceMax);
    else
        DispError('"MaxValue" must be a value or "max"');
        return
    end    
end

if ~isnumeric(oc.centre_value)
    if strcmp(lower(oc.centre_value), 'min')
        TraceMin = '';
        for i = 1:2:length(Traces)
            TraceMin = [TraceMin min(Traces{i}(:,1))];
        end
        oc.centre_value = min(TraceMin);
    else
        DispError('"CentreValue" must be a value or "min"');
        return
    end
end
    
%make sure input is not bogus
if oc.max_mag < oc.centre_value
    DispError('Centre value is larger than maximum input value');
    return
end

if oc.max_mag == oc.centre_value
    DispError('Centre value is same as maximum input value - define CentreValue if all r values are same - see help');
    return
end













%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                       %
%                             CHECK STANDARD PLOT                                       %
%                                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function will check a string that is a shortcut plotting string incorperating the marker, style and color.
%It will return seperate color, marker and style strings if they are found in the combined string. If the
%combined string has a syntax error then the function will exit the m file and return an error referring the
%user to the HELP PLOT help command.
function [Color, Marker, Style] = CheckStandardPlot(PlotString)

LineColorFlag = 0;
LineMarkerFlag = 0;
LineStyleFlag = 0;

Color = '';
Marker = '';
Style = '';

%check the standard_plot variable. If it is not emplty, that means the user has selected the PLOT
%functions shortcut arguments to make a plot. Therefore, convert these arguments to the appropriate
%line color and style. Note, that this will overwrite future uses of LineColor and LineStyle in the 
%arguments

if length(PlotString) > 4 | isempty(PlotString)            %color, marker, style
    DispError(['Incorrect plot parameters: ''' PlotString '''. Type HELP PLOT to see correct usage']);
    return
end
i = 1;
while i <= length(PlotString)
    c = PlotString(i);         %temp character variable
    %check the color
    if (c == 'y' | c == 'm' | c == 'c' | c == 'r' | c == 'g' | c == 'b' | c == 'w' | c == 'k') & LineColorFlag == 0
        LineColorFlag = 1;
        Color = c;
        
    %check the marker style
    elseif (c == '.' | c == 'o' | c == 'x' | c == '+' | c == '*' | c == 's' | c == 'd' | ...
            c == 'v' | c == '^' | c == '<' | c == '>' | c == 'p' | c == 'h') & LineMarkerFlag == 0
        LineMarkerFlag = 1;
        Marker = c;
        
    %check the line style
    elseif (c == '-' | c == ':') & LineStyleFlag == 0 %| c == '-.' | c == '--'  %THIS NEEDS FIXING
        LineStyleFlag = 1;
        Style = c;
        if(c == '-' & i < length(PlotString) )
            if PlotString(i+1) == '.' | PlotString(i+1) == '-'
                Style = [Style PlotString(i+1)];
                i = i + 1;
            end
        end       
        %if neither color nor marker nor style then error
    else
        DispError(['Incorrect plot parameters: ''' PlotString '''. Type HELP PLOT to see correct usage']);
        return
    end
    i = i+1;
end






















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                       %
%                                     DISP ERROR                                        %
%                                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DispError(ErrorString)

global ErrorFlag

ErrorFlag = 1;
disp(sprintf('\nPP ERROR:    %s\n             Type "help pp" for information\n\n', ErrorString));























%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                       %
%                                     DISP ERROR                                        %
%                                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function AssignStyle(ppStyle)

global oc ErrorFlag

switch ppStyle
case 0
    return
    
    %%%%%%%%%%  DEFAULT STYLE    %%%%%%%%%%%
case 1
    oc.angle_color = [0 0 0];
    oc.ring_color = [0 0 0];
    oc.angle_style = ':';
    oc.ring_style = ':';
    oc.angle_line_width = 0.1;
    oc.ring_line_width = 0.1;
    oc.ring_units = '';
    oc.angle_degree_mark = 'off';
    
    %%%%%%%%%  SOLID AXIS in DB Style  %%%%%%%%
case 2
    oc.angle_color = [0.5 0.5 0.5];
    oc.ring_color = [0.5 0.5 0.5];
    oc.angle_style = '-';
    oc.ring_style = '-';
    oc.angle_line_width = 0.1;
    oc.ring_line_width = 0.1;
    oc.ring_units = 'dB';
    oc.angle_degree_mark = 'on';
    
    %%%%%%% UNDEFINED STYLE %%%%%%%
otherwise
    ErrorFlag = 1;
    DispError('ppStyle number not Valid.');
end

return    
    
























%## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ##
%# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
%                                                                                        #
%                           Variable Information and Explanation                         #
%                                                                                        #
%# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
%## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ##

%-----------------------------------------------------------------------------------------
%
% tc:                                                                         (trace cell)
%   Trace properties structure
%
%-----------------------------------------------------------------------------------------
%
% oc:                                                                       (options cell)
%   Plot/Figure/Axes properties structure
%
%-----------------------------------------------------------------------------------------
%
% args:
%   Cell matrix containing possible property strings the user can enter and the actions to 
%   take when the user enters them
%  
%   eg: A row in args might be:
%  
%   'NumRings'              1                   'v'              oc.number_of_rings
%  
%       |                   |                    |                      |
%  Property Name      FLAG indicating        Data type            variable to store 
%                      data follows          expected                data to
%                        property
% 
%    NB: if FLAG is 0, then whatever is in the third column gets stored in the 4th column variable
% 
%-----------------------------------------------------------------------------------------
%
% UserData:
%       1 x n array of cells:                                                             (n = Num Traces + 2)
%                           {1} - "Bob's Polar Plot" string for plot identification
%                           {2} - oc (figure properties)
%                           {3} - i x 2 matrix of trace data (columns of Rho and Theta)   (i = length(Theta))
%                           {4} - tc (trace properties of trace in {3})
%                           {5} - k x 2 matrix of trace data (columns of Rho` and Theta`) (k = length(Theta`))
%                           {6} - tc` (trace properties or trace in {5})
%                            :
%                            :
% 
%-----------------------------------------------------------------------------------------
%
% Traces: 
%       1 x n-2 array of cells:
%                           {1} - same as UserData{3}
%                           {2} - same as UserData{4}
%                           {3} - same as UserData{5}
%                           {4} - same as UserData{6}
%                            :
%                            :
%
%-----------------------------------------------------------------------------------------
