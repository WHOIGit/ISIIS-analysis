feadir = '\\vortex\share\otz-data\SG2105\Stingray\OTZ_SG2105_ROIs\features\';
esd_bins = [0:.5:50];
mm_per_pixel = .0445;

CNNpath = 'C:\work\OTZ\Cruises\Sarmiento2021\Stingray\CNN_output\20220128_ISIIS_SG2105_Jan2022_0\';
metapath = '\\vortex\share\otz-data\SG2105\Stingray\Image_metadata\';
files = dir([CNNpath '*.json']);
S = jsondecode(fileread(fullfile(files(1).folder, files(1).name)));
class_labels = S.class_labels';

%%
thresh_config = table;
thresh_config.class_label = class_labels';
thresh_config.score_minLG(:) = .8;
thresh_config.score_minSM(:) = .8;
thresh_config.second_setLG(:) = {''};
thresh_config.second_setSM(:) = {''};
thresh_config.score_minLG(strcmp('marine_snow',thresh_config.class_label)) = 0;
thresh_config.score_minSM(strcmp('marine_snow',thresh_config.class_label)) = 0;
thresh_config.score_minLG(strcmp('salp',thresh_config.class_label)) = .95;
thresh_config.score_minSM(strcmp('salp',thresh_config.class_label)) = inf;
thresh_config.score_minLG(strcmp('ctenophore_lobate',thresh_config.class_label)) = .5;
thresh_config.score_minSM(strcmp('ctenophore_lobate',thresh_config.class_label)) = inf;
thresh_config.score_minLG(strcmp('doliolid',thresh_config.class_label)) = .98;
thresh_config.score_minSM(strcmp('doliolid',thresh_config.class_label)) = .98;
thresh_config.score_minLG(strcmp('medusa',thresh_config.class_label)) = .95;
thresh_config.score_minSM(strcmp('medusa',thresh_config.class_label)) = .95;
thresh_config.score_minLG(strcmp('polychaete',thresh_config.class_label)) = .85;
thresh_config.score_minSM(strcmp('polychaete',thresh_config.class_label)) = .85;
thresh_config.score_minLG(strcmp('radiolarian_colony',thresh_config.class_label)) = .95;
thresh_config.score_minSM(strcmp('radiolarian_colony',thresh_config.class_label)) = inf;
thresh_config.second_setLG(strcmp('radiolarian_colony',thresh_config.class_label)) = {'marine_snow'};
thresh_config.score_minLG(strcmp('appendicularian',thresh_config.class_label)) = .95;
thresh_config.score_minSM(strcmp('appendicularian',thresh_config.class_label)) = inf;
thresh_config.second_setLG{strcmp('appendicularian',thresh_config.class_label)} = {'detritus transparent' 'artifact'};

iii = size(thresh_config,1)+1;
thresh_config.class_label{iii} = {'copepod' 'euphausid'};
thresh_config.second_setLG{iii} = {'marine_snow'};
thresh_config.second_setSM(iii) = {'marine_snow'};
thresh_config.score_minLG(iii) = 0.8;
thresh_config.score_minSM(iii) = 0.8;

iii = size(thresh_config,1)+1;
thresh_config.class_label{iii} = class_labels(startsWith(class_labels,'siphon'));
thresh_config.second_setLG{iii} = {''};
thresh_config.second_setSM{iii} = {'appendicularian' 'marine_snow' 'radiolarian_colony' 'doliolid' 'detritus transparent' 'artifact' 'fecal_pellet_long'};
thresh_config.score_minLG(iii) = 0.5;
thresh_config.score_minSM(iii) = 0.8;

iii = size(thresh_config,1)+1;
thresh_config.class_label{iii} = {'ctenophore' 'ctenophore_cydippid'};
thresh_config.second_setLG{iii} = {''};
thresh_config.second_setSM{iii} = {''};
thresh_config.score_minLG(iii) = 0.85;
thresh_config.score_minSM(iii) = 0.85;

