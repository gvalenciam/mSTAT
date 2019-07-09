%-----------------MEANDER STATISTICS TOOLBOX. MStaT------------------------
%
% Meander Statistics Toolbox (MStaT), is a packaging of codes developed on 
% MATLAB, which allows the quantification of parameters dexscriptors of 
% meandering channels (sinuosity, arc-wavelength, amplitude, curvature, 
% inflection point, among other). To obtain all the meander parameters  
% MStaT uses the  function of wavelet transform to decompose the signail 
% (centerline). The toolbox obtains the Wavelet Spectrum, Curvature and 
% Angle Variation and the Global Wavelet Spectrum. The input data to use 
% MStaT is the Centerline (in a Coordinate System) and the average Width of 
% the study Channels. MStaT can analize a large number of bends in a short 
% time. Also MStaT allows calculate the migration of a period, and analizes 
% the migration signature. Finally MStaT has a Confluencer and Difuencer 
% toolbox that allow calculate the influence due the presence of the 
% tributary o distributary channel on the main channel. 
% For more information you can reviewed the Gutierrez and Abad 2014a and 
% Gutierrez and Abad 2014b.

%% Collaborations
% Lucas Dominguez. UNL, Argentina
% Jorge Abad. UTEC, Peru
% Ronald Gutierrez. UN, Colombia
%--------------------------------------------------------------------------

%      Begin initialization code - DO NOT EDIT.

function varargout = mStat(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mStat_OpeningFcn, ...
                   'gui_OutputFcn',  @mStat_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);               
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
% If ERROR, write a txt file with the error dump info
try
    
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
catch err
    if isdeployed
        errLogFileName = fullfile(pwd,...
            ['errorLog' datestr(now,'yyyymmddHHMMSS') '.txt']);
        msgbox({['An unexpected error occurred. Error code: ' err.identifier];...
            ('Error details are being written to the following file: ');...
            errLogFileName},...
            'MStaT Status: Unexpected Error',...
            'error');
        fid = fopen(errLogFileName,'W');
        fwrite(fid,err.getReport('extended','hyperlinks','off'));
        fclose(fid);
        rethrow(err)
    else
        close force
        msgbox(['An unexpected error occurred. Error code: ' err.identifier],...
            'MStaT Status: Unexpected Error',...
            'error');
        rethrow(err);
    end
end

%--------------------------------------------------------------------------

function mStat_OpeningFcn(hObject, eventdata, handles, varargin)
%      This function executes just before mStat is made 
%      visible.  This function has no output arguments (see OutputFcn), 
%      however, the following input arguments apply.  
addpath utils
handles.output = hObject;
handles.mStat_version='v1.00';
% Set the name and version
set(handles.figure1,'Name',['Meander Statistics Toolbox (MStaT) ' handles.mStat_version], ...
    'DockControls','off')

set_enable(handles,'init')

% Draw the mstat Background
% -----------------
% pos = get(handles.mStatBackground,'position');
% axes(handles.mStatBackground);
% % if ~isdeployed 
%     X = imread('MStaT_background.png');
%     imdisp(X,'size',[pos(4) pos(3)]) % Avoids problems with users not having Image Processing TB
% % else
% %     X = imread('MStaT_background.jpg');
% %     X = imresize(X, [pos(4) pos(3)]);
% %     X = uint8(X);
% %     imshow(X,'Border','tight')
% % end
% uistack(handles.mStatBackground,'bottom')
axes(handles.pictureReach); 

%data cursor type
dcm_obj = datacursormode(gcf);

set(dcm_obj,'UpdateFcn',@mStat_myupdatefcn);

set(dcm_obj,'Displaystyle','Window','Enable','on');
pos = get(0,'userdata');

%%%%%%%%%
%scalebar
%%%%%%%%%

% Push messages to Log Window:
    % ----------------------------
    log_text = {...
        '';...
        ['%----------- ' datestr(now) ' ------------%'];...
        'LETs START!!!'};
    statusLogging(handles.LogWindow, log_text)
handles.start=1;
guidata(hObject, handles);%      Updates handles structure.

%--------------------------------------------------------------------------

function varargout = mStat_OutputFcn(hObject, eventdata, handles)
%      Output arguments from this function are returned to the command line. 
%      Input arguments from this function are defined as below.  
%
varargout{1} = handles.output;

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
pos = get(handles.mStatBackground,'position');
 axes(handles.mStatBackground);
% if ~isdeployed 
   X = imread('MStaT_background.png');
   imdisp(X,'size',[pos(4) pos(3)]) % Avoids problems with users not having Image Processing TB
% else
%    X = imread('MStaT_background.jpg');
%    X = imresize(X, [pos(4) pos(3)]);
%    X = uint8(X);
%    imshow(X,'Border','tight')
% end

%axes(handles.pictureReach);
%uistack(handles.mStatBackground,'bottom')

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
close_button = questdlg(...
    'You are about to exit MStaT. Any unsaved work will be lost. Are you sure?',...
    'Exit MStaT?','No');
switch close_button
    case 'Yes'
        delete(hObject)
        close all hidden
    otherwise
        return
end

%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%Menu Toolbars
%%%%%%%%%%%%%%%%

% -------------------------------------------------------------------------
function file_Callback(hObject, eventdata, handles)
%Empty

% -------------------------------------------------------------------------
function newproject_Callback(hObject, eventdata, handles)
%New project function
axes(handles.pictureReach)
cla(handles.pictureReach)
clear handles.geovar
clc

% Push messages to Log Window:
% ----------------------------
log_text = {...
            '';...
            ['%--- ' datestr(now) ' ---%'];...
            'NEW PROJECT!'};
            statusLogging(handles.LogWindow, log_text)
                
set_enable(handles,'init')


% -------------------------------------------------------------------------
function openfunction_Callback(hObject, eventdata, handles)
%Open function
set_enable(handles,'init')

%This function incorporate the initial data input
multisel='on';

%Empty file flag
emptyFiles = 0;

persistent lastPath 
% If this is the first time running the function this session,
% Initialize lastPath to 0
if isempty(lastPath) 
    lastPath = 0;
