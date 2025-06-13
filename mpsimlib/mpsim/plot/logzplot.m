function [h,h2] = logzplot(varargin)
%Surface plot with log-scaled color and z-axis
%
% SYNTAX
%
%   LOGZPLOT
%   LOGZPLOT(Z)
%   LOGZPLOT(Z,C)
%   LOGZPLOT(X,Y,Z)
%   LOGZPLOT(X,Y,Z,C)
%   LOGZPLOT(...,'PLOTFUN')
%   LOGZPLOT(TriRep,'PLOTFUN')
%   LOGZPLOT(TRI,X,Y,Z,'PLOTFUN')
%   LOGZPLOT(TRI,X,Y,Z,C,'PLOTFUN')
%   LOGZPLOT(...,@PLOTFUN)
%   LOGZPLOT colorbar or LOGZPLOT(...,'colorbar')
%   LOGZPLOT(HANDLE,...)
%   H = LOGZPLOT(...)
%
% DESCRIPTION
%
% LOGZPLOT creates a SURF, MESH, PCOLOR, TRISURF or TRIMESH plot with a
% logarithmic scaling of the z-axis and color data.  The plot type can be
% specified as a string or function handle.  If called without data inputs,
% LOGZPLOT applies the log-scale transformation to an existing surface or
% patch object.  LOGZPLOT called with the optional argument 'colorbar' will
% also create a log-scaled colorbar.
%
%   LOGZPLOT(Z)
%   LOGZPLOT(Z,C)
%   LOGZPLOT(X,Y,Z)
%   LOGZPLOT(X,Y,Z,C)
%
% Create a log-scaled surface plot using the data in Z by first calling
% SURF() and then transforming the resulting surface object.  The optional
% arguments X and Y specify values for the X and Y locations of the
% elements of Z. If given, X and Y must be specified together, and be of
% the appropriate size for the data in Z.  If the optional argument C is
% given, the surface's color will be based on the values in C instead of Z.
%
%   LOGZPLOT(...,'PLOTFUN')
%   LOGZPLOT(TriRep,'PLOTFUN')
%   LOGZPLOT(TRI,X,Y,Z,'PLOTFUN')
%   LOGZPLOT(TRI,X,Y,Z,C,'PLOTFUN')
%   LOGZPLOT(...,@PLOTFUN)
%
% Use the plotting function specified by the string or function handle in
% PLOTFUN to plot the data. By default, SURF is used to generate the plot.
% Supported plotting functions are SURF, MESH, PCOLOR, TRISURF and TRIMESH.
% The number and type of the data inputs depends on the selected plotting
% function.  
% 
% For SURF, MESH, and PCOLOR plots, use (X,Y,Z,C) as inputs (Z is the only
% required input).  Note that PCOLOR only supports data of the forms
% PCOLOR(C) or PCOLOR(X,Y,C), so either one or three data inputs must be
% supplied when PCOLOR is used as the plotting function.  See the
% documentation for SURF, MESH and PCOLOR for more information.
%
% For TRISURF and TRIMESH plots, the data must be input either as a TriRep
% object or as (TRI,X,Y,Z,C) where TRI is the triangulation of the data in
% X and Y, Z is the height data, and C is optional color data to be used
% instead of Z to color the plot.  See the documentation for TRISURF and
% TRIMESH for more information
% 
%   LOGZPLOT(...,'colorbar')
%
% Additionally creates a log-scaled colorbar.
%
%   LOGZPLOT(AX_HANDLE,...)
%
% Uses the existing axes specified by AX_HANDLE to create the plot. 
%
%   H = LOGZPLOT(...)
%
% Returns the handle of the surface or patch object.
%
%   LOGZPLOT 
%
% Calling LOGZPLOT with no arguments will apply a log-scale transformation
% to a surface or patch object located in the current axes. The first such
% object found will be used by LOGZPLOT.  If the object has already been
% transformed by LOGZPLOT, calling LOGZPLOT again will have no effect.
%
%   LOGZPLOT colorbar
%   LOGZPLOT('colorbar') 
%
% Additionally create a log-scaled colorbar, or scale an existing colorbar
% attached to the axes of the log-transformed plot. The resulting colorbar
% scale should be accurate to the log-scaled data.  See the REMARKS section
% below for more information.
%
%   LOGZPLOT(HANDLE)
%   LOGZPLOT(HANDLE,'colorbar')
%
% Transform the surface or patch object specified by HANDLE, or, if HANDLE 
% refers to an axes, transform a surface or patch object located in the
% specified axes.
%
% REMARKS
%
% Compared to other high-level plotting functions, TRIMESH (and to a lesser
% extent TRISURF) offer incomplete support for the specification of an axes
% handle as a target for the plot output in place of gca().  In particular,
% TRIMESH cannot accept an axes handle if the data is specified as a TriRep
% object.  If LOGZPLOT is called with a TriRep object and TRIMESH as the
% plotting function, the plot will be created in the current axes, ignoring
% any axes handle input.
%
% Because MATLAB's OpenGL renderer does not support logarithmic axes, the
% figure's 'Renderer' property must be set to another renderer for proper
% display of the plot.  MATLAB should change the renderer automatically. In
% some cases when using an existing figure for the plot output, the
% renderer will not change automatically, and the log-scale z-axis will not
% display properly.  If this occurs, set the renderer manually using:
%    set(fig_h,'Renderer','ZBuffer')
% where fig_h is the handle of the figure in question.  See the
% documentation for 'Figure Properties' for more information.
% 
% If LOGZPLOT is used to transform an existing surface or patch object, the
% color data ('CData' for surface objects, 'FaceVertexCData' for trisurf
% and trimesh patch objects) must be in indexed form.  LOGZPLOT can not
% transform objects with truecolor (RGB) color data, and will exit with a
% warning if called on an object with truecolor color data.  LOGZPLOT sets
% the object's 'CDataMapping' property to 'scaled'.
%
% LOGZPLOT replaces the original color data, CData, with a transformed
% version, log10(CData).  An additional linear scaling is performed on the
% transformed data so that the scale on a colorbar will have the same range
% as the original data.  
%
% Changing the value of the axes 'CLim' (color limits) property using
% either the CAXIS command or set(ax_handle,'CLim') will alter the mapping
% of the data to the colormap as described in the documentation for the
% CAXIS command. This is a useful technique to highlight different data
% ranges in the plot.  See Example 2 below.
%
% However, as noted above, the log-transformed data does not result in an
% accurate colorbar scale without an additional (linear) transformation.
% To accurately map the color data to the colorbar's scale after a change
% to the axes 'CLim' property, LOGZPLOT attaches a set of listener
% functions to the axes that correct the color data scaling whenever the
% 'CLim' property is changed.  This allows the user to specify 'CLim'
% values in the same units and range as the original data.
%
% The listener functions were written for MATLAB R2010a, and may not
% function correctly on older releases due to changes in the MATLAB
% graphics system. If problems related to the listener functions occur, set
% the parameter 'ListenerEnableFlag' to 0 in the first section of the
% LOGZPLOT code, just below the help text.  This will disable the listener
% functionality and prevent rescaling of the color data after a CLim
% change.
%
% The additional scaling of the color data introduces numerical error.
% The magnitude of the error depends on the range of the original data as
% well as the values of the axes' CLim property.  The error is cumulative,
% so making many changes to the CLim values can potentially result in
% inaccurate color data.
%
% If an object created or modified by LOGZPLOT is located in an axes with
% non-log-scaled indexed color objects (surface, patch, or image), the
% colorbar scale will not be accurate.  To ensure accurate colorbar scales,
% do not combine a LOGZPLOT-scaled object with non-scaled indexed-color
% objects in the same axes.
%
% LOGZPLOT attempts to avoid re-transforming a previously log-scaled 
% surface (from a previous call to LOGZPLOT).  To accomplish this, LOGZPLOT
% sets the 'Tag' property of the surface or patch object, and checks for
% this tag before applying the scaling transformation.  This allows 
% multiple calls to LOGZPLOT using the same object, e.g. to add a colorbar
% after creating the plot.
%
% EXAMPLES
%
% % Example 1 - Compare linear and log-scaled surface plots
%
% % Generate some Gaussian data with a small sinusoidal component:
% x = linspace(-10,10,101);
% [X ,Y] = meshgrid(x);
% Z = 5*exp(-(0.82*(X+3.5).^2 + 0.46*(Y-3.5).^2)) + ...
%     0.8*exp(-(0.45*(X-1.5).^2 + 0.95*(Y-1.5).^2)) + ...
%     0.2*exp(-(0.75*(X-4).^2 + 0.85*(Y+1).^2)+(0.7*(X-3)+.3*(Y-1)).^2)+...
%     0.06*exp(-(0.2*(X+2.5).^2 + 0.3*(Y+3.5).^2)) + ...
%     -0.45*exp(-(0.5*(X+3.3).^2 + 1.5*(Y-2.5).^2)) + ...
%     0.0015*sin(2.6*X+1.1*Y-0.2*X.*Y) + ...
%     0.0009*sin(1.3*X+2.1*Y+0.12*X.*Y);
%
% % Scale the data so its range is 1 to 30000:
% minz = 1;
% maxz = 3e4;
% Z = (maxz-minz)*(Z-min(Z(:)))./(max(Z(:))-min(Z(:))) + minz;
% 
% % Add a large Gaussian that will swamp the rest of the data:
% Z = Z + 1e6*exp(-2*(X.^2 + (Y-4).^2));
%
% % Linear z-axis with linear color scale:
% figure(1)
% set(1,'position',[254 335 642 471])
% colormap(jet(64))
% h = surf(X,Y,Z); colorbar
% title('Linear Z-scale and Coloring')
% % Almost all of the surface's detail is hidden because both the height
% % scale and color scale are dominated by the single prominent feature of
% % the data. 
%
% % Log-scale z-axis with linear color scale:
% % Use SURF, then change the z-axis scaling using set(gca,'ZScale','log').
% figure(2)
% set(2,'position',[254 335 642 471])
% colormap(jet(64))
% h = surf(X,Y,Z); colorbar
% set(gca,'ZScale','log')
% title('Log Z-scale with Linear Coloring')
% % Note how the log-scale z-axis improves the visibility of the small
% % elevation features of the surface. However, the coloring of the surface
% % is not ideal - the variation in color is still concentrated near the
% % top of the surface due to the linear color scale.
%
% % Log-scale plot using LOGZPLOT to achieve both log-scale z-axis and
% % log-scale color:
% figure(3)
% set(3,'position',[254 335 642 471])
% colormap(jet(64))
% logzplot(X,Y,Z,'colorbar')
% title('Logarithmic Z-scale and Coloring')
% % The plot created by LOGZPLOT shows the advantage of using log-scaled
% % color in addition to the log-scaled z-axis.  
%
% % Example 2 - Multiple calls to LOGZPLOT, changing the 'CLim' property
%
% % (Using the X,Y,Z data from Example 1)
% figure(4)
% colormap(jet(64))
%
% % Make a surface using pcolor:
% pcolor(X,Y,Z); shading flat
%
% % Call logzplot to transform to the pcolor plot to log-scale:
% logzplot
%
% % Call logzplot again to add a log-scale colorbar:
% logzplot colorbar
%
% % Use the CAXIS command to set the axes CLim parameter (color limits) to
% % highlight the lower range of the data.  The colorbar scale should 
% % adjust to the new limits:
% caxis([1 70])
%
% % Call CAXIS again with different CLim values, to highlight the middle
% % range of the data:
% caxis([40 8000])
%
% % One more call to CAXIS to reset the color limits:
% caxis auto
%
%
% SEE ALSO: SURF, MESH, PCOLOR, TRISURF, TRIMESH, CAXIS
%

