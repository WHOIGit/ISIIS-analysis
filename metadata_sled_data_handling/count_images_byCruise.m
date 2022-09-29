p = '\\sosiknas1\Stingray_data\Image_metadata\NESLTER_EN655\';
p = 'D:\Stingray_summary\NESLTER_EN668\';
f = dir([p 'NES*']);

n = NaN(length(f),1);
for ii = 1:length(f)
    disp(f(ii).name)
    load([p f(ii).name filesep 'Image_metadata'])
    n(ii) = size(metaTable,1);
end
sum(n)

%EN668 1666126
%EN661 1007278
%EN657 1049076 (1069916)
%EN655 97295 (107206)
%EN649 1735292
%EN644  2402648
%1666126 + 1007278 + 1049076 + 97295 + 1735292 + 2402648 = 7957715