p = '\\sosiknas1\Stingray_data\OTZ_AR43\ROI\OTZ_AR43_15Mar2020_003\';
c = 'copepod';
clist = dir(p);
clist = clist([clist.isdir]);
clist = {clist.name};
clist(strmatch( '.',clist)) = [];

p2 = 'G:\OTZ_AR43_15Mar2020_003\';
load([p2 'image_meta_data'])
ilist = metaTable.pid;
ilist = regexprep(ilist, '.tiff', '');
ilist = regexprep(ilist,'OTZ_AR43_15Mar2020_003\', '');

for class_count = 1:length(clist)
    rlist = dir([p clist{class_count} filesep '*.png']);
    rlist = {rlist.name}';
    disp(class_count)
    meta_ind{class_count} = NaN(size(rlist));
    for count = 1:length(rlist)
        pos = strfind(rlist{count},'_');
        meta_ind{class_count}(count) = strmatch(rlist{count}(1:pos(8)-1), ilist, 'exact');
    end
    roi_list{class_count} = rlist;
end

frame_hist = histcounts(metaTable.DEPTH_M,0:10:1000);
for class_count = 1:length(clist)
    figure(1), clf
    h = histcounts(metaTable.DEPTH_M(meta_ind{class_count}),0:10:1000);
    bar(1:10:1000,h./frame_hist*100)
    set(gca, 'View', [90 90])
    title(['OTZ_AR43_15Mar2020_003: ' clist(class_count)], 'interpreter', 'none')
    xlabel('Depth (m)')
    ylabel('Occurence per 100 frames')
    set(gcf, 'position', [680 560 380 420])
    print(['D:\OTZ_AR43\ROIs\Profiles\' clist{class_count}], '-dpng')
end
