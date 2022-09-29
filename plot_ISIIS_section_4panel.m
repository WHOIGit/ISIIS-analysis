p = 'C:\Users\ISIIS WHOI\gss_logs\';
%p = 'C:\Users\ISIIS WHOI\gss_logs\';
%cstr = 'NESLTER_EN657';
%%load([p cstr '_sled_table_20201013_14_fixedGPS']); sled_table = sled_table_20201013_14_fixedGPS; clear sled_table_20201013_14_fixedGPS
%load([p cstr '_sled_data_fixedGPS'])
%cstr = 'NESLTER_EN661';
cstr = 'NESLTER_EN668';
load([p cstr '_sled_data.mat'])
sled_table_all = sled_table;
%addStnLabels = @myaddStnLabels;
bath = readtable('NESLTER_transect_bathymetry.csv');

%% EN668
towstr = 'Tow 1-7'; latlim = [39.75 41.2]; sled_table = sled_table_all; sled_table(sled_table_all.matdate > datenum('7-19-2021 23:00:00'),:) = [];
%towstr = 'Tow 4-8'; latlim = [39.75 41.2]; sled_table = sled_table_all; sled_table(sled_table_all.matdate < datenum('7-19-2021 00:00:00'),:) = [];
zmax = 150; Trange = [10 24]; Srange = [32 36]; Drange = [22.5 27.5]; Chlrange = [0 5]; bbrange = [.0006 .0024]; O2satrange = [60 108];

% %% EN661
% towstr = 'Tow 4'; latlim = [40.85 41.2]; sled_table = sled_table_all; sled_table(sled_table_all.matdate < datenum('2-6-2021'),:) = [];
% %towstr = 'Tow 1'; latlim = [40.85 41.2]; sled_table = sled_table_all; sled_table(sled_table_all.matdate > datenum('2-4-2021 12:00:00'),:) = [];
% %towstr = 'Tow 1-3'; latlim = [39.75 41.2]; sled_table = sled_table_all; sled_table(sled_table_all.matdate > datenum('2-6-2021 12:00:00'),:) = [];
% 
% zmax = 50; Trange = [4 5]; Srange = [32.3 32.5]; Drange = [25.75 26.25]; Chlrange = [0 2]; bbrange = [.002 .007]; O2satrange = [89 96];
% %zmax = 210; Trange = [4 14];Srange = [32 36];Drange = [25 28]; Chlrange = [0 2]; bbrange = [.002 .007]; O2satrange = [85 100];
%%

cstr2= cstr;
cstr2(strfind(cstr, '_')) = ' ';
%titlestr = [cstr2 ' ' datestr(min(sled_table.matdate)) '-' datestr(max(sled_table.matdate))];
titlestr = [cstr2 ' 16-19 Jul 2021'];
%
symbol_size = 10;
labelDepth = -10;
figure('color','w','position',[127 100 1350 550])
colormap jet
t = tiledlayout(2,2, 'tilespacing', 'compact');

nexttile
scatter(sled_table.TS_LATITUDE_DEG,sled_table.DEPTH_M,symbol_size, sled_table.CTD_TEMPERATURE_DEG_C), colorbar, set(gca, 'xdir', 'rev')
set(gca, 'ydir', 'rev', 'xdir', 'rev'), axis([latlim 0 zmax])
caxis(Trange), colorbar
text(41.15, zmax*.8, 'Temperature (\circC)')
addStnLabels(labelDepth)
hold on
plot(bath.latitude, bath.bottom_depth_meters, 'linewidth', 2, 'color', [.5 .5 .5])

nexttile
scatter(sled_table.TS_LATITUDE_DEG,sled_table.DEPTH_M,symbol_size, sled_table.CTD_SALINITY)
set(gca, 'ydir', 'rev', 'xdir', 'rev'), axis([latlim 0 zmax])
caxis(Srange), colorbar; text(41.15, zmax*.8, 'Salinity')
addStnLabels(labelDepth)
hold on
plot(bath.latitude, bath.bottom_depth_meters, 'linewidth', 2, 'color', [.5 .5 .5])

nexttile
scatter(sled_table.TS_LATITUDE_DEG, sled_table.DEPTH_M, symbol_size, .0073*(sled_table.FLUOROMETER_CHLOROPHYLL_RAW-48))
set(gca, 'ydir', 'rev', 'xdir', 'rev'), axis([latlim 0 zmax])
caxis(Chlrange), colorbar
text(41.15, zmax*.8, 'Chl from fluor (mg m^{-3})')
addStnLabels(labelDepth)
hold on
plot(bath.latitude, bath.bottom_depth_meters, 'linewidth', 2, 'color', [.5 .5 .5])

nexttile
%scatter(sled_table.TS_LATITUDE_DEG, sled_table.DEPTH_M,20, sled_table.AANDERAA_O2_UM), colorbar, set(gca, 'xdir', 'rev')
scatter(sled_table.TS_LATITUDE_DEG, sled_table.DEPTH_M,symbol_size, sled_table.AANDERAA_AIR_SATURATION), colorbar, set(gca, 'xdir', 'rev')
set(gca, 'ydir', 'rev', 'xdir', 'rev'), axis([latlim 0 zmax])
caxis(O2satrange), colorbar; text(41.15, zmax*.8, 'Oxygen saturation (%)')
addStnLabels(labelDepth)
hold on 
plot(bath.latitude, bath.bottom_depth_meters, 'linewidth', 2, 'color', [.5 .5 .5])

sgtitle(titlestr)

ylabel(t,'Depth (m)');
xlabel(t,'Latitide (\circN)');
%title(t,'yourTitle');

%print(['d:\work\Stingray_summary\' cstr '\Stingray_4panel_' towstr], '-dpng')


function [] = addStnLabels(labelDepth)
  %  LTER = [41 11.8 70 53; 41 1.8 70 53; 40 51.8 70 53; 40 41.8 70 53; 40 30.8 70 53; 40 21.8 70 53; 40 13.6 70 53; ...
  %      40 08.2 70 46.5; 40 5.9 70 53; 39 56.4 70 53; 39 46.4 70 53; 39 56.4 70 46.5; 40 21.9 70 46.5];
  %  LTER_labels = {'L1'; 'L2'; 'L3'; 'L4'; 'L5'; 'L6'; 'L7'; 'L8'; 'L9'; 'L10'; 'L11'; 'L12'; 'L13'};
    LTER = [41 11.8 70 53; 41 1.8 70 53; 40 51.8 70 53; 40 41.8 70 53; 40 30.8 70 53; 40 21.8 70 53; 40 13.6 70 53; ...
        40 08.2 70 46.5; 40 5.9 70 53; 39 56.4 70 53; 39 46.4 70 53];
    LTER_labels = {'L1'; 'L2'; 'L3'; 'L4'; 'L5'; 'L6'; 'L7'; 'L8'; 'L9'; 'L10'; 'L11'};
    lat = LTER(:,1)+LTER(:,2)/60;
    hold on
    %text(lat, repmat(labelDepth,length(lat),1),'v')
    text(lat, repmat(labelDepth,length(lat),1),LTER_labels, 'VerticalAlignment', 'top')
end