% logzplot.m 
% Copyright (c) 2010 by John Barber
% Distribution and use of this software is governed by the terms in the 
% accompanying license file.

% Release History:
% v 1.0 : 2010-Nov-08
%       - Initial release
% v 1.1 : 2010-Nov-30
%       - Added support for trisurf and trimesh plots
%       - Improved memory performance
%       - Improved speed of axes CLim change listener function
%       - Improved colorbar support

%% Set up defaults

% Listener enable flag:
% -- Disable if listener function causes errors
% -- 0 = disabled
% -- 1 = enabled (default)
ListenerEnableFlag = 1;  
% ListenerEnableFlag = 0;  % Uncomment this line to disable listener

% Supported plotting functions:
plotFunList = {'surf','pcolor','mesh','trisurf','trimesh','image'};

% Default values:
% hSurf = [];  
% hAx = [];   
% pcolorFlag = 0;    
inputHandle = [];
colorbarFlag = 0;
plotFun = @surf;
x = [];
y = [];
z = [];
CData = [];
tr = [];
triRep = [];
badInput = 0;
plotFlag = 0;

%% Parse inputs
if ~isempty(varargin)
    
    % Get char arrays and make indices of other classes
    chars = varargin(cellfun(@ischar,varargin));
    numIdx = cellfun(@isnumeric,varargin);
    fHandleIdx = cellfun(@(x)(isa(x,'function_handle')),varargin);
    scalarIdx = cellfun(@isscalar,varargin);
    emptyIdx = cellfun(@isempty,varargin);
    cellIdx = cellfun(@iscell,varargin);
    triRepIdx = cellfun(@(x)(isa(x,'TriRep')),varargin);
    
    % Make an index of non-empty non-scalar arrays
    numIdx = numIdx & ~scalarIdx & ~emptyIdx;
    numIdx = find(numIdx);
    
    % Make a cell array with just the function handles
    fHandles = varargin(fHandleIdx);
    
    % Detect an HG handle if it was given
    handleList = cell2mat(varargin(scalarIdx & ~fHandleIdx & ...
        ~emptyIdx & ~cellIdx));
    inputHandle = handleList(find(ishghandle(handleList),1));
    inputHandle((end-length(inputHandle)+2):end) = [];
    
    % Test for 'colorbar' and '(Plot Function Name)' inputs
    k = 1;
    while k <= length(chars)
        switch lower(chars{k})
            case 'colorbar'
                colorbarFlag = 1;
                k = k + 1;
            case plotFunList
                plotFun = str2func(chars{k});
                k = k + 1;
            otherwise
                k = k + 1;
        end
    end
    
    % If a valid function handle was input, take it
    if ~isempty(fHandles) && ...
            any(strcmp(func2str(fHandles{end}),plotFunList))
        plotFun = fHandles{end};
    end
    
    % Get the data to be plotted, otherwise, exit with an error   
    switch func2str(plotFun)
        case {'surf','mesh','pcolor','image'}
            % For surface plots, valid inputs are 1(z), 2(z,CData),
            % 3(x,y,z), or 4(x,y,z,CData)
            switch length(numIdx)
                case 0
                    plotFlag = 0;
                case 1
                    z = varargin{numIdx};
                    x = 1:size(z,2);
                    y = 1:size(z,1);
                    plotFlag = 1;
                case 2
                    z = varargin{numIdx(1)};
                    CData = varargin{numIdx(2)};
                    x = 1:size(z,2);
                    y = 1:size(z,1);
                    plotFlag = 1;
                case 3
                    x = varargin{numIdx(1)};
                    y = varargin{numIdx(2)};
                    z = varargin{numIdx(3)};
                    plotFlag = 1;
                case 4
                    x = varargin{numIdx(1)};
                    y = varargin{numIdx(2)};
                    z = varargin{numIdx(3)};
                    CData = varargin{numIdx(4)};
                    plotFlag = 1;
                otherwise
                    badInput = 1;
            end      
        case {'trisurf','trimesh'}

            % For trisurf/trimesh, valid inputs are 1(TriRep object),
            % 4(tr,x,y,z) or 5(tr,x,y,z,CData)
            if find(triRepIdx)
                triRep = varargin{triRepIdx};
                plotFlag = 1;
                % Force LOGZPLOT to use gca for trimesh because it does not
                % properly utilize an axes handle input when called with
                % TriRep input
                if ~isempty(inputHandle) && ...
                        strcmp(func2str(plotFun),'trimesh')
                    msgid = [mfilename ':IgnoreInputHandle'];
                    msgtext = ['trimesh does not properly support axes' ...
                        ' handle input.  Using gca() for plot output.'];
                    warning(msgid,msgtext)
                    inputHandle = gca;
                end
            else
                if length(numIdx) == 4
                    tr = varargin{numIdx(1)};
                    x = varargin{numIdx(2)};
                    y = varargin{numIdx(3)};
                    z = varargin{numIdx(4)};
                    plotFlag = 1;
                elseif length(numIdx) == 5
                    tr = varargin{numIdx(1)};
                    x = varargin{numIdx(2)};
                    y = varargin{numIdx(3)};
                    z = varargin{numIdx(4)};
                    CData = varargin{numIdx(5)};
                    plotFlag = 1;
                else
                    badInput = 1;
                end
            end
    end
    
    % Exit with an error if the inputs didn't work out
    if badInput == 1
        msgid = [mfilename ':InvalidInputs'];
        msgtext = ['Invalid input.  Type ' ...
            'help ' mfilename ' for correct syntax'];
        error(msgid,msgtext)
    end

