suna_path = '\\vdm\ParticipantData\EN687_Sosik_LTER\Sosik-provided_data\SUNA1903_StingRay\data\converted_raw_data\';
%suna_path = 'd:\converted_raw_data\';
f = dir([suna_path '*.csv']);
p = 'C:\Users\ISIIS WHOI\gss_logs\';
cstr = 'NESLTER_EN687'; % 'OTZ_EN688';
load([p cstr '_sled_data.mat'])
sled_table.datetime = datetime(sled_table.matdate, 'ConvertFrom', 'datenum');
sled_table_all = sled_table;
bath = readtable('NESLTER_transect_bathymetry.csv');

s = table;
for ii = 1:length(f)
    s = [s; readtable([suna_path f(ii).name])];
end
s.datetime = datetime(s.DATE_UTC_00_00_, 'InputFormat','dd MMM yyyy')+s.TIME_UTC_00_00_;
ii = find(s.NITRATE_UM); %omit the dark readings
suna = s(ii,:);
suna_meta = interp1(sled_table.datetime,[sled_table.DEPTH_M sled_table.TS_LATITUDE_DEG sled_table.TS_LATITUDE_DEG], suna.datetime);
suna_meta = array2table(suna_meta, 'VariableNames', {'Depth_m', 'Lat', 'Lon'});
suna = [suna suna_meta];

%save([suna_path 'sunaTable'], 'suna')
save(['D:\Stingray_summary\NESLTER_EN687' 'sunaTable'], 'suna')

suna_all = suna;
%%
%towstr = 'Tow 1-3'; latlim = [39.7 41.2]; sled_table = sled_table_all; sled_table(sled_table_all.matdate > datenum('7-19-2022 23:00:00'),:) = [];
zmax = 150; %Trange = [10 24]; Srange = [32 36]; Drange = [22.5 27.5]; Chlrange = [0 5]; bbrange = [.0006 .0024]; O2satrange = [60 108];
towstr = 'Tow 1-3'; latlim = [39.7 41.2]; suna = suna_all; suna(suna.datetime > datetime(2022,8,1,0,0,0),:) = [];
%towstr = 'Tow 3-6'; latlim = [39.7 41.2]; sled_table = sled_table_all; sled_table(sled_table_all.matdate < datenum('7-31-2022 12:00:00'),:) = [];

cstr2= cstr;
cstr2(strfind(cstr, '_')) = ' ';
titlestr = [cstr2 ' ' min(suna.datetime) '-' max(suna.datetime)];

%%
symbol_size = 10;
labelDepth = -10;
figure('color','w','position',[127 101 725 782])
colormap jet
subplot(3,1,1)
%scatter(sled_table.TS_LATITUDE_DEG,sled_table.DEPTH_M,symbol_size, sled_table.CTD_TEMPERATURE_DEG_C), colorbar, set(gca, 'xdir', 'rev')
scatter(suna.Lat,suna.Depth_m,symbol_size, suna.NITRATE_UM), colorbar, set(gca, 'xdir', 'rev')
set(gca, 'ydir', 'rev', 'xdir', 'rev'), axis([latlim 0 zmax])
caxis([-1 30]), colorbar
text(41.15, zmax*.8, 'Nitrate (\muM)')
titleHandle = title(titlestr);
addStnLabels(labelDepth)
hold on
plot(bath.latitude, bath.bottom_depth_meters, 'linewidth', 2, 'color', [.5 .5 .5])

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
