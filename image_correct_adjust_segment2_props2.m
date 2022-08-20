%tdir = 'EN657_13Oct2020_001';
indirbase = 'f:\NESLTER_AT46\';
outdirbase = 'D:\NESLTER_AT46_ROI_adj\';
outdirfea = [outdirbase 'features' filesep];
if ~exist(outdirfea)
    mkdir(outdirfea)
end
dirlist = [dir([indirbase 'NESLTER_AT46_17Feb*'])];% dir([indirbase 'EN661_06Feb*'])];
parpool %(3)
parfor count = 1:length(dirlist)
    tdir = dirlist(count).name;
    indir = [indirbase tdir filesep];
    
    p = indir;
    outdir = [outdirbase tdir filesep];
    propsfile = [outdirfea tdir];
    if ~exist(outdir, 'dir')
        mkdir(outdir)
        mkdir([outdir filesep 'artifact'])
        mkdir([outdir filesep 'small'])
    end
    
    extract_saveROIs_fromDir(indir, outdir, propsfile)
end

function [] = extract_saveROIs_fromDir(p, outdir, propsfile)

t = dir([p '*.tiff']);
cmax = numel(t);
b = t(1).name;
b = b(1:49);
% if exist([outdir b '_props.mat'], 'file')
%     load([outdir b '_props'])
%     c = count+1;
%     cmax = numel(pid);
% else
setsize = 1000;
t = dir([p '*.tiff']);
cmax = numel(t);
b = t(1).name;
b = b(1:49);
r = cell(setsize,1);
pid = r;
%mnGrey = NaN(setsize,2);
c = 51;
%c = 21051;
w = 50;
g = 2.2;
a = uint8(NaN(1750,2330,w*2+1));
pid_stack = regexprep(cellstr(strcat(p, b, '_', num2str((c-w:c+w)'), '.tiff')), ' ', '');
%for counts = 1:w*2+1, disp(c-w-1+counts), a(:,:,counts) = imread([pid_stack{counts}]); end
for counts = 1:w*2+1, a(:,:,counts) = imread([pid_stack{counts}]); end

disp(pid_stack(end))
%%
for count = (w*2+2):cmax
    pid = pid_stack{w+1};
    P = double(squeeze(a(:,:,w+1)));
    PM = squeeze(mean(a(:,:,[1:w-1,w+1:end]),3));
    PG = mean(PM(:));
    
    CF = PM./PG; %or is it really PG./PM as in pseudo-code??
    %CF = PG./PM;
    CF(CF>1.75) = 1.75;
    
    %PC = double(P).*CF;
    PC = double(P)./CF;
    PCN = PC./max(PC(:));
    PCG = PCN.^g;
    PCGm = mean(PCG(:));
    PCR = PCG*.812/PCGm;
    PCR(PCR<0) = 0;
    PCR(PCR>1) = 1;
    PFF = PCR*255;
    %mnGrey(count,2) = mean(PFF(:));
    
    Edges = edge(PFF,'canny',[.2 .4],1.5); %used for 13March2020
    se = strel('square',5); %consider making this larger 5*1.8 = 9
    %EdgesD = imdilate(Edges, se);
    EdgesD = imclose(Edges, se);
    %RFP = imfill(EdgesD,8);
    EdgesD(PFF<100) = 1;
    RFP = imfill(EdgesD,8,'holes');
    %RFP = bwareaopen(RFP,50,8);
    %imshow(EdgesD)
    
    %disp(count)
    
    lg_area1 = 2000;
    lg_area2 = 400;
    RFP2 = bwareaopen(RFP,100,8);
    
    r = struct2table(regionprops(RFP2, 'area', 'boundingbox', 'MajorAxis', 'MinorAxis', 'Eccentricity', 'MaxFeretProperties', 'MinFeretProperties', 'Perimeter', 'Centroid', 'Orientation'), 'AsArray', 1);
    
    if ~exist('Props', 'var')
        Props = r(1,:);
        Props.meanPFF = NaN;
        Props.stdPFF = NaN;
        Props.roiID = NaN;
        nanrow = Props; %make this in case needed later for ROIs with no blob
        for iii = 1:size(Props,2)
            temp = nanrow{1,iii};
            if iscell(temp)
                nanrow{1,iii} = {(cell2mat(nanrow{1,iii})*NaN)};
            else
                nanrow{1,iii} = temp*NaN;
            end
        end
        %nanrow.roiID = 'none';
        Props(1,:) = []; %now empty table with correct variables names and types
    end
    
    if 1 %output roi images
        %ind = find([r{count}.Area] >= lg_area1);
        ind = find(r.Area >= lg_area1);
        for ii = 1:length(ind)
            %bb = r{count}(ind(ii)).BoundingBox;
            bb = r.BoundingBox(ind(ii),:);
            bb(1:2) = bb(1:2) - 20;
            bb(3:4) = bb(3:4) + 20*2;
            bb(bb<0) = 0;
            img = imcrop(PFF,bb);
            blob = imcrop(RFP2,bb);
            [~,fout] = fileparts(pid_stack{w+1});
            fout = [fout '_' num2str(floor(bb(1))) '_' num2str(floor(bb(2)))];
            % r{count}(ind(ii)).pid = fout;
            gstat = [numel(find(img==255)) numel(img) prctile(double(img(:)),5)];
            %r{count}(ind(ii)).gstat = gstat;
            if 1
                if gstat(:,1)./gstat(:,2) > .03 & gstat(:,3)>150
                    imwrite(uint8(img), [outdir '\artifact\' fout '.png'])
                else
                    imwrite(uint8(img), [outdir fout '.png'])
                end
            end
            s = r(ind(ii),:);
            s.meanPFF = mean(img(blob));
            s.stdPFF = std(img(blob));
            s.roiID = {fout};
            Props = [Props; s];
        end
        %     ind = find([r{count}.Area] < lg_area1 & [r{count}.Area] >= lg_area2);
        ind = find([r.Area] < lg_area1 & [r.Area] >= lg_area2); %case for not saving props
        for ii = 1:length(ind)
            %bb = r{count}(ind(ii)).BoundingBox;
            bb = r.BoundingBox(ind(ii),:);
            bb(1:2) = bb(1:2) - 20;
            bb(3:4) = bb(3:4) + 20*2;
            bb(bb<0) = 0;
            img = imcrop(PFF, bb);
            blob = imcrop(RFP2,bb);
            [~,fout] = fileparts(pid_stack{w+1});
            fout = [fout '_' num2str(floor(bb(1))) '_' num2str(floor(bb(2)))];
            imwrite(uint8(img), [outdir '\small\' fout '.png'])
            s = r(ind(ii),:);
            s.meanPFF = mean(img(blob));
            s.stdPFF = std(img(blob));
            s.roiID = {fout};
            Props = [Props; s];
        end
    end
    
    
    a(:,:,1:end-1) = a(:,:,2:end);
  
    pid_stack(1:end-1) = pid_stack(2:end);
    pid_stack{end} = [p b '_' num2str(count) '.tiff'];
    disp(['new image end of stack: ' pid_stack{end}])
    try
        a(:,:,end) = imread(pid_stack{end});
    catch ME
        if (strcmp(ME.identifier,'imageio:tiffmexutils:libtiffError'))
            disp(['Bad tiff file: ', 'pid'])
            a(:,:,end) = squeeze(mean(a(:,:,1:end-1),3)); %fill with mean in case of bad image file
        end
    end
end

Props = movevars(Props,'roiID', 'before', 1);
save(propsfile, 'Props')

end