end % Done parsing input arguments

%% Make/modify plot

% Get handles:
[hFig,hAx,hSurf,priorFlag] = LogZPlotGetHandles(inputHandle,plotFlag);

if priorFlag == 1
    % Surface is already scaled, so just call the colorbar subfunction,
    % then exit:
    if colorbarFlag == 1
        LogZPlotColorbar(hFig,hAx)
    end
    return
end

if plotFlag == 0
    % Determine the plot type and get its CData
    
    switch get(hSurf,'Type')
        case 'surface'
            CDataName = 'CData';
            % To determine if it is a pcolor plot, check if the ZData is
            % all zeros
            pcolorFlag = all(all(get(hSurf,'ZData')==0));
        case 'patch'
            CDataName = 'FaceVertexCData';
            pcolorFlag = 0;
        case 'image'
            CDataName = 'CData';
            pcolorFlag = 1;  % avoid setting ZScale.
    end
    
    % Now get the CData to work on
    CData = get(hSurf,CDataName);
    
    % If the CData is RGB, we don't know what to do, so exit
    if size(CData,3) == 3;
        msgid = [mfilename ':TrueColorCData'];
        msgtext = ['The CData of the surface object is truecolor. ' ...
            'The surface will not be transformed'];
        warning(msgid,msgtext)
        return
    end
    