end

%River Average Width input mode (Comment and uncomment test)
flagAverageWidth = "manual";
%flagAverageWidth = "auto";
handles.flagAverageWidth = flagAverageWidth;

%mSTAT plot flag (Comment and uncomment test)
%handles.plotFlag = "no_plot";
handles.plotFlag = "plot";

%Save variables in handles
guidata(hObject, handles);
    
[ReadVar] = mStat_ReadInputFiles(multisel,lastPath, handles);

handles.File = ReadVar.File;

% assignin('base','xCoord',ReadVar.xCoord);
% assignin('base','yCoord',ReadVar.yCoord);
% assignin('base','width',ReadVar.width);

% Use the path to the last selected file
% If 'uigetfile' is called, but no item is selected, 'lastPath' is not overwritten with 0
if ReadVar.Path ~= 0
    lastPath = ReadVar.Path;
end

if (ReadVar.numfile > 1)
    
    for i=1:ReadVar.numfile
        
        if ReadVar.File{i} == 0 %empty file
        
            emptyFiles = 1;
            
        end
    
    end
    
else
    
    if ReadVar.File == 0 %empty file
        
        emptyFiles = 1;
        
    end
end
  
if emptyFiles == 1
    
else

    % Push messages to Log Window:
    % ----------------------------
%     log_text = {...
%                 '';...
%                 ['%--- ' datestr(now) ' ---%'];...
%                 'File Loaded:';[cell2mat({ReadVar.File})]};
%                 statusLogging(handles.LogWindow, log_text)
    
    %Name of files selected saved to handles
    handles.numFile = ReadVar.numfile;
    
    %Save variables in handles
    guidata(hObject, handles);
    
    %Additional variables
    Tools = 1; %Geometric parameters
    level = 5; %Decomposition level default
    
    handles.xCoord = [];
    handles.yCoord = [];
    handles.width = [];
    handles.geovar = [];
    
    %Multifile option
    if (ReadVar.numfile > 1)
        
        for i=1:ReadVar.numfile
            
            handles.xCoord{i} = ReadVar.xCoord{i}(:);
            handles.yCoord{i} = ReadVar.yCoord{i}(:);
            handles.formatfileread{i} = ReadVar.comp{i};
            %For this mode width value is assigned automatically from the input file
            handles.width{i} = ReadVar.width{i};            
            guidata(hObject, handles);
            set_enable(handles,'loadfiles');
            
            %Write and store the width
            %set(handles.widthinput{i}, 'String', handles.width{i});
            %setappdata(0,'width', handles.width{i});
            
            %Read selector (Method of calculate Infletion or valley line)
            sel = get(handles.selector,'Value');
            
            %Write the level
            set(handles.decompositionparameter, 'String', level);
            
            %Calculate and plot planar variables
            [geovar] = mStat_planar(handles.xCoord{i}, handles.yCoord{i}, handles.width{i}, sel, handles.pictureReach, handles.bendSelect, Tools, level, handles.plotFlag);
            
            %Save geovar in handles
            handles.geovar{i} = geovar;
            guidata(hObject, handles);
            
            %enable results
            set_enable(handles,'results');
            
        end
        
        for i=1:handles.numFile
        
            tableValues = [cell2mat({handles.geovar{i}.nBends}), cell2mat({round(nanmean(handles.geovar{i}.sinuosityOfBends),2)}), cell2mat({round(nanmean(handles.geovar{i}.lengthCurved),2)}), cell2mat({round(nanmean(handles.geovar{i}.wavelengthOfBends),2)}), cell2mat({round(nanmean(handles.geovar{i}.amplitudeOfBends),2)})];
            tableHeaders = ["numberBends", "Sinuosity", "Arc_Wavelength", "Wavelength", "Amplitude"];

            assignin('base','H',tableHeaders);
            assignin('base','V',tableValues);
            
            %output file
            fid = fopen(strcat(strcat(pwd, "/Outputs/"), strcat("out_", ReadVar.File{i})),'wt'); 

            for j = 1:5
                fprintf(fid,'%s',tableHeaders(1,j));
                fprintf(fid,'\t');
                fprintf(fid,'%.3f',tableValues(1,j));
                fprintf(fid,'\n');
            end

            fclose(fid);

        end
        
    %Single file option     
    else
        
        handles.xCoord = ReadVar.xCoord{:};
        handles.yCoord = ReadVar.yCoord{:};
        handles.formatfileread = ReadVar.comp;
        guidata(hObject, handles);
        set_enable(handles,'loadfiles') 
        
        if (strcmp(flagAverageWidth, "auto") == 1)
            handles.width = ReadVar.width;
        elseif (strcmp(flagAverageWidth, "manual") == 1)
            % Input the average width of channel
            x = newid('Channel average width [meters]:', 'MStaT', [1 50]);
            handles.width = str2num(x{:}); 
        else
            %Default
            x = newid('Channel average width [meters]:', 'MStaT', [1 50]);
            handles.width = str2num(x{:}); 
        end
        
        %Control the average width input
        if handles.width == 0 
            handles.warning = warndlg('Please enter a value for the river width.',...
            'WARNING');
        elseif isnan(handles.width) == 1 
            handles.warning = warndlg('Please enter a numeric value.','WARNING');
        end
        
        %Write and store the width
        set(handles.widthinput, 'String', handles.width);
        setappdata(0,'width', handles.width);
        
        %Read selector (Method of calculate Infletion or valley line)
        sel = get(handles.selector,'Value');
        
        %Write the level
        set(handles.decompositionparameter, 'String', level);
        
        %Calculate and plot planar variables
        [geovar] = mStat_planar(handles.xCoord, handles.yCoord, handles.width, sel, handles.pictureReach, handles.bendSelect, Tools, level, handles.plotFlag);
        
        %Save geovar in handles
        handles.geovar = geovar;
        guidata(hObject, handles);
        
        %Retrieve the selected bend ID number from the "bendSelect" listbox.
        selectedBend = get(handles.bendSelect,'Value');
        handles.selectedBend = num2str(selectedBend);

        %setappdata is a function which allows the selected bend to be accessed by multiple GUI windows.  
        setappdata(0, 'selectedBend', handles.selectedBend);
        guidata(hObject, handles);
        
        %Start by retreiving the selected bend given the user input from the "bendSelect" listbox. 
        handles.selectedBend = getappdata(0, 'selectedBend');
        handles.selectedBend = str2double(handles.selectedBend);
        guidata(hObject, handles);

        %to export kml
        handles.utmzone = ReadVar.utmzone{1}; %without data
        guidata(hObject, handles);
        
        %enable results
        set_enable(handles,'results');
        
        % Push messages to Log Window:
        % ----------------------------
        log_text = {...
                    '';...
                    ['%--- ' datestr(now) ' ---%'];...
                    'Summary';...
                    'Total Length Analyzed [km]:';[cell2mat({geovar.intS(end,1)/1000})];...
                    'Bends Found:';[cell2mat({geovar.nBends})];...
                    'Mean Sinuosity:';[cell2mat({nanmean(geovar.sinuosityOfBends)})];...
                    'Mean Amplitude [m]:';[cell2mat({nanmean(geovar.amplitudeOfBends)})];...
                    'Mean Arc-Wavelength [m]:';[cell2mat({nanmean(geovar.lengthCurved)})];...
                    'Mean Wavelength [m]:';[cell2mat({nanmean(geovar.wavelengthOfBends)})]};
                    statusLogging(handles.LogWindow, log_text)
        
    end
    
    assignin('base','geovar',geovar);
                   
