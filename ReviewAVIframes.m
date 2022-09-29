%fname = "E:\OTZ_EN688\Basler_avA2300-25gm\20220816T051400.368Z\Basler_avA2300-25gm-0053-20220816T061415.734Z.avi"
%fname = "G:\OTZ_EN688\Basler_avA2300-25gm\20220816T051400.368Z\Basler_avA2300-25gm-0053-20220816T061415.734Z"
%12 sec, siphonophore; E:\OTZ_EN688\Basler_avA2300-25gm\20220818T062813.921Z\Basler_avA2300-25gm-0076-20220818T075503.984Z.avi

%for ind = 1:3 %1041
%    rs = imageDatastore([char(fname) '_' num2str(ind)], 'ReadFcn', @readAVI);
%end
%global v2
%v2 = VideoReader(fname);
%rs = imageDatastore(fname, 'ReadFcn', @readAVI,'ReadSize',1041, 'FileExtensions', '.avi');
%%
%frame 40, nice tricho "G:\OTZ_EN688\Basler_avA2300-25gm\20220816T051400.368Z\Basler_avA2300-25gm-0053-20220816T061415.734Z.avi"
p = 'e:\OTZ_EN688\Basler_avA2300-25gm\';
[fname, p2] = uigetfile([p '\*.avi']);
tname = regexprep(fname, '.avi', ''); %for tiff output
%%
%v = VideoReader("G:\OTZ_EN688\Basler_avA2300-25gm\20220816T051400.368Z\Basler_avA2300-25gm-0053-20220816T061415.734Z.avi");
v = VideoReader([p2 fname]);
f = read(v);
f = squeeze(f(:,:,1,:));

n = 48;
a = 8; b = 6;
e = 100;
xi = repmat([size(f,2)*(0:a-1)+e],b,1)'; xi = xi(:);
yi = repmat([size(f,1)*(0:b-1)+e]',1,a)'; yi = yi(:);
%%
for ii = 1:ceil(size(f,3)/n)
    figure %('WindowState', 'maximized')
    s = ii*n;
    nn = (s-n++1):min([s size(f,3)]);
    imshow(imtile(f(:,:,nn),'gridsize', [6 8]))
    %text([2330*(0:7)+100], ones(1,8)*100,num2str([1:8]'))
    text(xi(1:length(nn)),yi(1:length(nn)),num2str(nn'))
    set(gcf,'WindowState','maximized')
    pause
end
%%
ni = 195; 
imwrite(f(:,:,ni),['C:\Users\ISIIS WHOI\Desktop\OTZ_EN688_highlights\' tname '_' num2str(ni,'%04d') '.tiff'],'tiff')
