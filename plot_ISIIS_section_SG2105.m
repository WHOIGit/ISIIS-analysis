
p = 'C:\Users\ISIIS WHOI\gss_logs\';
%cstr = 'NESLTER_EN657';
%%load([p cstr '_sled_table_20201013_14_fixedGPS']); sled_table = sled_table_20201013_14_fixedGPS; clear sled_table_20201013_14_fixedGPS
%load([p cstr '_sled_data_fixedGPS'])
cstr = 'OTZ_SG2105';
load([p cstr '_sled_data'])
sled_table_all = sled_table;

%%
%towstr = 'Tow 2'; flag = 'lat';
%xlim = [48.4 48.9]; sled_table = sled_table_all; sled_table((sled_table_all.matdate < datenum('5-6-2021') | sled_table_all.matdate > datenum('5-6-2021 12:00')),:) = [];
%zmax = 250; Trange = [11 13]; Srange = [35.2 35.7]; Drange = [27 29];
%Chlrange = [0 5]; bbrange = [.0007 .0012]; O2satrange = [85 100]; tx = 48.41;
%towstr = 'Tow 3'; flag = 'lon';
%xlim = [-14.94 -14.76]; sled_table = sled_table_all; sled_table((sled_table_all.matdate < datenum('5-6-2021 14:00') | sled_table_all.matdate > datenum('5-7-2021')),:) = [];
%zmax = 1000; Trange = [9 13]; Srange = [35.4 35.7]; Drange = [27 34]; Chlrange = [0 5]; bbrange = [.0007 .0012]; O2satrange = [85 100]; tx = -14.93;
towstr = 'Tow 4'; flag = 'lon';
xlim = [-14.94 -14.76]; sled_table = sled_table_all; sled_table((sled_table_all.matdate < datenum('5-7-2021') | sled_table_all.matdate > datenum('5-8-2021')),:) = [];
zmax = 1000; Trange = [9 13]; Srange = [35.4 35.7]; Drange = [27 34]; Chlrange = [0 5]; bbrange = [.0007 .0012]; O2satrange = [85 100]; tx = -14.93;

cstr2= cstr;
cstr2(strfind(cstr, '_')) = ' ';
titlestr = [cstr2 ' ' datestr(min(sled_table.matdate)) '-' datestr(max(sled_table.matdate))];
%%
if isequal(flag, 'lat')
    x = sled_table.TS_LATITUDE_DEG;
else
   x = sled_table.TS_LONGITUDE_DEG;
end

figure('color','w','position',[127 101 725 782])
colormap jet
subplot(3,1,1)
scatter(x,sled_table.DEPTH_M,20, sled_table.CTD_TEMPERATURE_DEG_C), colorbar
set(gca, 'ydir', 'rev'), axis([xlim 0 zmax])
caxis(Trange), colorbar
text(tx, zmax*.8, 'Temperature (\circC)')
titleHandle = title(titlestr);

subplot(3,1,2)
scatter(x, sled_table.DEPTH_M,20, sled_table.CTD_SALINITY)
set(gca, 'ydir', 'rev'), axis([xlim 0 zmax])
caxis(Srange), colorbar; text(tx, zmax*.8, 'Salinity')

subplot(3,1,3)
rho = density(sled_table.CTD_SALINITY, sled_table.CTD_TEMPERATURE_DEG_C, sled_table.CTD_PRESSURE/10);
scatter(x,sled_table.DEPTH_M, 20, rho-1000) 
set(gca, 'ydir', 'rev'), axis([xlim 0 zmax])
caxis(Drange), colorbar; text(tx, zmax*.8,'Density (kg m^{-3})')

print(['C:\work\Stingray_summary\OTZ_SG2105\Stingray_TSD_' towstr], '-dpng')

%%
figure('color','w','position',[127 101 725 782])
colormap jet

subplot(3,1,1)
scatter(x, sled_table.DEPTH_M, 20, .0073*(sled_table.FLUOROMETER_CHLOROPHYLL_RAW-48))
set(gca, 'ydir', 'rev'), axis([xlim 0 zmax])
caxis(Chlrange), colorbar
text(tx, zmax*.8, 'Chl from fluor (mg m^{-3})')
titleHandle = title(titlestr);

subplot(3,1,2)
scatter(x, sled_table.DEPTH_M,20, 1.684e-6*(sled_table.FLUOROMETER_BACKSCATTER_RAW-48)), 
set(gca, 'ydir', 'rev'), axis([xlim 0 zmax])
caxis(bbrange), colorbar; text(tx, zmax*.8, 'Backscattering (m^{-1} sr^{-1})')

subplot(3,1,3)
%scatter(sled_table.TS_LATITUDE_DEG, sled_table.DEPTH_M,20, sled_table.AANDERAA_O2_UM), colorbar, set(gca, 'xdir', 'rev')
scatter(x, sled_table.DEPTH_M,20, sled_table.AANDERAA_AIR_SATURATION), colorbar
set(gca, 'ydir', 'rev'), axis([xlim 0 zmax])
caxis(O2satrange), colorbar; text(tx, zmax*.8, 'Oxygen saturation (%)')

print(['C:\work\Stingray_summary\OTZ_SG2105\Stingray_FBO_' towstr], '-dpng')