end  
    

% --------------------------------------------------------------------
function close_Callback(hObject, eventdata, handles)
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Export function

% --------------------------------------------------------------------
function exportfunction_Callback(hObject, eventdata, handles)
%Empty

%Matlab Export
% --------------------------------------------------------------------
function exportmat_Callback(hObject, eventdata, handles)
saveDataCallback(hObject, eventdata, handles)

% Push messages to Log Window:
% ----------------------------
log_text = {...
            '';...
            ['%--- ' datestr(now) ' ---%'];...
            'Export .mat Filesuccesfully!'};
            statusLogging(handles.LogWindow, log_text)
            

           

function saveDataCallback(hObject, eventdata, handles)
hwait = waitbar(0,'Exporting .mat File...');

[handles.FileName,handles.PathName] = uiputfile('*.mat','Save .mat file');

Parameters.PathFileName  = fullfile(handles.PathName,handles.FileName);                           
Parameters.geovar = handles.geovar;
waitbar(0.5,hwait)

save([handles.PathName handles.FileName], 'Parameters');
            
waitbar(1,hwait)
delete(hwait)


%Excel Export
% --------------------------------------------------------------------
function exportexcelfile_Callback(hObject, eventdata, handles)
%savexlsDataCallback(hObject, eventdata, handles)
saveBendsData(hObject, eventdata, handles)

% Push messages to Log Window:
% ----------------------------
log_text = {...
            '';...
            ['%--- ' datestr(now) ' ---%'];...
            'Export .xlsx File succesfully!'};
            statusLogging(handles.LogWindow, log_text)
            
function savexlsDataCallback(hObject, eventdata, handles)
mStat_savexlsx(handles.geovar)

function saveBendsData(hObject, eventdata, handles)
mStat_saveBendsData(handles.geovar)


%Google Export
% --------------------------------------------------------------------
function exportkmzfile_Callback(hObject, eventdata, handles)
%This function esport the kmzfile for Google Earth

[file,path] = uiputfile('*','Save .kml File');

namekml=(fullfile(path,file));

% 3 file export function
%first
[xcoord,ycoord]=utm2deg(handles.xCoord,handles.xCoord,char(handles.utmzone(:,1:4)));
latlon1=[xcoord ycoord];

%second
for i=1:length(handles.geovar.xValleyCenter)
    utmzoneva(i,1)=cellstr(handles.utmzone(1,1:4));
end
utmva=char(utmzoneva);

[xvalley,yvalley]=utm2deg(handles.geovar.xValleyCenter,handles.geovar.yValleyCenter,char(utmzoneva));
latlon2=[xvalley yvalley];

%third
for i=1:length(handles.geovar.inflectionX)
    utmzoneinf(i,1)=cellstr(handles.utmzone(1,1:4));
end

[xinflectionY,yinflectionY]=utm2deg(handles.geovar.inflectionX,handles.geovar.inflectionY,char(utmzoneinf));
latlon3=[xinflectionY yinflectionY];

% Write latitude and longitude into a KML file
mStat_kml(namekml,latlon1,latlon2,latlon3);

% Push messages to Log Window:
% ----------------------------
log_text = {...
            '';...
            ['%--- ' datestr(now) ' ---%'];...
            'Export .kml File succesfully!'};
            statusLogging(handles.LogWindow, log_text)
            
    

%Export Figures    
% --------------------------------------------------------------------
function exportfiguregraphics_Callback(hObject, eventdata, handles)
%export figure function
[file,path] = uiputfile('*.tif','Save .tif File');

F = getframe(handles.pictureReach);
Image = frame2im(F);
imwrite(Image, fullfile(path,file),'Resolution',500)

% Push messages to Log Window:
% ----------------------------
log_text = {...
            '';...
            ['%--- ' datestr(now) ' ---%'];...
            'Export .tif File succesfully!'};
            statusLogging(handles.LogWindow, log_text)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Tools
% --------------------------------------------------------------------
function tools_Callback(hObject, eventdata, handles)
% Empty

% --------------------------------------------------------------------
function evaldecomp_Callback(hObject, eventdata, handles)
% Empty

% --------------------------------------------------------------------
function waveletanalysis_Callback(hObject, eventdata, handles)
%Wavelet analysis
geovar=handles.geovar;
handles.getWaveStats = mStat_WaveletAnalysis(geovar);


% --------------------------------------------------------------------
function riverstatistics_Callback(hObject, eventdata, handles)
% This function executes when the user presses the getRiverStats button
% and requires the following input arguments.
handles.getRiverStats = mStat_StatisticsVariables(handles);


% --------------------------------------------------------------------
function migrationanalyzer_Callback(hObject, eventdata, handles)
%Migration Analyzer Tool
mStat_MigrationAnalyzer;