else % plotFlag == 1
    % Make a plot with the user-suppled data
    
    % If we didn't get any CData as an input, use the ZData
    if isempty(CData)
        CData = z;
    end
    
    % Handle surf/mesh, pcolor and trisurf/trimesh plots differently
    switch func2str(plotFun)
        case {'surf','mesh'}
            CDataName = 'CData';
            pcolorFlag = 0;
            hSurf = plotFun(hAx,x,y,z,CData);
        case 'pcolor'
            CDataName = 'CData';
            pcolorFlag = 1;
            hSurf = plotFun(hAx,x,y,CData);
        case 'image'
            CDataName = 'CData';
            pcolorFlag = 1;  % avoid setting ZScale.
            if isvector(x),  x2 = x;  else  x2 = x(1,:);  end
            if isvector(y),  y2 = y;  else  y2 = y(:,1);  end
            hAx2 = gca();
            axes(hAx) %#ok<MAXES>
            hSurf = plotFun(x2,y2,CData);
            axes(hAx2) %#ok<MAXES>
            set(hAx, 'YDir','normal')
        case {'trisurf','trimesh'}
            CDataName = 'FaceVertexCData';
            pcolorFlag = 0;
            if isempty(triRep)
                hSurf = plotFun(tr,x,y,z,CData(:),'Parent',hAx);
            elseif strcmp(func2str(plotFun),'trimesh')
                % Workaround for broken axes handle support in trimesh
                hSurf = plotFun(triRep);
            else
                hSurf = plotFun(triRep,'Parent',hAx);
            end
            CData = get(hSurf,CDataName);        
    end
       
    % Clear x,y,z now that we're done with them.  We are clearing z
    % _before_ we modify CData.  This way, when CData <= z from the 
    % assignment statement a few lines above, MATLAB won't need to create
    % a second copy of the data in memory.
    clear x y z tr triRep

