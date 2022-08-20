%F = 'OTZ_AR43_15Mar2020_001';
%F = 'OTZ_AR43_13Mar2020_013';
p = '\\vortex\share\otz-data\AR43_Stingray\AR43_ROI_adj\features\';
Fall = dir([p '*.mat']);
max_width = 2330;
max_height = 1750;
max_pixel = [max_width max_height max_width max_height];
   
for ii = 1:length(Fall) %8, 15
    F = regexprep(Fall(ii).name, '.mat', '');
    disp(F)
    load(['\\vortex\share\otz-data\AR43_Stingray\AR43_ROI_adj\features\' F ])
    disp('loading class results')
    box_annotation = table;
    f = ['\\vortex\share\otz-data\AR43_Stingray\run-output\v3\AR43_20220308_0\' F '_img_results.json'];
    if exist(f, 'file')
        S = jsondecode(fileread(f));
        pid = regexprep(S.input_images, '.png', '');
        temp = split(pid,'_');
        frame = temp(:,8);
        box_annotation.frame = str2num(char(frame)); 
        [~,ib] = ismember(pid,Props.roiID);
        box_annotation = [box_annotation array2table((Props.BoundingBox(ib,:)-[.5 .5 0 0])./max_pixel, 'VariableNames', {'x', 'y','width', 'height'})];
        box_annotation.class = S.class_labels(S.output_classes+1);
    end
    %now get the small ones
    disp('loading class results for small ROIs')
        box_annotation2 = table;
    f = ['\\vortex\share\otz-data\AR43_Stingray\run-output\v3\AR43_20220308_0\' F filesep 'small_img_results.json'];
    if exist(f, 'file')
        S = jsondecode(fileread(f));
        pid = regexprep(S.input_images, '.png', '');
        temp = split(pid,'_');
        frame = temp(:,8);
        box_annotation2.frame = str2num(char(frame)); 
        [~,ib] = ismember(pid,Props.roiID);
        box_annotation2 = [box_annotation2 array2table((Props.BoundingBox(ib,:)-[.5 .5 0 0])./max_pixel, 'VariableNames', {'x', 'y','width', 'height'})];
        box_annotation2.class = S.class_labels(S.output_classes+1);
        end
    box_annotation = [box_annotation; box_annotation2];
    disp('saving bounding box output')
    writetable(box_annotation, ['\\vortex\share\otz-data\AR43_Stingray\AR43_ROI_adj\BoundingBox_csv\' F '.csv'])
    clear box_annotation
end