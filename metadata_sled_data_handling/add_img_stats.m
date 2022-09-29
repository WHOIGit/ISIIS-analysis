dd = dir('C:\work\Stingray_summary\OTZ_SG2105\OTZ_SG*\*.mat');
for ii = 1:length(dd)
    load([dd(ii).folder filesep dd(ii).name]);
    sstr = num2str(size(metaTable,1));
    for iii = 1:size(metaTable,1)
        if ~rem(iii,100)
            disp([num2str(iii) ' of ' sstr])
        end
        img = imread(metaTable.pid{iii});
        metaTable.img_mean(iii) = mean(img(:));
        metaTable.img_median(iii) = median(img(:));
        metaTable.img_5prctile(iii) = prctile(img(:),5);
        metaTable.img_10prctile(iii) = prctile(img(:),10);
    end
    save([dd(ii).folder filesep dd(ii).name], 'metaTable')
end

