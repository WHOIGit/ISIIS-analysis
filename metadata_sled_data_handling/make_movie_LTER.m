load 'C:\Users\ISIIS WHOI\gss_logs\NESLTER_EN668_sled_data'
p = 'd:\Stingray_summary\NESLTER_EN668\';
f = dir([p 'NESLTER_EN668*']);

%%
fcount = 1;
load([f(fcount).folder filesep f(fcount).name filesep 'Image_metadata.mat'])
metaTable_all = metaTable;
for fcount = 2:length(f)
    load([f(fcount).folder filesep f(fcount).name filesep 'Image_metadata.mat'])
    metaTable_all = [metaTable_all; metaTable];
end
metaTable = metaTable_all;
clear metaTable_all fcount

%%
%Tow 1-7
sled_table(sled_table.matdate > datenum('7-19-2021 23:00:00'),:) = [];
metaTable(metaTable.matdate > datenum('7-19-2021 23:00:00'),:) = []; 
v = VideoWriter(['c:\work\Stingray_summary\NESLTER_EN668\movie_300_15_TChl_outbound2']);
%%Tow 4-8
%sled_table(sled_table.matdate < datenum('7-19-2021 00:00:00'),:) = [];
%metaTable(metaTable.matdate < datenum('7-19-2021 00:00:00'),:) = []; 
%v = VideoWriter(['c:\work\Stingray_summary\NESLTER_EN668\movie_300_15_TChl_inbound']);

%%

figure, set(gcf, 'position', [1200 40 700 950], 'renderer', 'painters')
subplot(4,1,[1:2])

s2 = subplot(4,1,3);
scatter(sled_table.TS_LATITUDE_DEG, sled_table.DEPTH_M, 10, sled_table.CTD_TEMPERATURE_DEG_C,'filled')
caxis([8 22]), colormap jet
cb = colorbar('location', 'east');
set(cb, 'position', [.93 .328 .015 .16])
set(gca, 'ydir', 'rev', 'xdir', 'rev')
hold on
xlim([39.7 41.2])
ylim([0 150])
xl = xlim;
text(41.15, 125, 'Temperature (\circC)')

s3 = subplot(4,1,4);
scatter(sled_table.TS_LATITUDE_DEG, sled_table.DEPTH_M, 10, .0073*(sled_table.FLUOROMETER_CHLOROPHYLL_RAW-48),'filled')
caxis([0 4]), colormap jet
cb = colorbar('location', 'east');
set(cb, 'position', [.93 .11 .015 .16])
set(gca, 'ydir', 'rev', 'xdir', 'rev')
hold on
xlim([39.7 41.2])
ylim([0 150])
xl = xlim;
text(41.15, 125, 'Chl from fluor (mg m^{-3})')

%%
%%v.FrameRate = 70;
v.FrameRate = 15;
open(v)
t1 = []; t2 = [];

%for fcount = 1:48 %34:length(f)% 34:length(f) tow 4-8 1:48 for tow 1-7 
%    load([f(fcount).folder filesep f(fcount).name filesep 'Image_metadata.mat'])
%    disp(f(fcount).name)
   % v = VideoWriter(['c:\work\Stingray_summary\OTZ_SG2105\movie6_7May2021' num2str(fcount,'%02d')]);
   % open(v)
%    for ii = 1:70:size(metaTable,1)
    for ii = 1:300:size(metaTable,1)
        %disp(ii)
        img = imread(metaTable.pid{ii});
        subplot(4,1,1:2)
        imshow(img)
 
        delete(t1)
        t1 = plot(s2, metaTable.TS_LATITUDE_DEG(ii), metaTable.DEPTH_M(ii), 'k+');
        delete(t2)
        t2 = plot(s3, metaTable.TS_LATITUDE_DEG(ii), metaTable.DEPTH_M(ii), 'k+');
        drawnow
        frame = getframe(gcf);
        writeVideo(v,frame);
    end
    %close(v)
%end
close(v)