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
    roinum = regexprep(t(:,end), '.png', '');
    
    %small ROIs
    S2 = jsondecode(fileread(fullfile(files(fii).folder, imgfolder, 'small_img_results.json')));
    t = split(S2.input_images, '_');
    frames2 = join(t(:,1:end-2),'_');
    frameNum2 = str2num(char(t(:,end-2)));
    
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
 %   isodd = rem(frameNum,2);
 %   hodd = histcounts2(frameNum(isodd==1),optClass(isodd==1),frame_edges, 1:numclass+1);
 %   heven = histcounts2(frameNum(isodd==0),optClass(isodd==0),frame_edges, 1:numclass+1);
 %   isodd = rem(frameNum2,2);
 %   h2odd = histcounts2(frameNum2(isodd==1),optClass2(isodd==1),frame_edges, 1:numclass+1);
 %   h2even = histcounts2(frameNum2(isodd==0),optClass2(isodd==0),frame_edges, 1:numclass+1);
    h = histcounts2(frameNum,optClass,frame_edges, 1:numclass+1);
    h2 = histcounts2(frameNum2,optClass2,frame_edges, 1:numclass+1);

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

    meta_binall = [meta_binall; meta_bin];
    file_binall = [file_binall; file_bin];
    if ~isequal(size(meta_binall,1),size(hLG1,1))
        keyboard
    end
end
class_labels = S.class_labels';
clear h h2 meta_bin fii T frame* cc*
save('c:\work\OTZ\SG2105_ISIIS_CNN_edge_opt', '*all', 'class_labels', 'files', 'CNNpath', 'hLG*', 'hSM*')

%%
class_labels2 = [class_labels 'crustaceans', 'siphonophores', 'other ctenophores', 'radiozoans', 'marine_snow2']
tt = strmatch('marine_snow', class_labels);
hLG1 = [hLG1 hLG1(:,tt)+hLG1(:,end)];
hSM1 = [hSM1 hSM1(:,tt)+hSM1(:,end)];
hL = hLG1;%+hLG2;
hS = hSM1; %+hSM2;

%%
class2plot = {'appendicularian' 'chaetognath' 'ctenophore_lobate' 'doliolid' 'marine_snow'...
    'medusa' 'polychaete' 'salp' 'crustaceans' 'siphonophores' 'other ctenophores' 'radiozoans' 'marine_snow2'};
load('C:\work\OTZ\Cruises\Sarmiento2021\Stingray\SR1_edge_watermass.mat')
load('C:\work\OTZ\Cruises\Sarmiento2021\Stingray\SR1_edge_watermass_all.mat')
inn = find(~isnan(SR1wm.mtime));
wm_all = round(interp1(SR1wm.mtime(inn),SR1wm.watermass(inn), meta_binall.matdate));
[~,icall] = ismember(class2plot, class_labels2);
watermassStr(:,1) = {'ML west' 'ML filament' 'ML eddy' 'Unknown' 'Subducted' 'Deep eddy' 'Deep filament' ['Transition ML-subd']};
%2/28/2022 Fix for label error from Leah Johnson
watermassStr(:,1) = {'ML filament' 'ML west' 'ML eddy' 'Unknown' 'Subducted' 'Deep eddy' 'Deep filament' ['Transition ML-subd']};

class_labels3 = class_labels2;
class_labels3(icall) = {'Appendicularians' 'Chaetognaths' 'Lobate ctenophores' 'Doliolids' 'Marine snow1'...
    'Medusa' 'Polychaetes'  'Salps' 'Crustaceans' 'Siphonphores' 'Ctenophores' 'Radiolarians' 'Marine snow'};

