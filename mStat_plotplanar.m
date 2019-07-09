function mStat_plotplanar(equallySpacedX, equallySpacedY,inflectionPts, x0, y0, x_sim,...
newMaxCurvX, newMaxCurvY,pictureReach)

%Function create the initial panel graphs
%Dominguez Ruben 11/2017
%--------------------------------------------------------------------------
% This creates the 'background' axes.

%axes(pictureReach, 'Units', 'normalized', 'Position', [0 0 1 1]);
% pictureReach.Units = 'normalized';
% pictureReach.Position = [0 0 1 1];
pictureReach.ActivePositionProperty = 'position';
 
%  scalebar off
%  ha = axes('units','normalized', ...
% 'Position',[0 0 1 1],'DataAspectRatio',[1 1 1],...
%         'PlotBoxAspectRatio',[1 1 1]);
   
% Move the background axes to the bottom
% uistack(ha,'bottom');
% Turn the handlevisibility off so that we don't inadvertently selectData
% into the axes again.  Also, make the background axes invisible.
% set(ha,'handlevisibility','off','visible','off')
% set(gca, 'Color', 'w')
% axis equal 


% Call plotting function and selectData necessary data in the pictureReach.  
[equalPlot, inflectionCplot, intPoints1, maxCurv, wavelet] = ...
guiPlots(equallySpacedX, equallySpacedY,... 
inflectionPts, x0, y0, x_sim(:,1), ...
newMaxCurvX, newMaxCurvY, pictureReach);
xsim=x_sim(:,1);
hold on; 


%-------------------------------------------------------------------------

% Add a resizable legend to the main GUI axes.  
axes(pictureReach)
hLegend = legend([equalPlot, inflectionCplot, wavelet, ...
    intPoints1, maxCurv], ...
  'Equally Spaced Data'         , ...
  'Inflection Points'           , ...
  'Mean Center'           , ...
  'Intersection Points'         , ...
  'Maximum Curvature Points'    , ...
  'location', 'southeast' );

% End plotting section. 