iii = size(thresh_config,1)+1;
thresh_config.class_label{iii} = {'acantharian_skinny_star_straight' 'radiolarian'};
thresh_config.second_setLG{iii} = {'marine_snow'};
thresh_config.second_setSM{iii} = {'marine_snow'};
thresh_config.score_minLG(iii) = 0.9;
thresh_config.score_minSM(iii) = 0.9;
%%
num2bin = 150;
binLiters = num2bin*2.318;
hLG1 = [];
%hLG2 = hLG1;
hSM1 = hLG1;
%hSM2 = hLG1;
mar_snow_plus_byESD = []; 
meta_binall = [];
file_binall = [];
numclass = size(thresh_config,1)+1;
for fii = 1:length(files)
    disp(fii)
    S = jsondecode(fileread(fullfile(files(fii).folder, files(fii).name)));
    imgfolder = regexprep(files(fii).name, '_img_results.json', '');
    t = split(S.input_images, '_');
    frames = join(t(:,1:end-2),'_');
    frameNum = str2num(char(t(:,end-2)));
    %roiID = regexprep(t(:,end), '.png', '');
    roiID = split(S.input_images,'.png');
    roiID = roiID(:,1);
    %small ROIs
    S2 = jsondecode(fileread(fullfile(files(fii).folder, imgfolder, 'small_img_results.json')));
    t = split(S2.input_images, '_');
    frames2 = join(t(:,1:end-2),'_');
    frameNum2 = str2num(char(t(:,end-2)));
    roiID2 = split(S2.input_images,'.png');
    roiID2 = roiID2(:,1);
    
    load(fullfile(metapath, imgfolder, 'Image_metadata'));
    t = split(metaTable.pid,'\');
    meta_frames = regexprep(t(:,end), '.tiff', '');
    t = split(meta_frames, '_');
    meta_frameNum = str2num(char(t(:,end)));
    [~,ia] = ismember(frames, meta_frames);
    meta_match = metaTable(ia,:);
    [~,ia] = ismember(frames2, meta_frames);
    meta_match2 = metaTable(ia,:);
    frame_edges = min(meta_frameNum):num2bin:max(meta_frameNum);
    optClass = NaN(size(S.output_classes+1));
    optClass2 = NaN(size(S2.output_classes+1));
    m1 = max(S.output_scores')';
    m2 = max(S2.output_scores')';
    % marine_snow+ categories for second ranked score, when primary not good enough
    [~,msind] = intersect(class_labels, {'marine_snow' 'detritus transparent' 'fecal_pellet_long' 'artifact' 'diatom_chain'});

    for iii = 1:size(thresh_config,1)
        s = S.output_scores;
        [~,cind] = intersect(class_labels, thresh_config.class_label{iii});
        s1 = sum(s(:,cind),2);
        s(:,cind) = NaN;
        [s2,c2] = max(s'); s2 = s2'; c2 = c2';
        [~,eind] = intersect(class_labels, thresh_config.second_setLG{iii});
        gind = (s1>=m1 & s1>thresh_config.score_minLG(iii) & ~(ismember(c2,eind) & s2>.001));
        optClass(gind) = iii;
        %assign to marine_snow for cases with this class max, but not good enough and marine_snow+ is second
        optClass(s1>=m1 & ~gind &  ismember(c2,msind)) = numclass;
        %now do the small ROIs
        s = S2.output_scores;
        s1 = sum(s(:,cind),2);
        s(:,cind) = NaN;
        [s2,c2] = max(s'); s2 = s2'; c2 = c2';
        [~,eind] = intersect(class_labels, thresh_config.second_setSM{iii});
        gind = (s1>=m2 & s1>thresh_config.score_minSM(iii) & ~(ismember(c2,eind) & s2>.001));
        optClass2(gind) = iii;
        %assign to marine_snow for cases with this class max, but not good enough and marine_snow+ is second
        optClass2(s1>=m2 & ~gind &  ismember(c2,msind)) = numclass;
    end
    h = histcounts2(frameNum,optClass,frame_edges, 1:numclass+1);
    h2 = histcounts2(frameNum2,optClass2,frame_edges, 1:numclass+1);

    load([feadir imgfolder])
    roiIDfea = split(cellstr(Props.roiID),'.png');
    roiIDfea = roiIDfea(:,1);
    [~,ii] = ismember(roiID, roiIDfea);
    esd = 2*sqrt(Props.Area(ii)/pi)*mm_per_pixel; %esd for each target in mm
    ii = (optClass==strmatch('marine_snow', class_labels) | optClass == numclass); %marine_snow or last class mar_snow+
   % hmsp = histcounts(esd(ii),[esd_bins inf]);
    hmsp = histcounts2(frameNum(ii),esd(ii),frame_edges,[esd_bins inf]);
    [~,ii] = ismember(roiID2, roiIDfea);
    esd = 2*sqrt(Props.Area(ii)/pi)*mm_per_pixel; %esd for each target in mm
    ii = (optClass2==strmatch('marine_snow', class_labels) | optClass2 == numclass); %marine_snow or last class mar_snow+
    %hmsp2 = his    
    hmsp2 = histcounts2(frameNum2(ii),esd(ii),frame_edges,[esd_bins inf]);

    bin_ind = discretize(meta_frameNum,frame_edges);
    T = removevars(metaTable,{'sender_id','pid'});
    meta_bin = T(1,:);
    file_bin = table;
    for ii = 1:length(frame_edges)-1
        ind = find(bin_ind==ii);
        meta_bin{ii,:} = (nanmean(T{ind,:}));
        file_bin.imgfolder(ii) = cellstr(imgfolder);
        file_bin.frame(ii) = meta_frames(ind(1)); %first frame of the bin
        file_bin.frameNum(ii) = meta_frameNum(ind(1));
    end
%    hLG1 = [hLG1; hodd];
%    hLG2 = [hLG2; heven];
%    hSM1 = [hSM1; h2odd];
%    hSM2 = [hSM2; h2even];
    hLG1 = [hLG1; h];
    hSM1 = [hSM1; h2];
    mar_snow_plus_byESD = [mar_snow_plus_byESD; hmsp+hmsp2];
    meta_binall = [meta_binall; meta_bin];
    file_binall = [file_binall; file_bin];
    if ~isequal(size(meta_binall,1),size(hLG1,1))
        keyboard
    end
end
class_labels = S.class_labels';
clear h h2 meta_bin fii T frame* cc*
save('c:\work\OTZ\SG2105_ISIIS_CNN_edge_opt_withSize', '*all', 'class_labels', 'files', 'CNNpath', 'hLG*', 'hSM*', 'mar_snow_plus*', 'esd_bins', 'binLiters')

return
%plots for OSM 2022 below here
%%
load c:\work\OTZ\SG2105_ISIIS_CNN_edge_opt_withSize
%%
load('C:\work\OTZ\Cruises\Sarmiento2021\sled_data\OTZ_SG2105_sled_data.mat')
isled = find(sled_table.matdate>datenum('5-18-2021') & sled_table.matdate<datenum('5-18-2021 18:00'));
xi = -15.4:.02:-14.6; yi = (0:20:400)';
Zgrid = griddata(sled_table.LONadj(isled), sled_table.DEPTH_M(isled)',sled_table.CTD_TEMPERATURE_DEG_C(isled),xi,yi);
%%
load('C:\work\OTZ\Cruises\Sarmiento2021\Stingray\SR1_edge_watermass.mat')
inn = find(~isnan(SR1wm.mtime));
wm_all = round(interp1(SR1wm.mtime(inn),SR1wm.watermass(inn), meta_binall.matdate));
watermassStr(:,1) = {'ML west' 'ML filament' 'ML eddy' 'Unknown' 'Subducted' 'Deep eddy' 'Deep filament' ['Transition ML-subd']};
%2/28/2022 Fix for label error from Leah Johnson
watermassStr(:,1) = {'ML filament' 'ML west' 'ML eddy' 'Unknown' 'Subducted' 'Deep eddy' 'Deep filament' ['Transition ML-subd']};

%%
lim_all = [1 2; 2 4; 4 8; 8 16; 16 32];
clim = [1.5 4.5; 1 4; .5 3.5; 0 1.5; -inf inf]; %log10
esd2use = find(esd_bins>=lim(1,1) & esd_bins<lim(1,2));

for ii = 1:size(lim_all,1)-1
    lim = lim_all(ii,:);
    esd2use = find(esd_bins>=lim(1) & esd_bins<lim(2));
    h = sum(mar_snow_plus_byESD(:,esd2use),2);
    figure, set(gcf, 'position', [250 300 670 290])
    scatter(meta_binall.LONadj,meta_binall.DEPTH_M, 20, log10(h./binLiters*1000),'filled')
%    scatter(meta_binall.LONadj,meta_binall.DEPTH_M, 20, h./binLiters*1000,'filled')
    hold on
    title([num2str(lim(1)) 'mm \leq ESD > ' num2str(lim(2)) ' mm']) 
    %m = prctile(h(h>0)',95);
    %if ~isnan(m)
    %    caxis(([0 m]./binLiters*1000))
    %end
    caxis(clim(ii,:))
    set(gca, 'ydir', 'rev')
    ylim([0 420]), xlim([-15.4 -14.65])
    ylabel('Depth (m)')
    ch = colorbar('location', 'east');
    set(ch, 'position', [.9 .3 .0318 .6])
    title(ch, ' (m^{-3})')
    set(ch, 'ytick', ceil(clim(ii,1)):floor(clim(ii,2)))
  %  set(ch, 'yticklabel', 10.^get(ch, 'ytick'))
    set(ch, 'yticklabel', strcat('10^', num2str(get(ch, 'ytick')')))
    colormap parula
   % contour(xi, yi, Zgrid, [11.6 11.6], 'color', 'm', 'linewidth', 2)
   % print(['C:\work\OTZ\Cruises\Sarmiento2021\Stingray\marine_snow' num2str(ii) '_section_isoT'],'-dpng') 
    print(['C:\work\OTZ\Cruises\Sarmiento2021\Stingray\marine_snow' num2str(ii) '_section'],'-dpng') 
    %pause
end
%%
%for ii = 1:size(lim_all,1)-1
    lim = lim_all(1,:);
    esd2use = find(esd_bins>=lim(1) & esd_bins<lim(2));
    %esd2use = 1:length(esd_bins);
    h = sum(mar_snow_plus_byESD(:,esd2use),2);
    figure, set(gcf, 'position', [250 300 670 290])
%    scatter(meta_binall.LONadj,meta_binall.DEPTH_M, 20, log10(h./binLiters*1000),'filled')
    scatter(meta_binall.LONadj,meta_binall.DEPTH_M, 20, h./binLiters*1000,'filled')
    hold on
    title([num2str(lim(1)) 'mm \leq ESD > ' num2str(lim(2)) ' mm']) 
    caxis([0 20000])
    set(gca, 'ydir', 'rev')
    ylim([0 420]), xlim([-15.4 -14.65])
    ylabel('Depth (m)')
    ch = colorbar('location', 'east');
    set(ch, 'position', [.9 .3 .0318 .6])
    title(ch, ' (m^{-3})')
  %  set(ch, 'ytick', ceil(clim(ii,1)):floor(clim(ii,2)))
  %  set(ch, 'yticklabel', strcat('10^', num2str(get(ch, 'ytick')')))
    colormap parula
   % contour(xi, yi, Zgrid, [11.6 11.6], 'color', 'm', 'linewidth', 2)
   % print(['C:\work\OTZ\Cruises\Sarmiento2021\Stingray\marine_snow_all'  '_section_isoT'],'-dpng') 
   % print(['C:\work\OTZ\Cruises\Sarmiento2021\Stingray\marine_snow_all' '_section'],'-dpng') 
%end

%%
%figure(1), clf
%set(gcf, 'position', [250 220 500 350])  %500 vs 670
dlm = [12000 3500 400 5 inf];
for ii = 1:size(lim_all,1)
    lim = lim_all(ii,:);
    esd2use = find(esd_bins>=lim(1) & esd_bins<lim(2));
    h = sum(mar_snow_plus_byESD(:,esd2use),2);
    figure, set(gcf, 'position', [250 220 500 350])  %500 vs 670
  %  boxplot(h', wm_all', 'notch', 'on')
    boxplot(h', wm_all', 'ExtremeMode', 'compress', 'DataLim', [-inf dlm(ii)], 'notch', 'on')
    set(gca, 'xticklabel', watermassStr(:,1), 'XTickLabelRotation', 80,'fontsize', 12)
    %title(class_labels3(ic), 'interpreter', 'none')
    ylabel('Concentration (m^{-3})') 
    th = title([num2str(lim(1)) 'mm \leq ESD > ' num2str(lim(2)) ' mm']) ;
    p = get(th, 'position');
    p(1:2) = [6.5 dlm(ii)*1.05];
    set(th, 'position', p)
    %pause
    print(['C:\work\OTZ\Cruises\Sarmiento2021\Stingray\marine_snow' num2str(ii) '_boxplot_watermass'],'-dpng')
end