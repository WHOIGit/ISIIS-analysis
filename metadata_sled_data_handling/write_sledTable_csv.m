load('C:\Users\ISIIS WHOI\gss_logs\OTZ_SG2105_sled_data.mat')

sled_table.datetime_UTC = datetime(sled_table.matdate, 'ConvertFrom', 'datenum');
sled_table = movevars(sled_table, 'datetime_UTC', 'before', 1);
sled_table = removevars(sled_table, 'UNIX_timestamp');
writetable(sled_table,['D:\Stingray_summary\OTZ_SG2105_Stingray_sled_data_v1(' datestr(date, 'ddmmmyyyy') ').csv'])


