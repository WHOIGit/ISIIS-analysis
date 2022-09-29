T = readtable('\\vortex\share\nes-lter\Stingray\NESLTER_EN657_annotations.csv');
ii = find(strcmp('Jonathan_unlabeled', T.label));
% p = '\\vortex\share\nes-lter\Stingray\NESLTER_EN657_ROI\torun\';
% f = dir([p '/**/*.png']);
% n = regexprep({f.name}', '.png', '');
% [ia,ib] = ismember(T.roi_id(ii),n);
% if sum(ia) ~= length(ii)
%     disp('missing some ROIs')
%     keyboard
% end
% for cc = 1:length(ii)
%     movefile([f(ib(cc)).folder filesep f(ib(cc)).name], [f(ib(cc)).folder filesep T.label{ii((cc))} filesep f(ib(cc)).name])
% end

p = '\\vortex\share\nes-lter\Stingray\CNN_output\v3\ISIIS_SG2105_10Aug2021\';
f1 = 'EN657_13Oct2020_000';
fname = [f1 '_img_results.json'];

jj = fileread([p fname]);
jj = jsondecode(jj);
jj.output_classes = jj.output_classes+1; %change from 0 base for matlab

[~,ib] = ismember(T.roi_id(ii),regexprep(jj.input_images, '.png', ''));

new_annotations = table;
new_annotations.roi_id = jj.input_images(ib(find(ib)));
new_annotations.label = jj.class_labels(jj.output_classes(ib(find(ib))));

f1 = 'EN657_13Oct2020_001';
fname = [f1 '_img_results.json'];

jj = fileread([p fname]);
jj = jsondecode(jj);
jj.output_classes = jj.output_classes+1; %change from 0 base for matlab

[~,ib] = ismember(T.roi_id(ii),regexprep(jj.input_images, '.png', ''));

new_annotations2 = table;
new_annotations2.roi_id = jj.input_images(ib(find(ib)));
new_annotations2.label = jj.class_labels(jj.output_classes(ib(find(ib))));

f1 = 'EN657_14Oct2020_001';
fname = [f1 '_img_results.json'];

jj = fileread([p fname]);
jj = jsondecode(jj);
jj.output_classes = jj.output_classes+1; %change from 0 base for matlab

[~,ib] = ismember(T.roi_id(ii),regexprep(jj.input_images, '.png', ''));

new_annotations3 = table;
new_annotations3.roi_id = jj.input_images(ib(find(ib)));
new_annotations3.label = jj.class_labels(jj.output_classes(ib(find(ib))));

new_annotations = [new_annotations; new_annotations2; new_annotations3];