% --------------------------------------------------------------------
function confluencesanalyzer_Callback(hObject, eventdata, handles)
%Confluences and Bifurcation Tools
mStat_ConfluencesAnalyzer;


% --------------------------------------------------------------------
function backgroundimage_Callback(hObject, eventdata, handles)
% Add backgroud image
[handles.FileImage,handles.PathImage] = uigetfile({'*.jpg';'*.tif';'*.*'},'Select Graphic File');
guidata(hObject,handles)

if handles.FileImage==0
else
    axes(handles.pictureReach);
    hold on;
    mapshow(fullfile(handles.PathImage,handles.FileImage))
    hold on;

    mStat_plotplanar(handles.geovar.equallySpacedX, handles.geovar.equallySpacedY, handles.geovar.inflectionPts, ...
    handles.geovar.x0, handles.geovar.y0, handles.geovar.x_sim, handles.geovar.newMaxCurvX, handles.geovar.newMaxCurvY, ...
    handles.pictureReach);

    msgbox(['Successfully update'],...
        'Background Image');
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Settings
% --------------------------------------------------------------------
function setti_Callback(hObject, eventdata, handles)
% Empty


% --------------------------------------------------------------------
function unitsfunction_Callback(hObject, eventdata, handles)
% Empty


% --------------------------------------------------------------------
function metricunits_Callback(hObject, eventdata, handles)
% Metric factor function
if handles.start==0
    munits=1/0.3048;
else
    munits=1;
end
handles.geovar.lengthCurved=handles.geovar.lengthCurved*munits;
handles.geovar.wavelengthOfBends=handles.geovar.wavelengthOfBends*munits;
handles.geovar.amplitudeOfBends=handles.geovar.amplitudeOfBends*munits;
handles.geovar.downstreamSlength=handles.geovar.downstreamSlength*munits;
handles.geovar.upstreamSlength=handles.geovar.upstreamSlength*munits;
handles.width=handles.width*munits;
guidata(hObject,handles)

set(handles.widthinput,'String',handles.width)

% Retrieve the selected bend ID number from the "bendSelect" listbox.
selectedBend = get(handles.bendSelect,'Value');

% -------------------------------------------------------------------------

% Assign the bend statistics to an output array.
matrixOfBendStatistics = [handles.geovar.sinuosityOfBends(selectedBend),...
    handles.geovar.lengthStraight(selectedBend),handles.geovar.lengthCurved(selectedBend),...
    handles.geovar.wavelengthOfBends(selectedBend), handles.geovar.amplitudeOfBends(selectedBend),...
    handles.geovar.downstreamSlength(selectedBend),handles.geovar.upstreamSlength(selectedBend)];

matrixOfBendStatistics = matrixOfBendStatistics';

% Setappdata is a function which allows the matrix of bend statistics
% to be accessed by multiple GUI windows.  
setappdata(0, 'matrixOfBendStatistics', matrixOfBendStatistics);
guidata(hObject, handles);

% Set the statistics to the "IndividualStats" table in 
% the main GUI.  
set(handles.sinuosity, 'String', round(handles.geovar.sinuosityOfBends(selectedBend),2));
set(handles.curvaturel, 'String', round(handles.geovar.lengthCurved(selectedBend),2));
set(handles.wavel, 'String', round(handles.geovar.wavelengthOfBends(selectedBend),2));
set(handles.amplitude, 'String', round(handles.geovar.amplitudeOfBends(selectedBend),2));
set(handles.dstreamL, 'String', round(handles.geovar.downstreamSlength(selectedBend),2));
set(handles.ustreamL, 'String', round(handles.geovar.upstreamSlength(selectedBend),2));
handles.munits=1;
guidata(hObject, handles);


% --------------------------------------------------------------------
function englishunits_Callback(hObject, eventdata, handles)
% English units

eunits=0.3048;

handles.geovar.lengthCurved=handles.geovar.lengthCurved*eunits;
handles.geovar.wavelengthOfBends=handles.geovar.wavelengthOfBends*eunits;
handles.geovar.amplitudeOfBends=handles.geovar.amplitudeOfBends*eunits;
handles.geovar.downstreamSlength=handles.geovar.downstreamSlength*eunits;
handles.geovar.upstreamSlength=handles.geovar.upstreamSlength*eunits;
handles.width=handles.width*eunits;
guidata(hObject,handles)

set(handles.widthinput,'String',handles.width)

% Retrieve the selected bend ID number from the "bendSelect" listbox.
selectedBend = get(handles.bendSelect,'Value');

% -------------------------------------------------------------------------

% Assign the bend statistics to an output array.
matrixOfBendStatistics = [handles.geovar.sinuosityOfBends(selectedBend),...
    handles.geovar.lengthStraight(selectedBend),handles.geovar.lengthCurved(selectedBend),...
    handles.geovar.wavelengthOfBends(selectedBend), handles.geovar.amplitudeOfBends(selectedBend),...
    handles.geovar.downstreamSlength(selectedBend),handles.geovar.upstreamSlength(selectedBend)];

matrixOfBendStatistics = matrixOfBendStatistics';

% Setappdata is a function which allows the matrix of bend statistics
% to be accessed by multiple GUI windows.  
setappdata(0, 'matrixOfBendStatistics', matrixOfBendStatistics);
guidata(hObject, handles);

% Set the statistics to the "IndividualStats" table in 
% the main GUI.  
set(handles.sinuosity, 'String', round(handles.geovar.sinuosityOfBends(selectedBend),2));
set(handles.curvaturel, 'String', round(handles.geovar.lengthCurved(selectedBend),2));
set(handles.wavel, 'String', round(handles.geovar.wavelengthOfBends(selectedBend),2));
set(handles.amplitude, 'String', round(handles.geovar.amplitudeOfBends(selectedBend),2));
set(handles.dstreamL, 'String',round(handles.geovar.downstreamSlength(selectedBend),2));
set(handles.ustreamL, 'String', round(handles.geovar.upstreamSlength(selectedBend),2));
handles.eunits=0.3048;
guidata(hObject, handles);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Help
% --------------------------------------------------------------------
function helpfunction_Callback(hObject, eventdata, handles)
% Empty


