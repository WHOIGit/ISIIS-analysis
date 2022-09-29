function sled_table = compile_sled_data_table(input_spec,output_str)
% function sled_table = compile_sled_data_table(input_spec,output_str)
% For example:
% sled_table = compile_sled_data_table('C:\Users\ISIIS WHOI\gss_logs\202003*','OTZ_AR43');
%   
% Read CSV files output from Greensea Workspace export option for
% Stingray/ISIIS sled data files, compile multiple files into a single
% table, and save final table
%
% Heidi M. Sosik, Woods Hole Oceanographic Institution, August 2020
% ISIIS-analysis code set(function adapted from earlier script)

    f = dir([input_spec '.csv']);
    p = f(1).folder;
    f = {f.name}';
    t = regexprep(f, '_BELLAMARE_CSV_DATA_BELLAMARE_CSV_DATA.csv', '');
    t = regexprep(t, '_telemetry.gssbin_BELLAMARE_CSV_DATA.csv', '');
    mdate = datenum(t, 'yyyymmdd_HHMMSS');

    for ii = 1:length(f)
        disp([num2str(ii) ' of ' num2str(length(f)) ' : ' f{ii}])
        T_all{ii} = importfile_ISIIS(fullfile(p,f{ii}), [6, Inf]);
        temp = movmedian(T_all{ii}.TS_LATITUDE_DEG,60);
        T_all{ii}.LATadj = T_all{ii}.TS_LATITUDE_DEG;
        ind = find(abs(T_all{ii}.TS_LATITUDE_DEG-temp)>0.01);
        T_all{ii}.LATadj(ind) = temp(ind);
        temp = movmedian(T_all{ii}.TS_LONGITUDE_DEG,60);
        T_all{ii}.LONadj = T_all{ii}.TS_LONGITUDE_DEG;
        ind = find(abs(T_all{ii}.TS_LONGITUDE_DEG-temp)>0.01);
        T_all{ii}.LONadj(ind) = temp(ind);
    end

    %day = datenum(2020, 3, 11); ii = find(mdate > day & mdate < day+5);
    sled_table = cat(1,T_all{:});
   % sled_table.matdate = datenum('1-1-1970')+sled_table.UNIX_timestamp/3600/24; %seems bad!
    sled_table.matdate = datenum('1-1-1970')+sled_table.LCM_event_timestamp/3600/24/1e6;
    
    save([p filesep output_str '_sled_data'], 'sled_table')
    disp('Results saved:')
    disp([p filesep output_str '_sled_data'])
end

