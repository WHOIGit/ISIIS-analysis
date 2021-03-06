p = 'C:\Users\ISIIS WHOI\gss_logs\';
cstr = 'NESLTER_EN657';
load([p cstr '_sled_data'])

%load([p 'EN657_sled_table_20201013_14_fixedGPS'])

sled_table(1:size(sled_table_20201013_14_fixedGPS,1),:) = sled_table_20201013_14_fixedGPS(:,1:size(sled_table,2));

save([p cstr '_sled_data'], 'sled_table')