% --------------------------------------------------------------------
function usersguide_Callback(hObject, eventdata, handles)
%Send to web page with code modufy to github
try
    web('https://meanderstatistics.blogspot.com/p/tutorials.html')
catch err %#ok<NASGU>
	if isdeployed
        errLogFileName = fullfile(pwd,...
            ['errorLog' datestr(now,'yyyymmddHHMMSS') '.txt']);
        msgbox({['An unexpected error occurred. Error code: ' err.identifier];...
            ['Error details are being written to the following file: '];...
            errLogFileName},...
            'MStaT Status: Unexpected Error',...
            'error');
        fid = fopen(errLogFileName,'W');
        fwrite(fid,err.getReport('extended','hyperlinks','off'));
        fclose(fid);
        rethrow(err)
    else
        msgbox(['An unexpected error occurred. Error code: ' err.identifier],...
            'MStaT Status: Unexpected Error',...
            'error');
        rethrow(err);
    end
end


% --------------------------------------------------------------------
function checkforupdates_Callback(hObject, eventdata, handles)
%Send to web page for updates
try
    web('https://meanderstatistics.blogspot.com/p/download.html')
catch err %#ok<NASGU>
	if isdeployed
        errLogFileName = fullfile(pwd,...
            ['errorLog' datestr(now,'yyyymmddHHMMSS') '.txt']);
        msgbox({['An unexpected error occurred. Error code: ' err.identifier];...
            ['Error details are being written to the following file: '];...
            errLogFileName},...
            'MStaT Status: Unexpected Error',...
            'error');
        fid = fopen(errLogFileName,'W');
        fwrite(fid,err.getReport('extended','hyperlinks','off'));
        fclose(fid);
        rethrow(err)
    else
        msgbox(['An unexpected error occurred. Error code: ' err.identifier],...
            'MStaT Status: Unexpected Error',...
            'error');
        rethrow(err);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Initial Panel

function widthinput_Callback(hObject, eventdata, handles)
% Empty


% --- Executes during object creation, after setting all properties.
function widthinput_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in recalculate.
function recalculate_Callback(hObject, eventdata, handles)
%Recalculate using a New Width 

% clear figures and data 
axes(handles.pictureReach)
cla(handles.pictureReach)
clear selectBend
clc
guidata(hObject,handles)
%set_enable(handles,'init')

%Take new width
handles.width = str2double(get(handles.widthinput,'String'));
guidata(hObject,handles)

%  Store width
setappdata( 0,'width', handles.width)

%Method selected
sel=get(handles.selector,'Value');

Tools=1;%Geometry parameter

% Read the decompouse parameter
level = str2double(get(handles.decompositionparameter,'String'));

%Calculate and plot planar variables
[geovar]=mStat_planar(handles.xCoord,handles.yCoord,handles.width,sel,...
    handles.pictureReach,handles.bendSelect,Tools,level);

%save handles
handles.geovar=geovar;
guidata(hObject, handles);

% Push messages to Log Window:
% ----------------------------
log_text = {...
            '';...
            ['%--- ' datestr(now) ' ---%'];...
            'Summary';...
            'Total Length Analyzed [km]:';[cell2mat({round((geovar.intS(end,1)/1000),2)})];...
            'Bends Found:';[cell2mat({geovar.nBends})];...
            'Mean Sinuosity:';[cell2mat({round(nanmean(geovar.sinuosityOfBends),2)})];...
            'Mean Amplitude [m]:';[cell2mat({round(nanmean(geovar.amplitudeOfBends),2)})];...
            'Mean Arc-Wavelength [m]:';[cell2mat({round(nanmean(geovar.lengthCurved),2)})];...
            'Mean Wavelength[m]:';[cell2mat({round(nanmean(geovar.wavelengthOfBends),2)})]};
            statusLogging(handles.LogWindow, log_text)
                    
set_enable(handles,'results')

% --------------------------------------------------------------------
function bendstatistics_Callback(hObject, eventdata, handles)
% This function executes when the user presses the Get Bend panel 
% button and requires the following input arguments.  
%
% Retrieve the selected bend ID number from the "bendSelect" listbox.
selectedBend = get(handles.bendSelect,'Value');
handles.selectedBend = num2str(selectedBend);

% Setappdata is a function which allows the selected bend
% to be accessed by multiple GUI windows.  
setappdata(0, 'selectedBend', handles.selectedBend);
guidata(hObject, handles);

% Start by retreiving the selected bend given the user input from the
% "bendSelect" listbox. 
handles.selectedBend = getappdata(0, 'selectedBend');
handles.selectedBend = str2double(handles.selectedBend);

% Call the "userSelectBend" function to get the index of intersection
% points and the highlighted bend limits.  

[highlightX, highlightY, ~] = userSelectBend(handles.geovar.intS, handles.selectedBend,...
    handles.geovar.equallySpacedX,handles.geovar.equallySpacedY,handles.geovar.newInflectionPts,...
    handles.geovar.sResample);
handles.highlightX = highlightX;
handles.highlightY = highlightY;

% -------------------------------------------------------------------------
% Set the statistics to the "IndividualStats" table in 
% the main GUI.  
set(handles.sinuosity, 'String', handles.geovar.sinuosityOfBends(selectedBend));
set(handles.curvaturel, 'String', handles.geovar.lengthCurved(selectedBend));
set(handles.wavel, 'String', handles.geovar.wavelengthOfBends(selectedBend));
set(handles.amplitude, 'String', handles.geovar.amplitudeOfBends(selectedBend));
guidata(hObject, handles);
% 
% Note:  This section is repeated if the user presses the 
% "Go to Bend Statistics" button again.    
uiresume(gcbf);


% --- Executes on button press in selectData.
function selectData_Callback(hObject, eventdata, handles)
%Empty


function bendSelect_Callback(hObject, eventdata, handles)
% This function executes when the user presses the Get Bend Statistics 
% button and requires the following input arguments.  

%cla(handles.pictureReach)
guidata(hObject,handles)

