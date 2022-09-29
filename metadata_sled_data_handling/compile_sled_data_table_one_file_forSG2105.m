function sled_table = compile_sled_data_table_one_file_forSG2105(output_str)
% function sled_table = compile_sled_data_table(input_spec,output_str)
% For example:
% sled_table = compile_sled_data_table_one_file_forSG2105('C:\Users\ISIIS WHOI\gss_logs\20210514_065559.506_BELLAMARE_CSV_DATA_BELLAMARE_CSV_DATA.csv', 'OTZ_SG21025');
%
%   
% Read CSV files output from Greensea Workspace export option for
% Stingray/ISIIS sled data files, remove unneeded variable for small data file transfer between ships during OTZ SG2105
% and save final table
%
% Heidi M. Sosik, Woods Hole Oceanographic Institution, August 2020
% ISIIS-analysis code set(function adapted from earlier script)
[f, p] = uigetfile('C:\Users\ISIIS WHOI\gss_logs\*.csv');
sled_table = importfile_ISIIS([p filesep f], [6, Inf]);

    sled_table.matdate = datenum('1-1-1970')+sled_table.LCM_event_timestamp/3600/24/1e6;
    sled_table.CHL_fromECO_microgm_per_l = .0073*(sled_table.FLUOROMETER_CHLOROPHYLL_RAW-48);
    sled_table.BACKSCATTERING__fromECO_per_meter_per_sr = 1.684e-6*(sled_table.FLUOROMETER_BACKSCATTER_RAW-48);
    var2del = {'UNIX_timestamp'  'AANDERAA_TEMP_C'  'ALTITUDE_M' 'ALTITUDE_OK'...
    'CTD_SOUND_VELOCITY' 'FORWARD_VELOCITY_M_PER_S'  'HEADING_DEG' 'PITCH_DEG'...
    'ROLL_DEG' 'SEABIRD_PAR_ADC' 'SEABIRD_PAR_VDC' 'TS_GPS_EPOCH_TIME'...
    'VERTICAL_VELOCITY_M_PER_S' 'count_publish' 'sender_id' 'FLUOROMETER_BACKSCATTER_RAW' 'FLUOROMETER_CHLOROPHYLL_RAW'};
   
    sled_table = removevars(sled_table, var2del);
    sled_table = sled_table(1:9:end,:);
   % [p,f] = fileparts(input_file);
    f = regexprep(f,'_CSV_DATA_BELLAMARE_CSV_DATA.csv', '_Stingray_data.mat');

    save([p filesep f], 'sled_table')
    disp('Results saved:')
    disp([p filesep f])
end