end

% Get rid of (CData <= 0) and (CData == Inf)
CData(CData<=0) = NaN;
CData(CData==Inf) = NaN;

% Find min/max 
minC = min(CData(:));
maxC = max(CData(:));

% Convert data to log space
CData = log10(CData);

% Normalize the log scaled CData to have the same range as the ZData so 
% that the colorbar scale will be correct
CData = minC + (maxC-minC)*(CData-log10(minC))/(log10(maxC/minC));

% Now set the CData of the surface to the normalized CData
set(hSurf,CDataName,CData)

% Make sure we are in 'scaled' CDataMapping mode
set(hSurf,'CDataMapping','scaled')

% Tag the surface so we'll know it has already been transformed
set(hSurf,'Tag','LogZPlotTransformedCData')

% Set the Z scale to 'log' if it isn't a pcolor plot
if pcolorFlag == 0
    set(hAx,'ZScale','log')
end

% Call the colorbar subfunction
hCbar = [];
if colorbarFlag == 1
    hCbar = LogZPlotColorbar(hFig,hAx);
end

% Store the CData range and set up the listeners
if ListenerEnableFlag == 1
    try    
    setappdata(hSurf,'LogZPlotCLim',[minC maxC])
    setappdata(hSurf,'LogZPlotCLimOriginal',[minC maxC]);
    
    fhLogZPlotCLimChange = ...
        @(src,event)LogZPlotCLimChange(src,event,hAx,hSurf,1,CDataName);
    
    hCLimMPreListener = handle.listener(handle(hAx),...
        findprop(handle(hAx),'CLimMode'), 'PropertyPreSet',...
        {@LogZPlotCLimModeChange,hAx,fhLogZPlotCLimChange});
    
    hCLimPostListener = handle.listener(handle(hAx), ...
        findprop(handle(hAx),'CLim'), 'PropertyPostSet', ...
        {@LogZPlotCLimChange,hAx,hSurf,0,CDataName});
    
    LogZPlotListenerHandles = [hCLimMPreListener; hCLimPostListener];
    
    set(hSurf,'DeleteFcn',...
        {@LogZPlotSurfaceDeleted,LogZPlotListenerHandles})
    end
