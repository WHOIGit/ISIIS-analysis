load 'C:\Users\ISIIS WHOI\gss_logs\OTZ_SG2105_sled_data'
p = 'c:\work\Stingray_summary\OTZ_SG2105\';
f = [dir([p 'OTZ_SG2105_06*']);dir([p 'OTZ_SG2105_07*'])];
%f = [dir([p 'OTZ_SG2105_12*']); dir([p 'OTZ_SG2105_13*']);dir([p 'OTZ_SG2105_14*'])];
%%

figure, set(gcf, 'position', [1200 80 700 800], 'renderer', 'painters')
subplot(3,5,[1:5,7])

s2 = subplot(3,5,11:12);
%plot(sled_table.TS_LONGITUDE_DEG, sled_table.TS_LATITUDE_DEG, '.')
scatter(sled_table.TS_LONGITUDE_DEG, sled_table.TS_LATITUDE_DEG, 10, .0073*(sled_table.FLUOROMETER_CHLOROPHYLL_RAW-48),'filled')
caxis([0 3])
cb = colorbar('location', 'east');
set(cb, 'position', [.385 .12 .015 .18])
hold on
axis([-15.1 -14.6 48.3 49.3])
text(-14.9, 48.4,'Chl (mg m^{-3})')

s3 = subplot(3,5,13:15);
%plot(sled_table.matdate, sled_table.DEPTH_M, '.')
scatter(sled_table.matdate, sled_table.DEPTH_M, 10, sled_table.CTD_TEMPERATURE_DEG_C,'filled')
caxis([9 13])
cb = colorbar('location', 'east');
set(cb, 'position', [.89 .12 .015 .18])
set(gca, 'ydir', 'rev')
hold on
xlim([datenum(2021,5,6) datenum(2021,5,7,10,0,0)])
%xlim([datenum(2021,5,12,23,0,0) datenum(2021,5,14,10,0,0)])
datetick('x', 6,'keeplimits')
xl = xlim;
text(xl(1)+.1, 900, 'Temperature (\circC)')
set(gca, 'position', [.47 .11 .4494 .2157])

%%
%v = VideoWriter(['c:\work\Stingray_summary\OTZ_SG2105\movie6_7May2021' num2str(fcount,'%02d')]);
v = VideoWriter(['c:\work\Stingray_summary\OTZ_SG2105\movie06_07May2021_70TChl']);
%v = VideoWriter(['c:\work\Stingray_summary\OTZ_SG2105\movie13_14May2021_70TChl']);
v.FrameRate = 70;
open(v)
t1 = []; t2 = [];
for fcount = 1:length(f)
    load([f(fcount).folder filesep f(fcount).name filesep 'Image_metadata.mat'])
    disp(f(fcount).name)
   % v = VideoWriter(['c:\work\Stingray_summary\OTZ_SG2105\movie6_7May2021' num2str(fcount,'%02d')]);
   % open(v)
    for ii = 1:70:size(metaTable,1)
        %disp(ii)
        img = imread(metaTable.pid{ii});
        subplot(3,5,[1:5,7])
        imshow(img)
        %subplot(3,5,[11:12])
        delete(t1)
        hold on
        t1 = plot(s2,metaTable.TS_LONGITUDE_DEG(ii), metaTable.TS_LATITUDE_DEG(ii), 'r*');
        %subplot(3,5,13:15)
        delete(t2)
        t2 = plot(s3, metaTable.matdate(ii), metaTable.DEPTH_M(ii), 'r*');
        drawnow
        frame = getframe(gcf);
        writeVideo(v,frame);
    end
    %close(v)
end
close(v)