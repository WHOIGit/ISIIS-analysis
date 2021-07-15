p = 'D:\NESLTER_EN657_ROI\EN657_13Oct2020_003\CNN_output\20210712_ISIIS_EN657_13Oct2020_003\';
f1 = 'part5';
fname = [f1 '_img_results.json'];

jj = fileread([p fname]);
jj = jsondecode(jj);


pout_base = ['D:\NESLTER_EN657_ROI\EN657_13Oct2020_003\' f1 filesep];
ptemp = 'run-data//ISIIS/';
ptemp2 = ['D:\NESLTER_EN657_ROI\EN657_13Oct2020_003\' f1 filesep];

srange = [.95 1; .9 .95; .85 .9; .8 .85];

for snum = 1:4
for cnum = 1:2
    ii = find(jj.output_classes==cnum & jj.output_scores(:,cnum+1) > srange(snum,1) & jj.output_scores(:,cnum+1) <= srange(snum,2));    
    pout = [pout_base jj.class_labels{cnum+1} num2str(snum) filesep];
    mkdir(pout) 
for cc = 1:length(ii)/2
    %fname = char(regexprep(jj.input_images(ii(cc)), ptemp, ptemp2));
    fname = jj.input_images(ii(cc));
    %[~,f,x] = fileparts(fname);
    
    movefile(char(fullfile(ptemp2, fname)), char(fullfile(pout,fname)))
    %if jj.output_scores(ii(cc),2)>.9
    %    movefile([pout f x],[pout 'plankton_90_100/' f x])
    %end
    %if jj.output_scores(ii(cc),2)>=.8 & jj.output_scores(ii(cc),2)<.9
    %    movefile([pout f x],[pout 'plankton_80_89/' f x])
    %end
end
end
end
