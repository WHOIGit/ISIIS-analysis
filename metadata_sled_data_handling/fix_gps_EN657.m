p = 'C:\Users\ISIIS WHOI\gss_logs\';
cstr = 'NESLTER_EN657';
load([p cstr '_sled_data'])
ind = find(sled_table.matdate<datenum('10-15-2020'));
sled_table_temp = sled_table(ind,:);

load([p 'EN657_Data1SecDaily20201013_14'])

Data1SecDaily20201013_14.matdate = datenum('1-1-1970')+Data1SecDaily20201013_14.DateTime_UNIX/3600/24/1000; %from milliseconds
ii = find(diff(Data1SecDaily20201013_14.matdate) == 0);
Data1SecDaily20201013_14(ii,:) = []; %remove records with repeat times
sled_table_temp.matdate_gps_epoch = datenum('1-1-1970')+sled_table_temp.TS_GPS_EPOCH_TIME/3600/24;

offset = mode(sled_table_temp.matdate-sled_table_temp.matdate_gps_epoch);

sled_table_temp.latitude_ship = interp1(Data1SecDaily20201013_14.matdate, Data1SecDaily20201013_14.GPSFurunoLatitude, sled_table_temp.matdate-offset);
sled_table_temp.longitude_ship = interp1(Data1SecDaily20201013_14.matdate, Data1SecDaily20201013_14.GPSFurunoLongitude, sled_table_temp.matdate-offset);
sled_table_temp.TS_LATITUDE_DEG_bad = sled_table_temp.TS_LATITUDE_DEG;
sled_table_temp.TS_LONGITUDE_DEG_bad = sled_table_temp.TS_LONGITUDE_DEG;
sled_table_temp.TS_LATITUDE_DEG = sled_table_temp.latitude_ship;
sled_table_temp.TS_LONGITUDE_DEG = sled_table_temp.longitude_ship;

sled_table(ind,:) = sled_table_temp(:,1:size(sled_table,2));

save([p cstr '_sled_data_fixedGPS'], 'sled_table')
