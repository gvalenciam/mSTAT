function mStat_plotWavel(geovar,sel1,SIGLVL,filter,axest,Tools,vars)

riverName = getappdata(0, 'riverName');

%SPECIFY THE FOLDER AND NAME OF THE FILE TO ANALYZE
%BedFilesFolder = ['J:\Meander_toolbox\']; 
%FileBed =[BedFilesFolder,'BigRiversCurvature.txt'];
inodes = 500; jnodes = 1; deltaS = 1; deltaN=1; Jplot=1; 
% If Jplot=-1, it plots all profiles, if not specify Jplot=Jwanted

%FileBed =[BedFilesFolder,'CF16-nocyl-all-1518x32.dat'];
%inodes = 1518; jnodes = 32; deltaS =1, deltaN=1; Jplot=31; %If Jplot=-1,
%FileBed =[BedFilesFolder,'WA9-c-nocyl-all-2136x32.dat'];
%inodes = 2136; jnodes = 32; deltaS =1, deltaN=1; Jplot=-1; %If Jplot=-1,   
%J=1, 9, 20


%Input for wavelet analysis
dt = deltaS; 
dj = 0.05;     % small dj <= 0.5; the smaller the better resolution, but it takes longer.
% Define range of scales to examine fluctuations in power 
% (limits for the Band of Scales to analyse).
Input_Band_Scale = [100];   
Epsilon = 50;
%Ranges of lower and upper scales in the band in cms

%END INPUT PARAMETERS

% SPECIFY GRAPHICS SETTINGS
OptSaveFig=1;     
% This is to save the images into jpeg formats (0 = Not saved, 1 = Saved).
LenFileName = length(riverName);  
FileBaseW = [riverName 'WaveLet'];

%input data classic capture
if Tools==1 | Tools==3;
FileBed_dataMX = geovar.sResample(:,1); % S-coordinate
FileBed_dataMZ = geovar.cResample(:,1); % C-curvature
elseif Tools==2% Moigration Toolbox
    FileBed_dataMX = vars.MigrationDistance;
    vars.MigrationSignal(isnan(vars.MigrationSignal))=-999;%Change by value default
    FileBed_dataMZ = vars.MigrationSignal/vars.deltat;
end

lenRanges = length(Input_Band_Scale);
for m=1:(lenRanges);
    Lower_Scale = Input_Band_Scale(m)-Epsilon;   
    Upper_Scale = Input_Band_Scale(m)+Epsilon; 
    jj=Jplot;
    
    if Tools==2;
        DeltaCentS=FileBed_dataMX(1,1);
        xmin=0;
    else
        DeltaCentS=FileBed_dataMX(2,1)-FileBed_dataMX(1,1);  %units.
        xmin=min(FileBed_dataMX(:,jj));
    end
    sst=transpose(FileBed_dataMZ(:,jj));
    JProfile = jj;
   [period,power,sig95M,scale_avg,scaleavg_signif] = mStat_WaveletCenterline(...
       JProfile,jnodes,DeltaCentS,sst,OptSaveFig,FileBaseW,xmin,dt,dj,...
       Lower_Scale,Upper_Scale,SIGLVL,geovar.equallySpacedX,...
       geovar.equallySpacedY,geovar.angle,sel1,filter,axest,Tools,vars); 
end  
handles.sel1 = num2str(sel1);
setappdata(0, 'sel1', handles.sel1);
handles.clearfig=1;
% guidata(hObject, handles);