% Retrieve the selected bend ID number from the "bendSelect" listbox.
selectedBend = get(handles.bendSelect,'Value');
%selectedBend = num2str(selectedBend);

% setappdata is a function which allows the selected bend
% to be accessed by multiple GUI windows.  
setappdata(0, 'selectedBend', handles.selectedBend);
guidata(hObject, handles);

% Start by retreiving the selected bend given the user input from the
% "bendSelect" listbox. 
handles.selectedBend = getappdata(0, 'selectedBend');
handles.selectedBend = str2double(handles.selectedBend);
guidata(hObject, handles);

% -------------------------------------------------------------------------

% Assign the bend statistics to an output array.
matrixOfBendStatistics = [handles.geovar.sinuosityOfBends(selectedBend),...
    handles.geovar.lengthStraight(selectedBend),handles.geovar.lengthCurved(selectedBend),...
    handles.geovar.wavelengthOfBends(selectedBend), handles.geovar.amplitudeOfBends(selectedBend),...
    handles.geovar.downstreamSlength(selectedBend),handles.geovar.upstreamSlength(selectedBend)];

matrixOfBendStatistics = matrixOfBendStatistics';

% Setappdata is a function which allows the matrix of bend statistics
% to be accessed by multiple GUI windows.  
setappdata(0, 'matrixOfBendStatistics', matrixOfBendStatistics);
guidata(hObject, handles);

% Set the statistics to the "IndividualStats" table in 
% the main GUI.  
set(handles.sinuosity, 'String', round(handles.geovar.sinuosityOfBends(selectedBend),2));
set(handles.curvaturel, 'String', round(handles.geovar.lengthCurved(selectedBend),2));
set(handles.wavel, 'String', round(handles.geovar.wavelengthOfBends(selectedBend),2));
set(handles.amplitude, 'String', round(handles.geovar.amplitudeOfBends(selectedBend),2));
set(handles.dstreamL, 'String',round(handles.geovar.downstreamSlength(selectedBend),2));
set(handles.ustreamL, 'String', round(handles.geovar.upstreamSlength(selectedBend),2));
set(handles.condition, 'String', handles.geovar.condition(selectedBend));
guidata(hObject, handles);
    
uiresume(gcbf);
%--------------------------------------------------------------------------
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Panel Selection
% --- Executes during object creation, after setting all properties.
function uipanelselect_CreateFcn(hObject, eventdata, handles)
%Empty


function bendSelect_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------


function selectData_CreateFcn(hObject, eventdata, handles)
set(hObject,'enable','off')


% --- Executes on selection change in selector.
function selector_Callback(hObject, eventdata, handles)
%This function select the bend and shows the parameters results
axes(handles.pictureReach)
cla(handles.pictureReach)
guidata(hObject,handles)

%Read selector
sel=get(handles.selector,'Value');%1 Inflectionmethod or MCM

Tools=1;%Geometry parameter

% Read the decompouse parameter
level = str2double(get(handles.decompositionparameter,'String'));

%Function of calculate
[geovar]=mStat_planar(handles.xCoord,handles.yCoord,handles.width,sel,...
    handles.pictureReach,handles.bendSelect,Tools,level);

%save handles
handles.geovar=geovar;
guidata(hObject, handles);

% Push messages to Log Window:
% ----------------------------
log_text = {...
        '';...
        ['%--- ' datestr(now) ' ---%'];...
        'Summary';...
        'Total Length Analyzed [km]:';[cell2mat({round((geovar.intS(end,1)/1000),2)})];...
        'Bends Found:';[cell2mat({geovar.nBends})];...
        'Mean Sinuosity:';[cell2mat({round(nanmean(geovar.sinuosityOfBends),2)})];...
        'Mean Amplitude [m]:';[cell2mat({round(nanmean(geovar.amplitudeOfBends),2)})];...
        'Mean Arc-Wavelength[m]:';[cell2mat({round(nanmean(geovar.lengthCurved),2)})];...
        'Mean Wavelength [m]:';[cell2mat({round(nanmean(geovar.wavelengthOfBends),2)})]};
        statusLogging(handles.LogWindow, log_text)


% --- Executes during object creation, after setting all properties.
function selector_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%--------------------------------------------------------------------------
% --- Executes on button press in gobend.
function gobend_Callback(hObject, eventdata, handles)
%This function go to bend selected and replot the picture

cla(handles.pictureReach)
mStat_plotplanar(handles.geovar.equallySpacedX, handles.geovar.equallySpacedY, handles.geovar.inflectionPts, ...
    handles.geovar.x0, handles.geovar.y0, handles.geovar.x_sim, handles.geovar.newMaxCurvX, handles.geovar.newMaxCurvY, ...
    handles.pictureReach);

%zoom out

selectedBend = get(handles.bendSelect,'Value');

 if handles.geovar.amplitudeOfBends(selectedBend)~=0 || isfinite(handles.geovar.upstreamSlength)
    %      selectdata text labels for all bends.    
    axes(handles.pictureReach); 
    set(gca, 'Color', 'w')
    %axis normal; 
    dx = 2000;
    dy = 2000;
    loc = find(handles.geovar.newMaxCurvS == handles.geovar.bend(selectedBend,2));
    zoomcenter(handles.geovar.newMaxCurvX(loc),handles.geovar.newMaxCurvY(loc),10)
 else 
 end

% Call the "userSelectBend" function to get the index of intersection
% points and the highlighted bend limits.  
[handles.highlightX, handles.highlightY, ~] = userSelectBend(handles.geovar.intS, selectedBend,...
    handles.geovar.equallySpacedX,handles.geovar.equallySpacedY,handles.geovar.newInflectionPts,...
    handles.geovar.sResample);

 axes(handles.pictureReach);
% hold on
handles.highlightPlot = line(handles.highlightX(1,:), handles.highlightY(1,:), 'color', 'y', 'LineWidth',8); 

guidata(hObject,handles)
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Planar Parameters Display
function sinuosity_Callback(hObject, eventdata, handles)
%Empty

% --- Executes during object creation, after setting all properties.
function sinuosity_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function curvaturel_Callback(hObject, eventdata, handles)
%Empty


