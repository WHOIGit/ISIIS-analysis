p = 'C:\Users\ISIIS WHOI\gss_logs\';
%p = 'C:\Users\ISIIS WHOI\gss_logs\';
%cstr = 'NESLTER_EN657';
%%load([p cstr '_sled_table_20201013_14_fixedGPS']); sled_table = sled_table_20201013_14_fixedGPS; clear sled_table_20201013_14_fixedGPS
%load([p cstr '_sled_data_fixedGPS'])
cstr = 'NESLTER_EN687';
%cstr = 'NESLTER_AT46';
%load([p cstr '_sled_data_fixedGPS.mat'])
load([p cstr '_sled_data.mat'])
sled_table_all = sled_table;
%addStnLabels = @myaddStnLabels;
bath = readtable('NESLTER_transect_bathymetry.csv');

suna_path = '\\vdm\ParticipantData\EN687_Sosik_LTER\SUNA1903_StingRay\data\converted_raw_data\';
load([suna_path 'sunaTable'])
%% AT46
%towstr = 'Tow 1-3'; latlim = [39.75 41.2]; sled_table = sled_table_all; sled_table(sled_table_all.matdate < datenum('2-16-2022 01:00:00'),:) = []; sled_table(sled_table_all.matdate > datenum('2-19-2022 12:00:00'),:) = [];
%towstr = 'Tow 3-5'; latlim = [39.75 41.2]; sled_table = sled_table_all; sled_table(sled_table_all.matdate < datenum('2-17-2022 20:00:00'),:) = [];
%%zmax = 150; Trange = [10 24]; Srange = [32 36]; Drange = [22.5 27.5]; Chlrange = [0 5]; bbrange = [.0006 .0024]; O2satrange = [60 108];
%zmax = 210; Trange = [4 14];Srange = [32 36];Drange = [25 28]; Chlrange = [0 2]; bbrange = [.001 .003]; O2satrange = [85 100];

% EN668
%towstr = 'Tow 1-7'; latlim = [39.75 41.2]; sled_table = sled_table_all; sled_table(sled_table_all.matdate > datenum('7-19-2021 23:00:00'),:) = [];
%towstr = 'Tow 4-8'; latlim = [39.75 41.2]; sled_table = sled_table_all; sled_table(sled_table_all.matdate < datenum('7-19-2021 00:00:00'),:) = [];
%zmax = 150; Trange = [10 24]; Srange = [32 36]; Drange = [22.5 27.5]; Chlrange = [0 5]; bbrange = [.0006 .0024]; O2satrange = [60 108];

% %% EN661
% towstr = 'Tow 4'; latlim = [40.85 41.2]; sled_table = sled_table_all; sled_table(sled_table_all.matdate < datenum('2-6-2021'),:) = [];
% %towstr = 'Tow 1'; latlim = [40.85 41.2]; sled_table = sled_table_all; sled_table(sled_table_all.matdate > datenum('2-4-2021 12:00:00'),:) = [];
% %towstr = 'Tow 1-3'; latlim = [39.75 41.2]; sled_table = sled_table_all; sled_table(sled_table_all.matdate > datenum('2-6-2021 12:00:00'),:) = [];
% 
% zmax = 50; Trange = [4 5]; Srange = [32.3 32.5]; Drange = [25.75 26.25]; Chlrange = [0 2]; bbrange = [.002 .007]; O2satrange = [89 96];
% %zmax = 210; Trange = [4 14];Srange = [32 36];Drange = [25 28]; Chlrange = [0 2]; bbrange = [.002 .007]; O2satrange = [85 100];

% EN687
%towstr = 'Tow 1-3'; latlim = [39.7 41.2]; sled_table = sled_table_all; sled_table(sled_table_all.matdate > datenum('8-1-2022 00:00:00'),:) = [];
towstr = 'Tow 3-6'; latlim = [39.7 41.2]; sled_table = sled_table_all; sled_table(sled_table_all.matdate < datenum('7-31-2022 12:00:00'),:) = [];
zmax = 150; Trange = [10 24]; Srange = [32 36]; Drange = [22.5 27.5]; Chlrange = [0 5]; bbrange = [.0006 .0024]; O2satrange = [60 108];

%%

cstr2= cstr;
cstr2(strfind(cstr, '_')) = ' ';
titlestr = [cstr2 ' ' datestr(min(sled_table.matdate)) '-' datestr(max(sled_table.matdate))];

