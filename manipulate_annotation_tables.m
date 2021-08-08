kemyreadtable = @(filename)readtable(filename, 'delimiter', ','); 
collection = 'NESLTER_EN657';
%collection = 'NESLTER_EN657_2'; 
%collection = 'NESLTER_EN657_3'; 
AnnotationTable = webread(['https://odp-annotate.whoi.edu/api/winning_annotations/' collection],weboptions('ContentReader', myreadtable));

date_time = char(AnnotationTable.roi_id(:));
date_time = date_time(:,32:49);

tows = unique(cellstr(date_time));
for ii = 1:length(tows)
    ind = strmatch(tows(ii), cellstr(date_time));
    AnnotationTable_in = AnnotationTable(ind,:);
    unqlabel = unique(AnnotationTable_in.label);
    image_id = AnnotationTable_in.roi_id;
    s1 = extractBefore(image_id, 51);
    frameNum = extractBefore(extractAfter(image_id, 50), '_');
    %image_id = strcat(s1,frameNum);
    frameNum = str2num(char(frameNum));
    image_id = strcat(s1(1),num2str((1:max(frameNum))'));
    AnnotationTable_wide = array2table(zeros(max(frameNum), length(unqlabel)));
    AnnotationTable_wide.Properties.VariableNames = unqlabel;
    for iii = 1:length(frameNum)
        AnnotationTable_wide.(AnnotationTable_in.label{iii})(frameNum(iii)) = AnnotationTable_wide.(AnnotationTable_in.label{iii})(frameNum(iii)) + 1 ;
    end
    AnnotationTable_wide.image_id = image_id;
    AnnotationTable_wide = movevars(AnnotationTable_wide, 'image_id', 'Before', 1);
    writetable(AnnotationTable_wide, ['\\sosiknas1\Stingray_data\AnnotationTables\' output_file num2str(ii) '.csv'])
end
   


return
%% This sums counts across each of the 4 tables
totals = table;
totals.collection(1:4) = {'NESLTER_EN657A'; 'NESLTER_EN657B'; 'NESLTER_EN657_2'; 'NESLTER_EN657_3'};
for ii = 1:length(unqlabel)
     t = count(AnnotationTable1A.label, unqlabel(ii));
     totals.(unqlabel{ii})(1) = sum(t);
     t = count(AnnotationTable1B.label, unqlabel(ii));
     totals.(unqlabel{ii})(2) = sum(t);

     t = count(AnnotationTable2.label, unqlabel(ii));
     totals.(unqlabel{ii})(3) = sum(t);
     
     t = count(AnnotationTable3.label, unqlabel(ii));
     totals.(unqlabel{ii})(4) = sum(t);
end



