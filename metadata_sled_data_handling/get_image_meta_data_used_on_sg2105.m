% Heidi M. Sosik, Woods Hole Oceanographic Institution, August 2020
% ISIIS-analysis code set (initial commite of earlier script)
% 

p = 'C:\Users\ISIIS WHOI\gss_logs\';
%load([p 'NESLTER_EN649_sled_data'])

cstr = 'OTZ_SG2105';
load([p cstr '_sled_data'])
indir = ['f:' filesep cstr filesep];
%pathlist = dir([indir 'NESLTER*']);
pathlist = dir([indir 'OTZ_SG2105_0*']);
pathlist = {pathlist.name}';
outdir = ['C:\work\Stingray_summary\' cstr filesep];

%hz = 13.6739; %image frame rate
hz = 14.999925; %image frame rate

%for count = 27:length(pathlist)
for count = 1:16%length(pathlist)
    disp(pathlist(count))
    clear metaTable
    metaTable = table;
    p = [indir pathlist{count} filesep];
    t = dir([p '*.tiff']);
    t = {t.name}';
    b = t{1}(1:50);
    imgnum = regexprep(regexprep(t,b,''),'.tiff', '');
    imgnum = str2num(char(imgnum));
    [~,s] = sort(imgnum, 'ascend');
    %pid = regexprep(cellstr(strcat(p, b, '_', num2str((1:cmax)'), '.tiff')), ' ', '');
    pid = strcat(p, t);
    metaTable.pid = pid(s);
    
   % tt = regexprep(pid, p, '');
  %  tt = strcat(p, {t.name});
   % [~,ia,ib] = intersect(pid,tt);
   % metaTable.pid = regexprep(pid, outdir, '');
   %metaTable.file_datestr(ia,1) = {t(ib).date};
   %metaTable.file_matdate(ia) = datenum(metaTable.file_datestr(ia), 'dd-mmm-yyyy HH:MM:SS');
    start_datetime = datenum(b(32:46), 'yyyymmdd_HHMMSS')+str2num(b(47:49))/1000/60/60/24;
    %deltime = 1/24:1/24:cmax/24;
    cmax = length(imgnum);
    deltime = (1/hz:1/hz:cmax/hz)';
    metaTable.frame_matdate = start_datetime+deltime/60/60/24;
    %x = start_datetime+deltime/60/60/24-metaTable.file_matdate';
    %plot(x, '.')
    %hold on, line(xlim, xlim, 'color', 'r')
    %datetick('x'), datetick('y')
    %pause
    iia = NaN(size(deltime));
    for count2 = 1:length(deltime)
        [~,iia(count2)] = min(abs(metaTable.frame_matdate(count2)-sled_table.matdate));
    end
    
    metaTable = [metaTable sled_table(iia,:)];
    outdirnow = [outdir pathlist{count} filesep];
    if ~exist(outdirnow, 'dir')
        mkdir(outdirnow)
    end
    save([outdirnow 'Image_metadata'], 'metaTable')
    writetable(metaTable, [outdirnow 'Image_metadata.csv']) 
end