%
symbol_size = 10;
labelDepth = -10;
figure('color','w','position',[127 101 725 782])
colormap jet
subplot(3,1,1)
scatter(sled_table.TS_LATITUDE_DEG,sled_table.DEPTH_M,symbol_size, sled_table.CTD_TEMPERATURE_DEG_C), colorbar, set(gca, 'xdir', 'rev')
set(gca, 'ydir', 'rev', 'xdir', 'rev'), axis([latlim 0 zmax])
caxis(Trange), colorbar
text(41.15, zmax*.8, 'Temperature (\circC)')
titleHandle = title(titlestr);
addStnLabels(labelDepth)
hold on
plot(bath.latitude, bath.bottom_depth_meters, 'linewidth', 2, 'color', [.5 .5 .5])

subplot(3,1,2)
scatter(sled_table.TS_LATITUDE_DEG,sled_table.DEPTH_M,symbol_size, sled_table.CTD_SALINITY)
set(gca, 'ydir', 'rev', 'xdir', 'rev'), axis([latlim 0 zmax])
caxis(Srange), colorbar; text(41.15, zmax*.8, 'Salinity')
addStnLabels(labelDepth)
hold on
plot(bath.latitude, bath.bottom_depth_meters, 'linewidth', 2, 'color', [.5 .5 .5])

subplot(3,1,3)
rho = density(sled_table.CTD_SALINITY, sled_table.CTD_TEMPERATURE_DEG_C, sled_table.CTD_PRESSURE/10);
scatter(sled_table.TS_LATITUDE_DEG,sled_table.DEPTH_M,symbol_size, rho-1000) 
set(gca, 'ydir', 'rev', 'xdir', 'rev'), axis([latlim 0 zmax])
caxis(Drange), colorbar; text(41.15, zmax*.8,'Density (kg m^{-3})')
addStnLabels(labelDepth)
hold on
plot(bath.latitude, bath.bottom_depth_meters, 'linewidth', 2, 'color', [.5 .5 .5])