end

% Set return value and exit
if nargout > 0
    h = hSurf;
end
if nargout > 1
    h2 = hCbar;
end

end % End function LOGZPLOT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LogZPlotCLimChange(src,EventData,hAx,hSurf,auto_flag,CDataName)
% Listener function to update hSurf.CData with the proper scaling whenever
% hAx.CLim changes.  Executed post-set.

% Get old and new CLim values
priorCLim = getappdata(hSurf,'LogZPlotCLim');
newCLim = get(hAx,'CLim');

% auto_flag is set when this function is called by the CLimMode pre-set 
% listener, signifying that we are going back to 'auto' mode and need to
% scale the data to the original limits.  This handles the case where
% CLimMode is reset after having been set to manual.
if auto_flag == 1
    newCLim = getappdata(hSurf,'LogZPlotCLimOriginal');
end

% If newCLim equals priorCLim, no need to do anything
if isequal(priorCLim,newCLim)
    return
end

% Warn and don't scale data if CLim is <= 0
if any(newCLim<=0)
    msgid = [mfilename ':NegativeCAxisLimit'];
    msgtext = [mfilename ' only supports positive CLim values.  ' ...
               'Colorbar scale will not be accurate.'];
    warning(msgid,msgtext)
    return
end

% Chop up priorCLim
pL = priorCLim(1);
pH = priorCLim(2);

% Chop up newCLim
nL = newCLim(1);
nH = newCLim(2);

% There are two parts to the transformation: 1) Undo the previous
% normalization (restore CData to its original values) 2) Normalize the
% CData to the new CLim.  They are shown here separately, but computed
% in-place in one step by computing the constants K1 and K2 below.

% 1) Undo the previous normalization to priorCLim:
% CData = (CData-pL)*(log10(pH/pL)/(pH-pL)) + log10(pL);

% 2) Normalize CData to new CLim:
% CData = nL+(nH-nL)*(CData-log10(nL))/log10(nH/nL);

% Compute renormalization constants K1,K2
K1 = nL+(nH-nL)/(log10(nH/nL))*(log10(pL)-log10(nL)-pL*log10(pH/pL)/(pH-pL));
K2 = (nH-nL)*log10(pH/pL)/(log10(nH/nL)*(pH-pL));

% Update the surface with the new CData
set(hSurf,CDataName,K1+K2*get(hSurf,CDataName));

% Write the new CLim to appdata:
setappdata(hSurf,'LogZPlotCLim',newCLim);

