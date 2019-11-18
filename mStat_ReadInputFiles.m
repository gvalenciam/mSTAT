function [ReadVar]=mStat_ReadInputFiles(multisel,lastpath, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%MStaT
%This function incorporate the initial data the Centerline in diferent
%formats
%by Dominguez Ruben, UNL, Argentina
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%Start code
if lastpath == 0
[ReadVar.File,ReadVar.Path] = uigetfile({'*.shp;*.kml;*.txt;*.xls;*.xlsx',...
    'MStaT Files (*.shp,*.kml,*.txt,*.xls,*.xlsx)';'*.*',  'All Files (*.*)'},'Select Input File','MultiSelect',multisel);
else %remember the lastpath
    [ReadVar.File,ReadVar.Path] = uigetfile({'*.shp;*.kml;*.txt;*.xls;*.xlsx',...
    'MStaT Files (*.shp,*.kml,*.txt,*.xls,*.xlsx)';'*.*',  'All Files (*.*)'},'Select Input File','MultiSelect',multisel,lastpath);
end

assignin('base','file',ReadVar.File);
assignin('base','path',ReadVar.Path);

if isempty(ReadVar.File)
    %empty 
% if(ReadVar.File == 0)
    %No action
else
    
    if iscell(ReadVar.File)%determinate the number of secondary channels
        ReadVar.numfile=size(ReadVar.File,2);
    
    for i=1:ReadVar.numfile
        
        %ReadVar.comp{i}=mat2str(ReadVar.File{i}(end));
        ReadVar.comp{i} = strsplit(ReadVar.File{i}, '.');
        
        if (strcmp(ReadVar.comp{i}{2}, 'shp') == 1) %Read shp
            
            S = shaperead(strcat(ReadVar.Path,ReadVar.File{2}));
            sizeS = size(S);
            assignin('base','S',S);
            disp(S);

            %Polyline Shapefile

            S.X = S.X(~isnan(S.X))';
            S.Y = S.Y(~isnan(S.Y))';
            
%             [xCoordsUTM, yCoordsUTM,UTMZone] = deg2utm(Lat,Lon);
%             ReadVar.xCoord{i} = xCoordsUTM;
%             ReadVar.yCoord{i} = yCoordsUTM;
%             ReadVar.utmzone{i} = UTMZone;
            
            ReadVar.xCoord{i} = S.X;
            ReadVar.yCoord{i} = S.Y;
            ReadVar.utmzone{i}=[];
            
            if(strcmp(handles.flagAverageWidth, "auto") == 1)
                ReadVar.width{i} = S.width;   %Get the width value from the shp file 
            end
            assignin('base','x',S.X);
            assignin('base','y',S.Y);

            %Point Shapefile

%               xCoords = [];
%               yCoords = [];
% 
%               for i = 1:sizeS(1)
%                   temp = S(i);
%                   temp.X = temp.X(~isnan(temp.X))';
%                   temp.Y = temp.Y(~isnan(temp.Y))';
%                   xCoords = [xCoords; temp.X*10^4];
%                   yCoords = [yCoords; temp.Y*10^5];
%               end
%                  
%               assignin('base','x',xCoords);
%               assignin('base','y',yCoords);
%               ReadVar.xCoord{1} = xCoords;
%               ReadVar.yCoord{1} = yCoords;
%               ReadVar.utmzone{1}=[];
            
        elseif (strcmp(ReadVar.comp{i}{2}, 'kml') == 1) %Read kml

            kmlFile=fullfile(ReadVar.Path,ReadVar.File{i});

            ReadVar.kmlFile{i}=kmlFile;

            kmlStruct = kml2struct(kmlFile);

            %project kml in utm system
            [ReadVar.xCoord{i}, ReadVar.yCoord{i},ReadVar.utmzone{i}] = deg2utm(kmlStruct.Lat,kmlStruct.Lon);

            clear kmlFile kmlStruct

        elseif  (strcmp(ReadVar.comp{i}{2}, 'txt') == 1) %Read ASCII File

            %read ascii
            ReadVar.xyCl=importdata(fullfile(ReadVar.Path,ReadVar.File{i}));
            if(strcmp(handles.flagAverageWidth, "auto") == 1)
                ReadVar.xCoord{i} = ReadVar.xyCl(2:end,1);  %First column = latitude values (from second row to end)
                ReadVar.yCoord{i} = ReadVar.xyCl(2:end,2);  %Second column = longitude values (from second row to end)
                ReadVar.width{i} = ReadVar.xyCl(1,1);          %First row first column = river avg width 
            else
                ReadVar.xCoord{i} = ReadVar.xyCl(:,1);  
                ReadVar.yCoord{i} = ReadVar.xyCl(:,2);  
            end
            
            ReadVar.utmzone{i}=[];%without data


        elseif  ReadVar.comp(2)=='s'%read office 2007 File
                %read xlsx
                xlsxFile=fullfile(ReadVar.Path,ReadVar.File);
                ReadVar.utmzone{1}=[];%without data
                Ex=xlsread(xlsxFile);

                ReadVar.xCoord{1} = Ex(:,1);
                ReadVar.yCoord{1} = Ex(:,2);

            if isnumeric(ReadVar.xCoord{1}(1,1)) | isnumeric(ReadVar.yCoord{1}(1,1))
            else
                ReadVar.xCoord{1}(1,1) =[];
                ReadVar.yCoord{1}(1,1) =[]; 
            end          
        elseif  ReadVar.comp(2)=='x'%read office 2013 File
                %read xlsx
                xlsxFile=fullfile(ReadVar.Path,ReadVar.File);
                ReadVar.utmzone{1}=[];%without data
                Ex=xlsread(xlsxFile);

                ReadVar.xCoord{1} = Ex(:,1);
                ReadVar.yCoord{1} = Ex(:,2);

            if isnumeric(ReadVar.xCoord{1}(1,1)) | isnumeric(ReadVar.yCoord{1}(1,1))
            else
                ReadVar.xCoord{1}(1,1) =[];
                ReadVar.yCoord{1}(1,1) =[]; 
            end 

        end
    end
    
    else% one file
        ReadVar.numfile=1;
    
            for i=1:ReadVar.numfile
%               ReadVar.comp=mat2str(ReadVar.File(end));
                ReadVar.comp = strsplit(ReadVar.File, '.');
            if (strcmp(ReadVar.comp{2}, 'kml') == 1) %Read kml

                kmlFile=fullfile(ReadVar.Path,ReadVar.File);

                ReadVar.kmlFile=kmlFile;

                kmlStruct = kml2struct(kmlFile);

                %project kml in utm system
                [ReadVar.xCoord{1}, ReadVar.yCoord{1},ReadVar.utmzone{1}] = deg2utm(kmlStruct.Lat,kmlStruct.Lon);

                clear kmlFile kmlStruct

            elseif (strcmp(ReadVar.comp{2}, 'shp') == 1)
                
                S = shaperead(strcat(ReadVar.Path,ReadVar.File));
                sizeS = size(S);
                assignin('base','S',S);
               
                %Polyline Shapefile
                
                S.X = S.X(~isnan(S.X))';
                S.Y = S.Y(~isnan(S.Y))';
                
%                 [xCoordsUTM, yCoordsUTM,UTMZone] = deg2utm(S.Y,S.X);
%                 
%                 ReadVar.xCoord{i} = xCoordsUTM;
%                 ReadVar.yCoord{i} = yCoordsUTM;
%                 ReadVar.utmzone{i} = UTMZone;
            
                ReadVar.xCoord{1} = S.X;
                ReadVar.yCoord{1} = S.Y;
                
                assignin('base','Xcoords',S.X);
                assignin('base','Ycoords',S.Y);
                
                ReadVar.utmzone{1}=[];
                if(strcmp(handles.flagAverageWidth, "auto") == 1)
                    ReadVar.width = S.width;   %Get the width value from the shp file 
                end
                assignin('base','x',S.X);
                assignin('base','y',S.Y);
                
                %Point Shapefile
                
%               xCoords = [];
%               yCoords = [];
% 
%               for i = 1:sizeS(1)
%                   temp = S(i);
%                   temp.X = temp.X(~isnan(temp.X))';
%                   temp.Y = temp.Y(~isnan(temp.Y))';
%                   xCoords = [xCoords; temp.X*10^4];
%                   yCoords = [yCoords; temp.Y*10^5];
%               end
%                  
%               assignin('base','x',xCoords);
%               assignin('base','y',yCoords);
%               ReadVar.xCoord{1} = xCoords;
%               ReadVar.yCoord{1} = yCoords;
%               ReadVar.utmzone{1}=[];
                
            elseif (strcmp(ReadVar.comp{2}, 'txt') == 1)%Read ASCII File
                
                %read ascii
                ReadVar.xyCl=importdata(fullfile(ReadVar.Path,ReadVar.File));
                if(strcmp(handles.flagAverageWidth, "auto") == 1)
                    ReadVar.xCoord{1} = ReadVar.xyCl(2:end,1);  %First column = latitude values (from second row to end)
                    ReadVar.yCoord{1} = ReadVar.xyCl(2:end,2);  %Second column = longitude values (from second row to end)
                    ReadVar.width = ReadVar.xyCl(1,1);          %First row first column = river avg width 
                else
                    ReadVar.xCoord{1} = ReadVar.xyCl(:,1);  
                    ReadVar.yCoord{1} = ReadVar.xyCl(:,2);  
                end
                
                ReadVar.utmzone{1}=[];%without data

%                  if isnumeric(ReadVar.xCoord{1}(1,1)) | isnumeric(ReadVar.yCoord{1}(1,1))%Quit the first row
%                  else
%                     ReadVar.xCoord{1}(1,1) =[];
%                     ReadVar.yCoord{1}(1,1) =[]; 
%                  end

               

            elseif  ReadVar.comp(2)=='s'%read office 2007 File
                    %read xlsx
                    xlsxFile=fullfile(ReadVar.Path,ReadVar.File);
                    ReadVar.utmzone{1}=[];%without data
                    Ex=xlsread(xlsxFile);

                    ReadVar.xCoord{1} = Ex(:,1);
                    ReadVar.yCoord{1} = Ex(:,2);

                if isnumeric(ReadVar.xCoord{1}(1,1)) || isnumeric(ReadVar.yCoord{1}(1,1))
                else
                    ReadVar.xCoord{1}(1,1) =[];
                    ReadVar.yCoord{1}(1,1) =[]; 
                end          
            elseif  ReadVar.comp(2)=='x'%read office 2013 File
                    %read xlsx
                    xlsxFile=fullfile(ReadVar.Path,ReadVar.File);
                    ReadVar.utmzone{1}=[];%without data
                    Ex=xlsread(xlsxFile);

                    ReadVar.xCoord{1} = Ex(:,1);
                    ReadVar.yCoord{1} = Ex(:,2);

                if isnumeric(ReadVar.xCoord{1}(1,1)) || isnumeric(ReadVar.yCoord{1}(1,1))
                else
                    ReadVar.xCoord{1}(1,1) =[];
                    ReadVar.yCoord{1}(1,1) =[]; 
                end 

            end
            end
    end
    
end


function rememberUigetfile
persistent lastPath pathName
% If this is the first time running the function this session,
% Initialize lastPath to 0
if isempty(lastPath) 
    lastPath = 0;
end
% First time calling 'uigetfile', use the pwd
if lastPath == 0
    [fileName, pathName] = uigetfile;
    
% All subsequent calls, use the path to the last selected file
else
    [fileName, pathName] = uigetfile(lastPath);
end
% Use the path to the last selected file
% If 'uigetfile' is called, but no item is selected, 'lastPath' is not overwritten with 0
if pathName ~= 0
    lastPath = pathName;
end