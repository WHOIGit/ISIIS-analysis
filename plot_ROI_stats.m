base = 'D:\Stingray_summary\OTZ_SG2105\';
f = dir([base 'OTZ_SG2105_18May*']);
f = {f.name};
Nall = [];
metaTable_all = table;
Nesdall = [];
esd_bins = [0:.5:50];
mm_per_pixel = .0445;
liters_per_frame = 2.3183;

for dircount = 1:length(f)
    disp(f(dircount))
    load([base f{dircount} '\Image_metadata.mat'])
    if size(metaTable,1) > 51
        load(['D:\OTZ_SG2105\ROIs\features\' f{dircount}])
        
        imgID = split(cellstr(Props.roiID), '_');
        imgnum = str2num(char(imgID(:,8)));
        imgID = join(imgID(:,1:8),'_');
        
        meta_imgID = split(metaTable.pid, '\');
        meta_imgID = meta_imgID(:,end);
        meta_imgID_temp = split(meta_imgID, '_');
        meta_imgnum = str2num(char(regexprep(meta_imgID_temp(:,end), '.tiff', '')));
        
        [a,b] = bounds(imgnum);
        frame_set = 100;
        bins = a:frame_set:b;
        binc = bins(1:end-1)+50;
        if length(bins) > 1
            [N,edges,bin_num] = histcounts(imgnum, bins);
            %bin_num is 0 for images not used after the last bin edge
            Nall = [Nall; N'];
            [~,meta_ind] = intersect(meta_imgnum,binc);
            metaTable_all = [metaTable_all; metaTable(meta_ind,:)];
            Nesd_temp = NaN(length(binc),length(esd_bins));
            for bincount = 1:length(binc)
                ii = find(bin_num == bincount);
                [Nesd_temp(bincount,:)] = histcounts(2*sqrt(Props.Area(ii)/pi)*mm_per_pixel,[esd_bins inf]);
            end
            Nesdall = [Nesdall; Nesd_temp];
        end
    end
end

%%
%load("C:\Users\ISIIS WHOI\gss_logs\OTZ_SG2105_sled_data")
figure
ind = find(sled_table.matdate>datenum('2021-5-18') & sled_table.matdate<datenum('2021-5-18 17:00'));
scatter(sled_table.LONadj(ind), sled_table.DEPTH_M(ind), 40,sled_table.CTD_TEMPERATURE_DEG_C(ind), '.')
set(gca, 'ydir', 'rev')
caxis([11 13]), ch = colorbar; colormap jet
title(ch, 'Temperature (\circC)', 'fontsize', 10)
ylim([0 420])
set(gcf, 'position', [680 550 560 280])

xi = -15.4:.02:-14.6; yi = (0:20:400)';
Zgrid = griddata(sled_table.LONadj(ind), sled_table.DEPTH_M(ind)',sled_table.CTD_TEMPERATURE_DEG_C(ind),xi,yi);
hold on
contour(xi, yi, Zgrid, [11.6 11.6], 'color', 'm', 'linewidth', 2)
print('D:\Stingray_summary\OTZ_SG2105\EdgeExpt_temperature', '-dpng', '-r300')

%%

%llim = 1; clim = [4.5 6.5];
%llim = 2; clim = [3 5];
%llim = 5; clim = [2 4]; 
lim = [1 2]; clim = [4.5 6.5];
%lim = [2 4]; clim = [4 6];
%lim = [4 8]; clim = [3.5 5.5]; 
%lim = [8 16]; clim = [1.5 3.5]; 
%lim = [16 32]; clim = [1 3]; 
figure(lim(1)), clf
%esd2use = find(esd_bins>=llim);
esd2use = find(esd_bins>=lim(1) & esd_bins<lim(2));
%scatter(metaTable_all.TS_LONGITUDE_DEG, metaTable_all.DEPTH_M, 40,log10(sum(Nesdall(:,esd2use),2)*liters_per_frame*frame_set), '.')
scatter(metaTable_all.LONadj, metaTable_all.DEPTH_M, 40,log10(sum(Nesdall(:,esd2use),2)*liters_per_frame*frame_set), '.')
set(gca, 'ydir', 'rev')
caxis(clim), ch = colorbar; colormap jet
set(ch, 'ticklabels', strcat('10^{',num2str(get(ch, 'ytick')'), '}'))
title(ch, 'Concentration (L^{-1})', 'fontsize', 10)
%title(['> ' num2str(llim) ' mm'])
title([num2str(lim(1)) ' mm < ESD > ' num2str(lim(2)) ' mm'])
ylim([0 420])
set(gcf, 'position', [680 550 560 280])
hold on
contour(xi, yi, Zgrid, [11.6 11.6], 'color', 'm', 'linewidth', 2)
print(['D:\Stingray_summary\OTZ_SG2105\EdgeExpt_particles' num2str(lim(1)) '-' num2str(lim(2))], '-dpng', '-r300')

%%
% figure
% scatter(sled_table.DEPTH_M(ind),sled_table.CTD_TEMPERATURE_DEG_C(ind),3,sled_table.LONadj(ind))
% view([90 90])
% xlabel('Depth (m)')
% ylabel('Temperature (\circC)')
% set(gca, 'YAxisLocation', 'right')
% colormap jet, ch = colorbar;
% title(ch, 'Longitude (\circ)')
%%

figure
scatter(sled_table.LONadj(ind), sled_table.DEPTH_M(ind), 40,log10(.0073*(sled_table.FLUOROMETER_CHLOROPHYLL_RAW(ind)-48)), '.')
set(gca, 'ydir', 'rev')
caxis(log10([.035 3])), ch = colorbar; colormap jet
set(ch, 'ytick', log10([.1 .3 1 3]))
set(ch, 'ticklabels', num2str(10.^get(ch, 'ytick')',1))
title(ch, 'Chl, fl. estimated (\mug l^{-1})', 'fontsize', 10)
ylim([0 420])
set(gcf, 'position', [680 550 560 280])
hold on
contour(xi, yi, Zgrid, [11.6 11.6], 'color', 'm', 'linewidth', 2)
print('D:\Stingray_summary\OTZ_SG2105\EdgeExpt_chl', '-dpng', '-r300')

%%
figure
scatter(metaTable_all.DEPTH_M,log10(sum(Nesdall(:,esd2use),2)*liters_per_frame*frame_set),3,metaTable_all.LONadj)
view([90 90])
xlabel('Depth (m)')
ylabel('Concentration (L^{-1})')
set(gca, 'YAxisLocation', 'right')
colormap jet, ch = colorbar;
title(ch, 'Longitude (\circ)')
title([num2str(lim(1)) ' mm < ESD > ' num2str(lim(2)) ' mm'])




return
plot(bins(1:end-1), N)
binc = bins(1:end-1)+50;
[~,meta_ind] = intersect(meta_imgnum,binc);

liters_per_frame = 2.3183;
mm_per_pixel = .0445;
plot(metaTable.DEPTH_M(meta_ind), N*liters_per_frame*frame_set)

plot(metaTable.DEPTH_M(meta_ind), N/(liters_per_frame*frame_set)), view(90,90)
xlabel('Depth (m)')
ylabel('Particle concentration (l^{-1})')
set(gca,'YAxisLocation', 'right')

