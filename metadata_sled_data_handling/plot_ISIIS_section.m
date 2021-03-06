
p = 'C:\Users\ISIIS WHOI\gss_logs\';
cstr = 'OTZ_AR43';
load([p cstr '_sled_data'])

figure
plot(sled_table.matdate, sled_table.DEPTH_M)
set(gca, 'ydir', 'rev')
title([cstr ' Stingray / ISIIS tows'])
ylabel('Depth (m)')
datetick('x', 'mm/dd/yy')
set(gca, 'fontsize', 12)
set(gcf, 'position', [200 700 1000 250])

figure
scatter(sled_table.matdate, sled_table.DEPTH_M, 10, sled_table.CTD_TEMPERATURE_DEG_C)
set(gca, 'ydir', 'rev')
title([cstr 'Stingray / ISIIS tows: Temperature (\circC)'])
ylabel('Depth (m)')
datetick('x', 'mm/dd/yy')
set(gca, 'fontsize', 12)
set(gcf, 'position', [200 700 1000 250])
colorbar, caxis([ 5 15])

figure
scatter(sled_table.matdate, sled_table.DEPTH_M, 10, sled_table.CTD_SALINITY)
set(gca, 'ydir', 'rev')
title([cstr ' Stingray / ISIIS tows: Salinity'])
ylabel('Depth (m)')
datetick('x', 'mm/dd/yy')
set(gca, 'fontsize', 12)
set(gcf, 'position', [200 700 1000 250])
colorbar, caxis([35 36])

figure
rho = density(sled_table.CTD_SALINITY, sled_table.CTD_TEMPERATURE_DEG_C, sled_table.CTD_PRESSURE/10);
scatter(sled_table.matdate, sled_table.DEPTH_M, 10, rho-1000)
set(gca, 'ydir', 'rev')
title([cstr ' Stingray / ISIIS tows: Density (kg m^{-3})'])
ylabel('Depth (m)')
datetick('x', 'mm/dd/yy')
set(gca, 'fontsize', 12)
set(gcf, 'position', [200 700 1000 250])
colorbar, caxis([26 32])

figure
scatter(sled_table.matdate, sled_table.DEPTH_M, 10, sled_table.FLUOROMETER_CHLOROPHYLL_RAW)
set(gca, 'ydir', 'rev')
title([cstr ' Stingray / ISIIS tows: Chl fluorescence (raw)'])
ylabel('Depth (m)')
datetick('x', 'mm/dd/yy')
set(gca, 'fontsize', 12)
set(gcf, 'position', [200 700 1000 250])
colorbar, caxis([0 200])

figure
scatter(sled_table.matdate, sled_table.DEPTH_M, 10, sled_table.FLUOROMETER_BACKSCATTER_RAW)
set(gca, 'ydir', 'rev')
title([cstr ' Stingray / ISIIS tows: Optical backscattering (raw)'])
ylabel('Depth (m)')
datetick('x', 'mm/dd/yy')
set(gca, 'fontsize', 12)
set(gcf, 'position', [200 700 1000 250])
colorbar, caxis([0 200])

figure
z = sled_table.AANDERAA_O2_UM; z(z<.1) = NaN;
scatter(sled_table.matdate, sled_table.DEPTH_M, 10, z)
set(gca, 'ydir', 'rev')
title([cstr ' Stingray / ISIIS tows: Oxygen (\muM)'])
ylabel('Depth (m)')
datetick('x', 'mm/dd/yy')
set(gca, 'fontsize', 12)
set(gcf, 'position', [200 700 1000 250])
colorbar, caxis([150 320])

figure
scatter(sled_table.TS_LATITUDE_DEG, sled_table.TS_LONGITUDE_DEG, 10, sled_table.matdate-datenum('3-1-2020'))
axis([39.5 39.85 -71.1 -70.7])
cb = colorbar;
xlabel(cb, 'Day in March 2020')


figure('color','w','position',[127 101 725 782])
colormap jet
subplot(3,1,1)
scatter3(sled_table.TS_LATITUDE_DEG,sled_table.TS_LONGITUDE_DEG, sled_table.DEPTH_M,20, sled_table.CTD_TEMPERATURE_DEG_C), colorbar, set(gca, 'xdir', 'rev')
set(gca, 'zdir', 'rev', 'xdir', 'rev'), axis([39.5 39.7 -71 -70.8 0 1000])
caxis([5 15]), colorbar
text(39.5, -70.9, -100, 'Temperature (\circC)')
titleHandle = title([cstr ' Stingray Tow 2 ']);

subplot(3,1,2)
scatter3(sled_table.TS_LATITUDE_DEG,sled_table.TS_LONGITUDE_DEG,sled_table.DEPTH_M,20, sled_table.CTD_SALINITY)
set(gca, 'zdir', 'rev', 'xdir', 'rev'), axis([39.5 39.7 -71 -70.8 0 1000])
caxis([34.5 36]), colorbar; text(39.5, -70.9, -100, 'Salinity')

subplot(3,1,3)
rho = density(sled_table.CTD_SALINITY, sled_table.CTD_TEMPERATURE_DEG_C, sled_table.CTD_PRESSURE/10);
scatter3(sled_table.TS_LATITUDE_DEG,sled_table.TS_LONGITUDE_DEG,sled_table.DEPTH_M, 20, rho-1000) 
set(gca, 'zdir', 'rev', 'xdir', 'rev'), axis([39.5 39.7 -71 -70.8 0 1000])
caxis([27 30]), colorbar; text(39.5, -70.9, -100,'Density (kg m^{-3})')

figure('color','w','position',[127 101 725 782])
colormap jet

subplot(3,1,1)
%scatter(sled_table.TS_LATITUDE_DEG, sled_table.DEPTH_M, 20, .0073*(sled_table.FLUOROMETER_CHLOROPHYLL_RAW-48))
scatter3(sled_table.TS_LATITUDE_DEG,sled_table.TS_LONGITUDE_DEG,sled_table.DEPTH_M, 20,  .0073*(sled_table.FLUOROMETER_CHLOROPHYLL_RAW-48)) 
set(gca, 'zdir', 'rev', 'xdir', 'rev'), axis([39.5 39.7 -71 -70.8 0 1000])
caxis([0 1.5]), colorbar; text(39.5, -70.9, -100,'Chl from fluor (mg m^{-3})')

subplot(3,1,2)
scatter3(sled_table.TS_LATITUDE_DEG,sled_table.TS_LONGITUDE_DEG,sled_table.DEPTH_M, 20, 1.684e-6*(sled_table.FLUOROMETER_BACKSCATTER_RAW-48)) 
set(gca, 'zdir', 'rev', 'xdir', 'rev'), axis([39.5 39.7 -71 -70.8 0 1000])
caxis([0.0025 .0045]), colorbar; text(39.5, -70.9, -100,'Backscattering (m^{-1} sr^{-1})')

subplot(3,1,3)
scatter3(sled_table.TS_LATITUDE_DEG,sled_table.TS_LONGITUDE_DEG,sled_table.DEPTH_M, 20,sled_table.AANDERAA_O2_UM) 
set(gca, 'zdir', 'rev', 'xdir', 'rev'), axis([39.5 39.7 -71 -70.8 0 1000])
caxis([175 375]), colorbar; text(39.5, -70.9, -100,'Oxygen (\muM)')
