function mStat_saveBendsData(handles)

assignin('base','geovar',handles.geovar);

geovar = handles.geovar;
hwait = waitbar(0,'Exporting Excel File...');
defaultName = convertCharsToStrings(strcat(handles.formatfileread(1), '.txt'));
disp("DN");
disp(defaultName);
[file,path] = uiputfile('*.txt','Save *.txt file', defaultName);
outfile = fullfile(path,file); 

fid = fopen(outfile,'wt');

generalHeaders = ["Total bends", "Total length", "Date created"];
generalValues = [convertCharsToStrings(num2str(geovar.nBends)), convertCharsToStrings(num2str(geovar.intS(end,1))), convertCharsToStrings(datestr(now))];
    
for i = 1:length(generalHeaders)
    fprintf(fid,'%s',generalHeaders(1,i));
    fprintf(fid,'\t');
    fprintf(fid,'%s',generalValues(1,i));
    fprintf(fid,'\n');
end

fprintf(fid,'\n');

waitbar(1/3, hwait);

dataHeaders = ["Bend ID", "Sinuosity", "Arc Wavelength", "Wavelength", "Amplitude", "Downstream length", "Upstream length", "Condition"];

for i = 1:length(dataHeaders)
    fprintf(fid,'%s',dataHeaders(1,i));
    fprintf(fid,'\t\t');
end

fprintf(fid,'\n');

for i = 1:geovar.nBends
    fprintf(fid,'%s',convertCharsToStrings(num2str(geovar.bendID1(i))));
    fprintf(fid,'\t\t');
    fprintf(fid,'%s',convertCharsToStrings(num2str(geovar.sinuosityOfBends(i))));
    fprintf(fid,'\t\t\t');
    if (isnan(geovar.lengthCurved(i)) || geovar.lengthCurved(i) <= 0); fprintf(fid,'%s',"0000.0000"); else; fprintf(fid,'%s',convertCharsToStrings(num2str(geovar.lengthCurved(i)))); end
    fprintf(fid,'\t\t');
    if (isnan(geovar.wavelengthOfBends(i)) || geovar.wavelengthOfBends(i) <= 0); fprintf(fid,'%s',"0000.0000"); else; fprintf(fid,'%s',convertCharsToStrings(num2str(geovar.wavelengthOfBends(i)))); end
    fprintf(fid,'\t\t');
    if (isnan(geovar.amplitudeOfBends(i)) || geovar.amplitudeOfBends(i) <= 0); fprintf(fid,'%s',"0000.0000"); else; fprintf(fid,'%s',convertCharsToStrings(num2str(geovar.amplitudeOfBends(i)))); end
    fprintf(fid,'\t\t');
    if (isnan(geovar.downstreamSlength(i)) || geovar.downstreamSlength(i) <= 0); fprintf(fid,'%s',"0000.0000"); else; fprintf(fid,'%s',convertCharsToStrings(num2str(geovar.downstreamSlength(i)))); end
    fprintf(fid,'\t\t\t');
    if (isnan(geovar.upstreamSlength(i)) || geovar.upstreamSlength(i) <= 0); fprintf(fid,'%s',"0000.0000"); else; fprintf(fid,'%s',convertCharsToStrings(num2str(geovar.upstreamSlength(i)))); end
    fprintf(fid,'\t\t\t');
    fprintf(fid,'%s',geovar.condition{i});
    fprintf(fid,'\n');
end

fprintf(fid,'\n');
fprintf(fid,'%s',"Mean Values");
fprintf(fid,'\n\n');

waitbar(2/3, hwait);

meanDataHeaders = ["Sinuosity", "Arc_Wavelength", "Wavelength", "Amplitude", "Condition"];

for i = 1:length(meanDataHeaders)
    fprintf(fid,'%s',meanDataHeaders(1,i));
    fprintf(fid,'\t\t');
end

[s,~,j] = unique(geovar.condition);

fprintf(fid,'\n');

fprintf(fid,'%s',convertCharsToStrings(round(nanmean(geovar.sinuosityOfBends), 5)));
fprintf(fid,'\t\t');
fprintf(fid,'%s',convertCharsToStrings(round(nanmean(geovar.lengthCurved), 5)));
fprintf(fid,'\t\t');
fprintf(fid,'%s',convertCharsToStrings(round(nanmean(geovar.wavelengthOfBends), 5)));
fprintf(fid,'\t\t');
fprintf(fid,'%s',convertCharsToStrings(round(nanmean(geovar.amplitudeOfBends), 5)));
fprintf(fid,'\t\t');
fprintf(fid,'%s', s{mode(j)});
fprintf(fid,'\n');

waitbar(1, hwait);
delete(hwait)

fclose(fid);