end % End function LogZPlotCLimChange
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LogZPlotSurfaceDeleted(src,EventData,hLogZPlotListeners) 
% Listener function to delete all of the listeners attached to the axes
% CLim property so that problems won't crop up if the axes is recycled for
% a new plot.  Listeners are passed as an array of function handles.

try   
    delete(hLogZPlotListeners)
end

end % End function LogZPlotSurfaceDeleted
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LogZPlotCLimModeChange(src,EventData,hAx,fhLogZPlotCLimChange) 
% Listener function to reset the CData using fhLogZPlotCLimChange whenever
% the CLimMode is changed back to 'auto'.  This needs to happen _before_
% the CLimMode is actually changed so that the auto-mode axes refresh uses
% the correct (new) limits instead of basing them on the old CData.

if strcmp(get(hAx,'CLimMode'),'manual')
    fhLogZPlotCLimChange(0,0)
end

end % End function LogZPlotCLimModeChange
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hFig,hAx,hSurf,priorFlag] = ...
                LogZPlotGetHandles(inputHandle,plotFlag)
% Given an input handle and plotFlag, get figure, axes, surface handles and
% priorFlag.  

% Default return value unless we find a tag on the surface object
priorFlag = 0;

% Return empty for hSurf if plotFlag = 1
hSurf = [];

if ~isempty(inputHandle)
    % If we were given a handle, determine its type and then get the other
    % handles we need
    switch lower(get(inputHandle,'Type'))
        case 'axes'
            hAx = inputHandle;
            hFig = ancestor(hAx,'figure');
        case {'surface','patch','image'}
            hSurf = inputHandle;
            hAx = ancestor(hSurf,'axes');
            hFig = ancestor(hSurf,'figure');
        otherwise
            msgid = [mfilename ':InvalidInputHandle'];
            msgtext = ['Input handle must refer to a valid axes or '...
                'surface object'];
            error(msgid,msgtext);
    end
else
    % No input handle so use the current figure and axes
    hFig = gcf;
    hAx = gca;
end

if plotFlag == 0
    % If necessary, try to find a surface object
    if isempty(hSurf)
        hSurf = findobj(hAx,'Type','surface','-or','Type','patch','-or','Type','image');
    end
    
    % If we couldn't find one, or found more than one, exit
    if isempty(hSurf)
        msgid = [mfilename ':NoSurfaceObject'];
        msgtext = 'Could not locate a surface object to transform';
        error(msgid,msgtext);
    elseif length(hSurf) > 1
        msgid = [mfilename ':MultipleSurfaceObjects'];
        msgtext = [mfilename ' only supports one surface object per axes'];
        error(msgid,msgtext)
    end
    
    % Check for tag on surface object and set priorFlag if found
    priorFlag = strcmp(get(hSurf,'Tag'),'LogZPlotTransformedCData');

end

end %End function LogZPlotGetHandles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hCbar = LogZPlotColorbar(hFig,hAx,hCbar)

if nargin == 2
    % See if there are existing colorbars in the figure
    hCbar = findobj(hFig,'tag','Colorbar');
end

% We only want to modify a colorbar whose peer axes is hAx.  To check this,
% use the not fully documented handle() and h.axes property.  Best to wrap
% this in a try block and do nothing if it fails.
try
    for k = length(hCbar):-1:1
        hTestAx = handle(hCbar(k));
        if (double(hTestAx.axes) ~= hAx)
            hCbar(k) = [];
        end
    end
catch  
    hCbar = [];
end

% For multiple colorbars, call this function recursively for each one
if length(hCbar) > 1
    for k = 1:length(hCbar)
        LogZPlotColorbar(hFig,hAx,hCbar(k))
    end 
    return
end

% If there isn't a colorbar, make it now 
if isempty(hCbar)
    hCbar = colorbar('peer',hAx);
end

switch get(hCbar,'Location')
    case {'East','West','EastOutside','WestOutside'}
        scaleName = 'YScale';
    case {'North','South','NorthOutside','SouthOutside'}
        scaleName = 'XScale';
end

% Set the colorbar axes scale to 'log'
set(hCbar,scaleName,'log')
    
end % End of function LogZPlotColorbar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%