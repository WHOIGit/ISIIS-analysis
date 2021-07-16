%p = 'D:\NESLTER_EN657_ROI\EN657_13Oct2020_003\CNN_output\20210712_ISIIS_EN657_13Oct2020_003\';
%f1 = 'part5';
%fname = [f1 '_img_results.json'];

p = 'D:\NESLTER_EN657_ROI\CNN_output\';
f1 = 'EN657_14Oct2020_002'
fname = [f1 '_img_results.json'];

jj = fileread([p fname]);
jj = jsondecode(jj);

%pout_base = ['D:\NESLTER_EN657_ROI\EN657_13Oct2020_003\' f1 filesep];
%ptemp2 = ['D:\NESLTER_EN657_ROI\EN657_13Oct2020_003\' f1 filesep];

pout_base = ['\\vortex\share\nes-lter\Stingray\NESLTER_EN657_ROI\' f1 filesep];

srange = [.95 1; .9 .95; .85 .9; .8 .85];% .7 .8;.6 .7];

for snum = 1:4
    display(snum)
for cnum = 1:2
    display(jj.class_labels(cnum+1))
    ii = find(jj.output_classes==cnum & jj.output_scores(:,cnum+1) > srange(snum,1) & jj.output_scores(:,cnum+1) <= srange(snum,2));    
    pout = [pout_base jj.class_labels{cnum+1} num2str(snum) filesep];
    mkdir(pout) 
for cc = 1:length(ii) %(floor(length(ii)/2)+1):length(ii)
    %fname = jj.input_images(ii(cc));
    fname = regexprep(jj.input_images(ii(cc)),['/vortexfs1/share/nes-lter/Stingray/NESLTER_EN657_ROI/' f1 '/'], '');
    if exist(char(fullfile(pout_base, fname)), 'file')
        movefile(char(fullfile(pout_base, fname)), char(fullfile(pout,regexprep(fname, 'turbid/', ''))))
    end
end
end
end

%%
ii = find(jj.output_scores(:,1) < 1/3);    
    pout = [pout_base jj.class_labels{1} '_low_probability' filesep];
    mkdir(pout) 
for cc = 1:length(ii) %(floor(length(ii)/2)+1):length(ii)
%    fname = jj.input_images(ii(cc));
    fname = regexprep(jj.input_images(ii(cc)),['/vortexfs1/share/nes-lter/Stingray/NESLTER_EN657_ROI/' f1 '/'], '');
    if exist(char(fullfile(pout_base, fname)), 'file')
       movefile(char(fullfile(pout_base, fname)), char(fullfile(pout,regexprep(fname, 'turbid/', ''))))
    end
end