% --- Executes during object creation, after setting all properties.
function curvaturel_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function wavel_Callback(hObject, eventdata, handles)
% Empty


% --- Executes during object creation, after setting all properties.
function wavel_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function amplitude_Callback(hObject, eventdata, handles)
% Empty


% --- Executes during object creation, after setting all properties.
function amplitude_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Extra Functions

% --- Executes during object creation, after setting all properties.
function condition_CreateFcn(hObject, eventdata, handles)
% Empty


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
%Empty


% --- Executes during object creation, after setting all properties.
function IndividualStats_CreateFcn(hObject, eventdata, handles)
% Empty 


% --- Executes on button press in withinflectionpoints.
function withinflectionpoints_Callback(hObject, eventdata, handles)
% Empty


% --- Executes on button press in withvalleyline.
function withvalleyline_Callback(hObject, eventdata, handles)
% Empty


% --- Executes during object creation, after setting all properties.
function mStatBackground_CreateFcn(hObject, eventdata, handles)
%empty


% --- Executes on mouse press over axes background.
function pictureReach_ButtonDownFcn(hObject, eventdata, handles)
pan(handles.pictureReach)


function set_enable(handles,enable_state)
switch enable_state
case 'init'
    set(handles.widthinput,'String','','Enable','off')
    set(handles.sinuosity,'String','','Enable','off')
    set(handles.curvaturel,'String','','Enable','off')
    set(handles.wavel,'String','','Enable','off')
    set(handles.amplitude,'String','','Enable','off')
    set(handles.ustreamL,'String','','Enable','off')
    set(handles.dstreamL,'String','','Enable','off')
    set(handles.condition,'String','','Enable','off')
    set(handles.bendSelect,'Visible','off','String','','Enable','off')
    set(handles.exportfunction,'Enable','off')
    set(handles.exportkmzfile,'Enable','off')
    set(handles.setti,'Enable','off') 
    set(handles.recalculate,'Enable','off')    
    set(handles.gobend,'Enable','off')   
    set(handles.selector,'Enable','off')  
    set(handles.bendSelect,'Enable','off') 
    set(handles.waveletanalysis,'Enable','off')
    set(handles.decompositionparameter,'String','','Enable','off')
    set(handles.riverstatistics,'Enable','off')
    set(handles.backgroundimage,'Enable','off')
    axes(handles.pictureReach)
    cla(handles.pictureReach)
    clear selectBend
    clc
    case 'loadfiles'
    set(handles.widthinput,'Enable','on')
    set(handles.sinuosity,'Enable','on')
    set(handles.curvaturel,'Enable','on')
    set(handles.wavel,'Enable','on')
    set(handles.amplitude,'Enable','on')
    set(handles.ustreamL,'Enable','on')
    set(handles.dstreamL,'Enable','on')
    set(handles.bendSelect,'Visible','on','Enable','on')
    set(handles.condition,'String','','Enable','on')
    %set(handles.tools,'Enable','on')
    set(handles.decompositionparameter,'Enable','on')
    set(handles.setti,'Enable','on')
    set(handles.recalculate,'Enable','on') 
    set(handles.gobend,'Enable','on')
    set(handles.selector,'Enable','on')  
    set(handles.bendSelect,'Enable','on')  
    case 'results'
    set(handles.waveletanalysis,'Enable','on')  
    set(handles.riverstatistics,'Enable','on')  
    set(handles.exportfunction,'Enable','on')
%     if  strcmp(handles.formatfileread{2}, 'kml') == 1
%     set(handles.exportkmzfile,'Enable','on')
%     end
    handles.start=0;
    set(handles.backgroundimage,'Enable','on')
    otherwise                
end
       

% --------------------------------------------------------------------
function pictureReach_CreateFcn(hObject, eventdata, handles)
%Empty


% --------------------------------------------------------------------
function pictureReach_DeleteFcn(hObject, eventdata, handles)
%Empty
% 