%print('C:\work\Stingray_summary\NESLTER_EN661\Stingray_TSD', '-dpng')
print(['C:\work\Stingray_summary\' cstr '\Stingray_TSD_' towstr], '-dpng')

%%
figure('color','w','position',[127 101 725 782])
colormap jet

subplot(3,1,1)
%new 2021 cal for AT46
scatter(sled_table.TS_LATITUDE_DEG, sled_table.DEPTH_M, symbol_size, .0073*(sled_table.FLUOROMETER_CHLOROPHYLL_RAW-51))
set(gca, 'ydir', 'rev', 'xdir', 'rev'), axis([latlim 0 zmax])
caxis(Chlrange), colorbar
text(41.15, zmax*.8, 'Chl from fluor (mg m^{-3})')
titleHandle = title(titlestr);
addStnLabels(labelDepth)
hold on
plot(bath.latitude, bath.bottom_depth_meters, 'linewidth', 2, 'color', [.5 .5 .5])

subplot(3,1,2)
%new 2021 cal for AT46
scatter(sled_table.TS_LATITUDE_DEG, sled_table.DEPTH_M,symbol_size, 1.861e-6*(sled_table.FLUOROMETER_BACKSCATTER_RAW-46)), 
set(gca, 'ydir', 'rev', 'xdir', 'rev'), axis([latlim 0 zmax])
caxis(bbrange), colorbar; text(41.15, zmax*.8, 'Backscattering (m^{-1} sr^{-1})')
addStnLabels(labelDepth)
hold on
plot(bath.latitude, bath.bottom_depth_meters, 'linewidth', 2, 'color', [.5 .5 .5])

subplot(3,1,3)
%scatter(sled_table.TS_LATITUDE_DEG, sled_table.DEPTH_M,20, sled_table.AANDERAA_O2_UM), colorbar, set(gca, 'xdir', 'rev')
scatter(sled_table.TS_LATITUDE_DEG, sled_table.DEPTH_M,symbol_size, sled_table.AANDERAA_AIR_SATURATION), colorbar, set(gca, 'xdir', 'rev')
set(gca, 'ydir', 'rev', 'xdir', 'rev'), axis([latlim 0 zmax])
%caxis([160 280]), colorbar; text(41.15, zmax*.8, 'Oxygen (\muM)')
%caxis([190 390]), colorbar; text(41.15, zmax*.8, 'Oxygen (\muM)')
caxis(O2satrange), colorbar; text(41.15, zmax*.8, 'Oxygen saturation (%)')
addStnLabels(labelDepth)
hold on 
plot(bath.latitude, bath.bottom_depth_meters, 'linewidth', 2, 'color', [.5 .5 .5])
print(['C:\work\Stingray_summary\' cstr '\Stingray_FBO_' towstr], '-dpng')

figure('color','w','position',[127 101 725 782])
colormap jet
subplot(3,1,1)
scatter(suna.Lat,suna.Depth_m,symbol_size, suna.NITRATE_UM), colorbar, set(gca, 'xdir', 'rev')
set(gca, 'ydir', 'rev', 'xdir', 'rev'), axis([latlim 0 zmax])
caxis([-1 30]), colorbar
text(41.15, zmax*.8, 'Nitrate (\muM)')
titleHandle = title(titlestr);
addStnLabels(labelDepth)
hold on
plot(bath.latitude, bath.bottom_depth_meters, 'linewidth', 2, 'color', [.5 .5 .5])

return
%% use this to plot vs time
figure
plot(sled_table.matdate, sled_table.DEPTH_M)
set(gca, 'ydir', 'rev')
title('EN661 Stingray / ISIIS tows')
ylabel('Depth (m)')
datetick('x', 'mm/dd/yy')
set(gca, 'fontsize', 12)
set(gcf, 'position', [200 700 1000 250])

figure(2), clf
scatter(sled_table.matdate, sled_table.DEPTH_M, 10, sled_table.CTD_TEMPERATURE_DEG_C)
set(gca, 'ydir', 'rev')
title('EN661 Stingray / ISIIS tows: Temperature (\circC)')
ylabel('Depth (m)')
datetick('x', 'mm/dd/yy')
set(gca, 'fontsize', 12)
set(gcf, 'position', [200 700 1000 250])
colorbar, caxis([4 14]) %caxis([12 22])

figure(3), clf
scatter(sled_table.matdate, sled_table.DEPTH_M, 10, sled_table.CTD_SALINITY)
set(gca, 'ydir', 'rev')
title('EN661 Stingray / ISIIS tows: Salinity')
ylabel('Depth (m)')
datetick('x', 'mm/dd/yy')
set(gca, 'fontsize', 12)
set(gcf, 'position', [200 700 1000 250])
colorbar, caxis([32 36])

figure(4), clf
rho = density(sled_table.CTD_SALINITY, sled_table.CTD_TEMPERATURE_DEG_C, sled_table.CTD_PRESSURE/10);
scatter(sled_table.matdate, sled_table.DEPTH_M, 10, rho-1000)
set(gca, 'ydir', 'rev')
title('EN661 Stingray / ISIIS tows: Density (kg m^{-3})')
ylabel('Depth (m)')
datetick('x', 'mm/dd/yy')
set(gca, 'fontsize', 12)
set(gcf, 'position', [200 700 1000 250])
colorbar, caxis([24 28])

figure(5), clf
scatter(sled_table.matdate, sled_table.DEPTH_M, 10, sled_table.FLUOROMETER_CHLOROPHYLL_RAW)
set(gca, 'ydir', 'rev')
title('EN661 Stingray / ISIIS tows: Chl fluorescence (raw)')
ylabel('Depth (m)')
datetick('x', 'mm/dd/yy')
set(gca, 'fontsize', 12)
set(gcf, 'position', [200 700 1000 250])
colorbar, caxis([0 300])

figure(6), clf
scatter(sled_table.matdate, sled_table.DEPTH_M, 10, sled_table.FLUOROMETER_BACKSCATTER_RAW)
set(gca, 'ydir', 'rev')
title('EN661 Stingray / ISIIS tows: Optical backscattering (raw)')
ylabel('Depth (m)')
datetick('x', 'mm/dd/yy')
set(gca, 'fontsize', 12)
set(gcf, 'position', [200 700 1000 250])
colorbar, caxis([1500 3000])

figure(7), clf
z = sled_table.AANDERAA_O2_UM; z(z<.1) = NaN;
scatter(sled_table.matdate, sled_table.DEPTH_M, 10, z)
set(gca, 'ydir', 'rev')
title('EN661 Stingray / ISIIS tows: Oxygen (\muM)')
ylabel('Depth (m)')
datetick('x', 'mm/dd/yy')
set(gca, 'fontsize', 12)
set(gcf, 'position', [200 700 1000 250])
colorbar, caxis([150 300])

figure(8)
scatter(sled_table.TS_LONGITUDE_DEG, sled_table.TS_LATITUDE_DEG, 10, sled_table.matdate-datenum('10-1-2020'))
axis([-70.95 -70.8 40.5 41.5])
cb = colorbar;
xlabel(cb, 'Day in October 2020')

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
