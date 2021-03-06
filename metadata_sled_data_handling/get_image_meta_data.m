% Heidi M. Sosik, Woods Hole Oceanographic Institution, August 2020
% ISIIS-analysis code set (initial commite of earlier script)
% 

p = 'C:\Users\ISIIS WHOI\gss_logs\';
%load([p 'NESLTER_EN649_sled_data'])

cstr = 'NESLTER_EN661';
load([p cstr '_sled_data'])
indir = ['f:' filesep cstr filesep];
%pathlist = dir([indir 'NESLTER*']);
pathlist = dir([indir 'EN661*']);
pathlist = {pathlist.name}';
outdir = ['C:\work\Stingray_summary\' cstr filesep];

hz = 13.6739; %image frame rate

for count = 1:17%18:length(pathlist)
    disp(pathlist(count))
    clear metaTable
    metaTable = table;
    p = [indir pathlist{count} filesep];
    t = dir([p '*.tiff']);
    cmax = numel(t);
    b = t(1).name;
    b = b(1:49);
    pid = regexprep(cellstr(strcat(p, b, '_', num2str((1:cmax)'), '.tiff')), ' ', '');
    tt = regexprep(pid, p, '');
    tt = strcat(p, {t.name});
    [~,ia,ib] = intersect(pid,tt);
    metaTable.pid = regexprep(pid, outdir, '');
    metaTable.file_datestr(ia,1) = {t(ib).date};
    metaTable.file_matdate(ia) = datenum(metaTable.file_datestr(ia), 'dd-mmm-yyyy HH:MM:SS');
    start_datetime = datenum(b(32:end), 'yyyymmdd_HHMMSS')+str2num(b(end-2:end))/1000/60/60/24;
    %deltime = 1/24:1/24:cmax/24;
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