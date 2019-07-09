function mStat_savexlsx(geovar)

%This function save all the data in excel file to posprocessing

hwait = waitbar(0,'Exporting Excel File...');
    [file,path] = uiputfile('*.xlsx','Save *.xlsx file');
    outfile = fullfile(path,file);  


[m,n]=size(geovar.equallySpacedX);

D='DS';
U='US';
C='C';

D=sum(strcmp(D,geovar.condition));
U=sum(strcmp(U,geovar.condition));
C=sum(strcmp(C,geovar.condition));

   sout = {...
            'MStaT: Summary of Data Analysis' '' '' '' '' '';...
 %           'MSTaT ' geovar.mStat_version '' '' '' '';...
            'Date Processed: ' datestr(now) '' '' '' '';...
            'Path and File' '' '' '' '' outfile;
            '' '' '' '' '' '';...
            'Statistics points Analysis' '' '' '' '' '';...
            'Total Bends found:' '' '' '' '' geovar.nBends;...
            'Total Length [m]:' '' '' '' '' geovar.intS(end,1);...
            'Total points analyzed:' '' '' '' '' m;...
            '' '' '' '' '' '';...
            'Method' '' '' '' '' geovar.methodIntersection;
            'Numbers of Downstream Bends found' '' '' '' '' D;...
            'Numbers of Upstream Bends found' '' '' '' '' U;...
            'Numbers of C Bends found' '' '' '' '' C;...
            '' '' '' '' '' '';...
            '' '' '' '' 'Min' 'Max';...
            'Amplitude [m]' '' '' '' nanmin(geovar.amplitudeOfBends) nanmax(geovar.amplitudeOfBends);...
            'Sinuosity [m]' '' '' '' nanmin(geovar.sinuosityOfBends) nanmax(geovar.sinuosityOfBends);...
            'Wavelength [m]' '' '' '' nanmin(geovar.wavelengthOfBends) nanmax(geovar.wavelengthOfBends)};
        %xlswrite(outfile,sout,'MStaTSummary','A1');
        writematrix(sout, outfile);
waitbar(1/5,hwait)
        
s1=[num2cell([geovar.bendID1' geovar.sinuosityOfBends geovar.lengthCurved'...
    geovar.wavelengthOfBends geovar.amplitudeOfBends geovar.downstreamSlength' geovar.upstreamSlength'])];

    s1headers = {'BendID' 'Sinuosity_Of_Bends' 'Arc_Wavelength_[m]'...
        'Wavelength_[m]' 'Amplitude_Of_Bends_[m]' ...
        'Downstream_length_[m]' 'Upstream_length_[m]'};

pvout1 = vertcat(s1headers,s1);
xlswrite(outfile,pvout1, 'Planar Variables');
waitbar(2/5,hwait)
       
s2=[num2cell([geovar.equallySpacedX geovar.equallySpacedY...
    geovar.xValleyCenter geovar.yValleyCenter ...
    geovar.sResample geovar.cResample])];

        s2headers = {'Equally_SpacedX_[m]' 'Equally_SpacedY_[m]' 'xValley_Center_[m]'...
        'yValley_Center_[m]' 'S_Resample' 'C_Resample'};
            
    
pvout2 = vertcat(s2headers,s2);
xlswrite(outfile,pvout2, 'Geometry');
waitbar(3/5,hwait)

s3=[num2cell([geovar.newMaxCurvX geovar.newMaxCurvY...
    geovar.newMaxCurvS])];


      s3headers = {'NewMaxCurvX_[m]' 'NewMaxCurvY_[m]' 'NewMaxCurvS_[m]'};
    
pvout3 = vertcat(s3headers,s3);
xlswrite(outfile,pvout3, 'Data');

s4=[num2cell([geovar.inflectionX...
    geovar.inflectionY])];

      s4headers = {'Inflection_X' 'Inflection_Y'};

pvout4 = vertcat(s4headers,s4);
xlswrite(outfile,pvout4, 'Inflection_points');
waitbar(1,hwait)
delete(hwait)
