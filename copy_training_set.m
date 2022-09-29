%https://odp-annotate.whoi.edu/api/winning_annotations/SG2105
%T = readtable('D:\OTZ_SG2105\SG2105_annotations.csv', 'delimiter', ',');
T = readtable("C:\Users\ISIIS WHOI\Downloads\SG2105_annotations_10Aug2021.csv", 'delimiter', ',');
roipath = 'D:\OTZ_SG2105\ROIs_test\';
roilist = dir([roipath '**\*.png']);
roilist_name = {roilist.name};

nmax = 2000;
ind = strmatch('small', T.label);
T(ind,:) = [];
ind = strmatch('marine_snow', T.label);
ii = randperm(length(ind));
T(ind(ii(2001:end)),:) = []; %keep random nmax

outpath = 'D:\OTZ_SG2105\training_set_10Aug2021\';
classes = unique(T.label);
for cc = 1:length(classes)
    p = [outpath classes{cc}];
    if ~exist(p, 'dir')
        mkdir(p)
    end
end

for cc = 1:size(T,1)
    disp(cc)
    ii = strmatch(T.roi_id(cc), roilist_name);
    copyfile([roilist(ii).folder filesep roilist_name{ii}], [outpath T.label{cc} filesep roilist_name{ii}])
end
