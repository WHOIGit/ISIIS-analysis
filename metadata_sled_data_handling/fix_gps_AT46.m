p = 'C:\Users\ISIIS WHOI\gss_logs\';
cstr = 'NESLTER_AT46';
load([p cstr '_sled_data'])
%ind = find(sled_table.matdate<datenum('10-15-2020'));
sled_table_temp = sled_table; %(ind,:);

t = dir([p '\AT46\*.csv']); 
uw = [];
for ii = 1:length(t)
    disp(t(ii).name)
    uw = [uw; readtable([p '\AT46\' t(ii).name])];
end
uw.dt = datetime(uw.DATE_GMT, 'InputFormat', 'yyyy/MM/dd')+uw.TIME_GMT;
uw.matdate = datenum(uw.dt);
%uw.matdate = datenum('1-1-1970')+uw.DateTime_UNIX/3600/24/1000; %from milliseconds
%ii = find(diff(uw.matdate) == 0);
%uw(ii,:) = []; %remove records with repeat times
sled_table_temp.matdate_gps_epoch = datenum('1-1-1970')+sled_table_temp.TS_GPS_EPOCH_TIME/3600/24;

%offset = mode(sled_table_temp.matdate-sled_table_temp.matdate_gps_epoch);
offset = 0;

sled_table_temp.latitude_ship = interp1(uw.matdate, uw.Dec_LAT, sled_table_temp.matdate-offset);
sled_table_temp.longitude_ship = interp1(uw.matdate, uw.Dec_LON, sled_table_temp.matdate-offset);
sled_table_temp.TS_LATITUDE_DEG_bad = sled_table_temp.TS_LATITUDE_DEG;
sled_table_temp.TS_LONGITUDE_DEG_bad = sled_table_temp.TS_LONGITUDE_DEG;

ii = find(abs(sled_table_temp.latitude_ship-sled_table.TS_LATITUDE_DEG)>1e-3);
sled_table_temp.TS_LATITUDE_DEG(ii) = sled_table_temp.latitude_ship(ii);
ii = find(abs(sled_table_temp.longitude_ship-sled_table.TS_LONGITUDE_DEG)>1e-3);
sled_table_temp.TS_LONGITUDE_DEG(ii) = sled_table_temp.longitude_ship(ii);

sled_table = sled_table_temp;

save([p cstr '_sled_data_fixedGPS'], 'sled_table')