% % --------------------------------------------------------------------
function Opengui_ClickedCallback(hObject, eventdata, handles)
openfile_Callback(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%
%Toolbar editor
%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on selection change in LogWindow.
function LogWindow_Callback(hObject, eventdata, handles)
% empty


% --- Executes during object creation, after setting all properties.
function LogWindow_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function decompositionparameter_Callback(hObject, eventdata, handles)
% empty


% --- Executes during object creation, after setting all properties.
function decompositionparameter_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
                                                                                                                                    

% --------------------------------------------------------------------
function export_txt_average_values_Callback(hObject, eventdata, handles)
% hObject    handle to export_txt_average_values (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (handles.numFile > 1)
    
    for i=1:handles.numFile
        
        tableValues = [cell2mat({handles.geovar{i}.nBends}), cell2mat({round(nanmean(handles.geovar{i}.sinuosityOfBends),2)}), cell2mat({round(nanmean(handles.geovar{i}.lengthCurved),2)}), cell2mat({round(nanmean(handles.geovar{i}.wavelengthOfBends),2)}), cell2mat({round(nanmean(handles.geovar{i}.amplitudeOfBends),2)})];
        tableHeaders = ["numberBends", "Sinuosity", "Arc_Wavelength", "Wavelength", "Amplitude"];

        assignin('base','H',tableHeaders);
        assignin('base','V',tableValues);
        %output file
        fid = fopen(strcat(strcat('river_metrics_', num2str(i)), '.txt'),'wt'); 

        for j = 1:length(tableHeaders)
            fprintf(fid,'%s',tableHeaders(1,j));
            fprintf(fid,'\t');
            fprintf(fid,'%.3f',tableValues(1,j));
            fprintf(fid,'\n');
        end

        fclose(fid);
        
    end
    
else
    
    tableValues = [cell2mat({handles.geovar.nBends}), cell2mat({round(nanmean(handles.geovar.sinuosityOfBends),2)}), cell2mat({round(nanmean(handles.geovar.lengthCurved),2)}), cell2mat({round(nanmean(handles.geovar.wavelengthOfBends),2)}), cell2mat({round(nanmean(handles.geovar.amplitudeOfBends),2)})];
    tableHeaders = ["numberBends", "Sinuosity", "Arc_Wavelength", "Wavelength", "Amplitude"];

    assignin('base','H',tableHeaders);
    assignin('base','V',tableValues);
    %output file
    fid = fopen('subjectlist.txt','wt'); 
    
    for i=1:5
        fprintf(fid,'%s',tableHeaders(1,i));
        fprintf(fid,'\t');
        fprintf(fid,'%.3f',tableValues(1,i));
        fprintf(fid,'\n');
    end

    fclose(fid);
    
end


% --------------------------------------------------------------------
function export_meancenterline_Callback(hObject, eventdata, handles)
% hObject    handle to export_meancenterline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Open save file window (only shp file format for now)
[file,path] = uiputfile('*.shp', 'Save meancenterline', 'meancenterline.shp');

if(file == 0)
    %No action
else
    %Create geovector with coordinates as vector (output file of type LINE)
    geoMeancenterline = geoshape(imag(handles.geovar.x_sim), real(handles.geovar.x_sim));
    geoMeancenterline.Geometry = 'line';
    shapewrite(geoMeancenterline, strcat(path, file));
end


% --------------------------------------------------------------------
function export_bend_shapefiles_Callback(hObject, eventdata, handles)
% hObject    handle to export_bend_shapefiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for i = 1:length(handles.geovar.intS)
     v = handles.geovar.intS(i);
     [index, ~] = searchclosest(handles.geovar.sResample, v);
     
     if isnan(index)
     else
     indexOfIntersectionPoints(i) = index; 
     end
end

for i = 1:length(indexOfIntersectionPoints)
    
    if (i == 1)
        
        bend{1} = [handles.geovar.equallySpacedX(1:indexOfIntersectionPoints(i)) handles.geovar.equallySpacedY(1:indexOfIntersectionPoints(i))];
        
    else
        
        bend{i} = [handles.geovar.equallySpacedX(indexOfIntersectionPoints(i - 1):indexOfIntersectionPoints(i)) handles.geovar.equallySpacedY(indexOfIntersectionPoints(i - 1):indexOfIntersectionPoints(i))];
        
    end
    
end

assignin('base','bend',bend);
disp("BEND");
disp(length(bend));

% figure;
% 
% for j = 1:length(bend)
%     
%     plot(bend{j}(:,1), bend{j}(:,2));
%     hold on;
%     
% end

hwait = waitbar(0,'Exporting bends...');

%Open save file window (only shp file format for now)
[file,path] = uiputfile('*.shp', 'Save bends information', 'mstat_bend.shp');
split = strsplit(file, '.');
ls = length(bend) - 1;

waitbar(1/3, hwait);

if(file == 0)
    %No action
else
    
    
    geoStruct = struct('ID', 0, 'Geometry', 0, 'Lat', 0, 'Lon', 0, 'Sinuosity', 0, 'Arc_Wavelength', 0, 'Amplitude', 0);
    geoStruct = repmat(geoStruct, length(bend) - 1, 1);
    
    %Populate Geostruct
    [geoStruct(1:ls).Geometry]  = deal('Line');
    
    for i = 1:length(bend) - 1
        geoStruct(i).ID                 = length(bend) - handles.geovar.bendID1(i);
        geoStruct(i).Lat                = bend{i}(:,2);
        geoStruct(i).Lon                = bend{i}(:,1);
        geoStruct(i).Sinuosity          = handles.geovar.sinuosityOfBends(i);
        geoStruct(i).Arc_Wavelength     = handles.geovar.lengthCurved(i);
        geoStruct(i).Amplitude          = handles.geovar.amplitudeOfBends(i);
    end
    
    waitbar(2/3, hwait);
    
    assignin('base','geoStruct',geoStruct);
    shapewrite(geoStruct, strcat(path, file));
    
    waitbar(1, hwait);
    delete(hwait);
    
%     for j = 1:length(bend) - 1
%         disp(j);
%         %Create geovector with coordinates as vector (output file of type LINE)
%         geoPointVectorBend = geoshape(bend{j}(:,1), bend{j}(:,2));
%         geoPointVectorBend.Geometry = 'line';
%         geoPointVectorBend.sinuosity = handles.geovar.sinuosityOfBends(j);
%         geoPointVectorBend.arcwavelength = handles.geovar.lengthCurved(j);
%         geoPointVectorBend.amplitude = handles.geovar.amplitudeOfBends(j);
%         fileName = strcat(strcat(split(1), num2str(j)), ".shp");
%         shapewrite(geoPointVectorBend, strcat(path, fileName));
% 
%     end
    
end


% --------------------------------------------------------------------
function export_inflection_points_Callback(hObject, eventdata, handles)
% hObject    handle to export_inflection_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Open save file window (only shp file format for now)
[file,path] = uiputfile('*.shp', 'Save inflection points', 'mstat_inflection.shp');

hwait = waitbar(0,'Exporting inflection points...');

if(file == 0)
    %No action
else
    %Create geovector with coordinates as vector (output file of type Point)
    geoInflectionPoints = geoshape(handles.geovar.inflectionPts(:,2), handles.geovar.inflectionPts(:,1));
    geoInflectionPoints.Geometry = 'point';
    shapewrite(geoInflectionPoints, strcat(path, file));
end

waitbar(1, hwait);
delete(hwait);


% --------------------------------------------------------------------
function export_max_curvature_points_Callback(hObject, eventdata, handles)
% hObject    handle to export_max_curvature_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Open save file window (only shp file format for now)
[file,path] = uiputfile('*.shp', 'Save max curvature points', 'mstat_max_curvature.shp');

hwait = waitbar(0,'Exporting max curvature points...');

if(file == 0)
    %No action
else
    %Create geovector with coordinates as vector (output file of type Point)
    geoMaxCurvaturePoints = geoshape(handles.geovar.newMaxCurvY, handles.geovar.newMaxCurvX);
    geoMaxCurvaturePoints.Geometry = 'point';
    shapewrite(geoMaxCurvaturePoints, strcat(path, file));
end

waitbar(1, hwait);
delete(hwait);