%%
%%
load('C:\work\OTZ\Cruises\Sarmiento2021\sled_data\OTZ_SG2105_sled_data.mat')
isled = find(sled_table.matdate>datenum('5-18-2021') & sled_table.matdate<datenum('5-18-2021 18:00'));
xi = -15.4:.02:-14.6; yi = (0:20:400)';
Zgrid = griddata(sled_table.LONadj(isled), sled_table.DEPTH_M(isled)',sled_table.CTD_TEMPERATURE_DEG_C(isled),xi,yi);

%%
for iii = 1:length(class_labels2)
    figure(3), clf
    subplot(2,1,1)
    scatter(meta_binall.LONadj,meta_binall.DEPTH_M, 20, hL(:,iii)./binLiters*1000,'filled')
    set(gca, 'ydir', 'rev'), title(class_labels3(iii), 'interpreter', 'none')
    m = prctile(hL(hL(:,iii)>0,iii)',95);
    if ~isnan(m)
        caxis([0 m]./binLiters*1000)
    end
    colorbar
    subplot(2,1,2)
    scatter(meta_binall.LONadj,meta_binall.DEPTH_M, 20, hS(:,iii)./binLiters*1000,'filled')
    m = prctile(hS(hS(:,iii)>0,iii)',95);
    set(gca, 'ydir', 'rev')
    if ~isnan(m)
        caxis([0 m]./binLiters*1000)
    end
    colorbar
    colormap jet    
    print(['C:\work\OTZ\Cruises\Sarmiento2021\Stingray\' class_labels3{iii} '_section'],'-dpng') 
    pause
end
%%
for ii = 1:length(icall)
    ic = icall(ii);
    figure
    subplot(2,1,1)
    scatter(meta_binall.LONadj,meta_binall.DEPTH_M, 20, hL(:,ic)./binLiters*1000,'filled')
    set(gca, 'ydir', 'rev'), title([class_labels3{ic} ' (m^{-3})'])
    m = prctile(hL(hL(:,ic)>0,ic)',95);
    if ~isnan(m)
        caxis([0 m]./binLiters*1000)
    end
    colorbar
    subplot(2,1,2)
    scatter(meta_binall.LONadj,meta_binall.DEPTH_M, 20, hS(:,ic)./binLiters*1000,'filled')
    m = prctile(hS(hS(:,ic)>0,ic)',95);
    set(gca, 'ydir', 'rev')
    if ~isnan(m)
        caxis([0 m]./binLiters*1000)
    end
    colorbar
    colormap parula
    print(['C:\work\OTZ\Cruises\Sarmiento2021\Stingray\' class_labels3{iii} '_sectionLG_SM'],'-dpng') 
%    pause
end
%%
figure(1), clf
set(gcf, 'position', [250 300 670 290])
h = hL+hS;
for ii = 13%1:length(icall)
    ic = icall(ii);
    figure(1), clf
    scatter(meta_binall.LONadj,meta_binall.DEPTH_M, 20, h(:,ic)./binLiters*1000,'filled')
    hold on
    set(gca, 'ydir', 'rev'), title(class_labels3{ic}) %title([class_labels3{ic} ' (m^{-3})'])
    m = prctile(h(h(:,ic)>0,ic)',95);
    if ~isnan(m)
        caxis([0 m]./binLiters*1000)
    end
    set(gca, 'ydir', 'rev')
    ylim([0 420]), xlim([-15.4 -14.65])
    ylabel('Depth (m)')
    ch = colorbar('location', 'east');
    set(ch, 'position', [.9 .3 .0318 .6])
    %title(ch, [class_labels3{ic} ' (m^{-3})'])
    title(ch, ' (m^{-3})')
    colormap parula
   % contour(xi, yi, Zgrid, [11.6 11.6], 'color', 'm', 'linewidth', 2)
   % print(['C:\work\OTZ\Cruises\Sarmiento2021\Stingray\' class_labels3{ic} '_section_isoT'],'-dpng') 
   % print(['C:\work\OTZ\Cruises\Sarmiento2021\Stingray\' class_labels3{ic} '_section'],'-dpng') 
    %pause
end
%%
%%
%[~,icall] = intersect(class_labels2, class2plot);
%watermassStr(:,1) = {'ML west' 'ML filament' 'ML eddy' 'unk' 'Subducted' 'Deep eddy' 'Deep filament' 'Transition ML to subduct'}
%class_labels3 = class_labels2;
%class_labels3(icall) = {'Appendicularians' 'Chaetognaths' 'Crustaceans' 'Lobate ctenophores' 'Doliolids' 'Marine snow1' 'Medusa' 'Ctenophores' 'Polychaetes' 'Radiozoans' 'Salps' 'Siphonphores' 'Marine snow'}
for ii = 1:length(icall)
    figure
    ic = icall(ii);
    plot(h(:,ic)./binLiters*1000, meta_binall.DEPTH_M, '-', 'color', [.9 .9 .9])
    hold on
    scatter(h(:,ic)./binLiters*1000, meta_binall.DEPTH_M, 20,wm_all, 'filled')
    colormap(SR1wm.watermasscol)
    th = title([class_labels3{ic} ' (m^{-3})']);
    set(gca, 'xAxisLocation','top')
    set(gca, 'ydir', 'rev', 'ylim', [0 400])
    ch = colorbar('location', 'east');
    caxis([.5 8.5])
    set(ch, 'ydir', 'rev', 'yticklabel', watermassStr(:,1), 'position', [.85 .12 .0318 .5], 'yaxislocation', 'left')
    print(['C:\work\OTZ\Cruises\Sarmiento2021\Stingray\' class_labels3{ic} '_profile'],'-dpng') 
end    

%%
figure(1), clf
set(gcf, 'position', [250 220 500 350])  %500 vs 670
dlm = [50 15 8 4 inf inf inf inf inf 10 50 18 1.5e4];
for ii = 1:length(icall)
    ic = icall(ii);
    figure(1)
  %  boxplot(h(:,ic)', wm_all', 'notch', 'on')
    boxplot(h(:,ic)', wm_all', 'ExtremeMode', 'compress', 'DataLim', [-inf dlm(ii)], 'notch', 'on')
    set(gca, 'xticklabel', watermassStr(:,1), 'XTickLabelRotation', 80,'fontsize', 12)
    %title(class_labels3(ic), 'interpreter', 'none')
    ylabel([class_labels3{ic} ' (m^{-3})']);
    %pause
    print(['C:\work\OTZ\Cruises\Sarmiento2021\Stingray\' class_labels2{ic} '_boxplot_watermass'],'-dpng')
end

%%
figure
set(gcf, 'position', [250 300 670 290])
scatter(sled_table.LONadj(isled), sled_table.DEPTH_M(isled), 10,sled_table.CTD_TEMPERATURE_DEG_C(isled))
set(gca, 'ydir', 'rev')
caxis([11 13])
ch = colorbar('location', 'westoutside')
title(ch, {'Temperature'; '(\circC)'})
ylim([0 420]), xlim([-15.4 -14.65])
set(gca, 'position', [.1 .11 .775 .8])
ylim([0 420]), xlim([-15.4 -14.65])
set(ch, 'position', [.91 .25 .0318 .6])
ylabel('Depth (m)')

%%
figure
set(gcf, 'position', [250 300 670 290])
scatter(sled_table.LONadj(isled), sled_table.DEPTH_M(isled), 10,log10((sled_table.FLUOROMETER_CHLOROPHYLL_RAW(isled)-50)*.0073))
set(gca, 'ydir', 'rev')
caxis(log10([.02 4]))
set(gca, 'position', [.1 .11 .775 .8])
ch = colorbar('location', 'westoutside')
title(ch, {'Chlorophyll'; '(mg m{^3})'})
ylim([0 420]), xlim([-15.4 -14.65])
set(ch, 'ytick', log10([.01 .1  1]))
set(ch, 'yticklabel', 10.^get(ch, 'ytick'))
set(ch, ' ''position', [.91 .25 .0318 .6])
ylabel('Depth (m)')
%%

figure
set(gcf, 'position', [250 300 670 290])
scatter(sled_table.LONadj(isled), sled_table.DEPTH_M(isled), 10,(sled_table.FLUOROMETER_BACKSCATTER_RAW(isled)-50)*1.684e-6)
set(gca, 'ydir', 'rev')
caxis([.0008 .001])
set(gca, 'position', [.1 .11 .775 .8])
ch = colorbar('location', 'westoutside')
title(ch, {'Backscattering'; '(m^{-1} sr^{-1})'})
ylim([0 420]), xlim([-15.4 -14.65])
set(ch, 'ytick', log10([.01 .1  1]))
set(ch, 'yticklabel', 10.^get(ch, 'ytick'))
set(ch, 'position', [.91 .25 .0318 .6])
ylabel('Depth (m)')

%%
figure
zall = repmat(SR1.z(:),1,43);
set(gcf, 'position', [250 300 670 290])
scatter(SR1.lonall(:), zall(:), 10,SR1.watermass(:))
set(gca, 'ydir', 'rev')
caxis([0.5 8.5])
set(gca, 'units', 'inches')
p = get(gca, 'position');
set(gcf, 'position', [250 300 800 290])
set(gca, 'position', p)
ylabel('Depth (m)')

ch = colorbar('location', 'east');
%ch = colorbar('location', 'southoutside');
title(ch, {'Water masses'})
ylim([0 420]), xlim([-15.4 -14.65])
set(ch, 'position', [.8 .25 .0318 .6])
set(ch, 'ytick', 1:8)
set(ch, 'yticklabel', watermassStr(:,1))
colormap(SR1wm.watermasscol)
set(ch, 'ydir', 'rev')
set(ch, 'yaxislocation', 'right')

%set(gca, 'units', 'inches')
%p = get(gca, 'position');
%set(gcf, 'position', [250 300 720 290])
%set(gca, 'position', p)
return

%OTZ_SG2105_18May2021_023
%20220128_ISIIS_SG2105_Jan2022_0
% salp seems decent at >0.95
% (cases with 2nd highest as radiolarian_colony seem to all be errors)
% none in small
%
% copoepod seems pretty good at >0.8
% copepod+euphausid seems pretty good at >0.8
% many in small
% [~,eind] = intersect(class_labels,{'marine_snow'});
% gind = s1 > .8 & ~(ismember(c2,eind) & s2>.001);
%
% grouped siphonophores (siphonophore,siphonophore_diphyid, siphonophore_sphaeronectes)
% looks pretty good at >0.5 for main folder (large ROIs)
% small ROIs, okay-ish at >0.8, when second is appendicularian, marine snow
%           or radiolarian_colony, etc usually wrong
% SMALL
% cind = find(startsWith(class_labels,'siphon'));
%[~,eind] = intersect(class_labels,{'appendicularian' 'marine_snow' 'radiolarian_colony' 'doliolid' 'detritus transparent' 'artifact' 'fecal_pellet_long'
% gind = s1 > .8 & ~(ismember(c2,eind) & s2>.001)
%
% chaetognath
% looks quite good for large and small at >0.8 (a few missed in small)
%
% ctenophore_lobate
% very good for large at >0.5
% 0 found in small (this profile)

% grouped other ctenophores
% [~,cind] = intersect(class_labels, {'ctenophore' 'ctenophore_cydippid'})
% looks okay at >0.85 for large and small
%
% doloiolid
% looks quite good for large and small at >0.98, YES 0.98
%
% medusa
% looks pretty good for large and small at >0.95 (maybe 0.9)
%
% polychaete (not very many)
% looks okay for large at >0.85
% maybe also 0.85 for small (a few missed)
%
% grouped {'acantharian_skinny_star_straight' 'radiolarian'}
% [~,cind] = intersect(class_labels, {'acantharian_skinny_star_straight' 'radiolarian'})
% [~,eind] = intersect(class_labels,{'marine_snow'});
% gind = s1 > .9 & ~(ismember(c2,eind) & s2>.001);
% (maybe > 0.85)
%
% radiolarian_colony
% ONLY for large (~none appear correct in small)
% [~,eind] = intersect(class_labels,{'marine_snow'});
% gind = s1 < .95 & ~(ismember(c2,eind) & s2>.001);
% 
% appendicularian
% ONLY for large (small way too many errors) > 0.95 (misses a few)
% [~,eind] = intersect(class_labels,{'detritus transparent' 'artifact'});
% gind = s1 < .95 & ~(ismember(c2,eind) & s2>.001);

