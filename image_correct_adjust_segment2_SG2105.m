%p = '\\sosiknas1\Stingray_data\EN649\EN649_02Feb2020_028\';
%b = 'Basler_avA2300-25gm__22955661__20200202_183926409';
%outdir = '\\sosiknas1\Stingray_data\EN649\ROIs\EN649_02Feb2020_028\';

    tdir = 'OTZ_SG2105_14May2021_001';
    outdir = ['D:\OTZ_SG2105\ROIs_test\' tdir '\'];
    p = ['g:\OTZ_SG2105\' tdir '\'];
    
if ~exist(outdir, 'dir')
    mkdir(outdir)
    mkdir([outdir filesep 'artifact'])
    mkdir([outdir filesep 'small'])
end

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
%r = cell(setsize,1);
%pid = r;
%mnGrey = NaN(setsize,2);
c = 51;
c = 21051;
% end
w = 50;
g = 2.2;
a = uint8(NaN(1750,2330,w*2+1));
%pid_stack = cell(w*2+1,1);
%pid_stack{end} = [p b '_' num2str(c+count) '.tiff'];
pid_stack = regexprep(cellstr(strcat(p, b, '_', num2str((c-w:c+w)'), '.tiff')), ' ', '');
for counts = 1:w*2+1, disp(c-w-1+counts), a(:,:,counts) = imread([pid_stack{counts}]); end
%for count = c-w:c+w, disp(count-c+w+1), pid_stack{count-c+w+1} = [p b '_' num2str(count) '.tiff']; a(:,:,count-c+w+1) = imread(pid{count-c+w+1}); end
%disp([p b '_' num2str(count) '.tiff'])
disp(pid_stack(end))
%%
lastonesofar = 0;
%c = 51;
for setnum = 1:ceil(cmax/setsize)
    %for count = c:cmax-w-1  %36169
    r = cell(setsize,1);
    pid = r;
    r = cell(1,1); %Temp for SG2105 not saving stats
    mnGrey = NaN(setsize,2);
    for count = 1:setsize  %36169
        if lastonesofar < cmax
            %f = [p b '_' num2str(count) '.tiff'];
            pid{count} = pid_stack{w+1};
            P = double(squeeze(a(:,:,w+1)));
            mnGrey(count,1) = mean(P(:));
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
            mnGrey(count,2) = mean(PFF(:));
            
            %Edges = edge(PFF,'canny',[.2 .6],1.5); %.2 .6
            %Edges = edge(PFF,'canny',[.1 .3],1.5); %used for 12March2020
            Edges = edge(PFF,'canny',[.2 .4],1.5); %used for 13March2020
            se = strel('square',5); %consider making this larger 5*1.8 = 9
            %EdgesD = imdilate(Edges, se);
            EdgesD = imclose(Edges, se);
            %RFP = imfill(EdgesD,8);
            EdgesD(PFF<100) = 1;
            RFP = imfill(EdgesD,8,'holes');
            %RFP = bwareaopen(RFP,50,8);
            %imshow(EdgesD)
            
            disp(count)
            
            lg_area1 = 2000;
            lg_area2 = 400;
            RFP2 = bwareaopen(RFP,100,8);
            %r{count} = regionprops(RFP2, 'area', 'boundingbox', 'MajorAxis', 'MinorAxis', 'Eccentricity', 'MaxFeretProperties', 'MinFeretProperties', 'Perimeter');
            r{1} = regionprops(RFP2, 'area', 'boundingbox');
            if 1 %output roi images
                %ind = find([r{count}.Area] >= lg_area1);
                ind = find([r{1}.Area] >= lg_area1);
                for ii = 1:length(ind)
                    %bb = r{count}(ind(ii)).BoundingBox;
                    bb = r{1}(ind(ii)).BoundingBox;
                    bb(1:2) = bb(1:2) - 20;
                    bb(3:4) = bb(3:4) + 20*2;
                    bb(bb<0) = 0;
                    img = imcrop(PFF, bb);
                    [~,fout] = fileparts(pid_stack{w+1});
                    fout = [fout '_' num2str(floor(bb(1))) '_' num2str(floor(bb(2)))];
                    %r{count}(ind(ii)).pid = fout;
                    gstat = [numel(find(img==255)) numel(img) prctile(double(img(:)),5)];
                    %r{count}(ind(ii)).gstat = gstat;
                    if 1 %write images
                        if gstat(:,1)./gstat(:,2) > .03 & gstat(:,3)>150
                            %imwrite(uint8(img), [outdir '\artifact\' fout '.png'])
                        else
                            imwrite(uint8(img), [outdir fout '.png'])
                        end
                    end
                end
                %       ind = find([r{count}.Area] < lg_area1 & [r{count}.Area] >= lg_area2);
                %       for ii = 1:length(ind)
                %           bb = r{count}(ind(ii)).BoundingBox;
                %           bb(1:2) = bb(1:2) - 20;
                %           bb(3:4) = bb(3:4) + 20*2;
                %           bb(bb<0) = 0;
                %           img = imcrop(PFF, bb);
                %           [~,fout] = fileparts(pid_stack{w+1});
                %           fout = [fout '_' num2str(floor(bb(1))) '_' num2str(floor(bb(2)))];
                %           r{count}(ind(ii)).pid = fout;
                %           gstat = [numel(find(img==255)) numel(img) prctile(double(img(:)),5)];
                %           %if gstat(:,1)./gstat(:,2) > .03 & gstat(:,3)>150
                %           imwrite(uint8(img), [outdir '\small\' fout '.png'])
                %           %else
                %           %  imwrite(uint8(img), [outdir fout '.png'])
                %           %end
                %       end
            end
            
            if 0
                pauseflag = 0;
                [B,L] = bwboundaries(RFP2,'noholes');
                figure(3), imshow(L), colormap jet, caxis auto
                figure(2), clf
                imshow(PFF), caxis auto, hold on
                for k=1:length(B)
                    boundary = B{k};
                    %cidx = mod(k,length(colors))+1;
                    %plot(boundary(:,2), boundary(:,1),colors(cidx),'LineWidth',.75);
                    %  plot(boundary(:,2), boundary(:,1),colors(ind(k)),'LineWidth',.75);
                    if r{count}(k).Area > lg_area1
                        plot(boundary(:,2), boundary(:,1),'b','LineWidth',.75);
                        pauseflag = 1;
                    else
                        plot(boundary(:,2), boundary(:,1),'r','LineWidth',.75);
                    end
                end
                if pauseflag
                    pause(.1)
                else
                    pause(.1)
                end
                pauseflag = 0;
            end
            a(:,:,1:end-1) = a(:,:,2:end);
            % f = [p b '_' num2str(count+1, '%04.0f') '.tiff'];
            % f = [p b '_' num2str(count+c-w) '.tiff'];
            pid_stack(1:end-1) = pid_stack(2:end);
            %pid_stack{end} = [p b '_' num2str(count+w+1) '.tiff'];
            lastonesofar = c+count+w+setsize*(setnum-1);
            pid_stack{end} = [p b '_' num2str(lastonesofar) '.tiff'];
            disp(['new image end of stack: ' pid_stack{end}])
            try
                a(:,:,end) = imread(pid_stack{end});
            catch ME
                if (strcmp(ME.identifier,'imageio:tiffmexutils:libtiffError'))
                    disp(['Bad tiff file: ', 'pid'])
                    a(:,:,end) = squeeze(mean(a(:,:,1:end-1),3)); %fill with mean in case of bad image file
                end
            end
            %if ~rem(count,1000)
            %    save([outdir b '_props'], 'r', 'pid', 'mnGrey', 'tdir', 'count', 'b', '-v7.3')
            %end
        end
end
%    save([outdir b '_props' num2str(setnum,'%03.0f')], 'r', 'pid', 'mnGrey', 'tdir', 'count', 'b', '-v7.3')
end

%save([outdir b '_props'], 'r', 'pid', 'mnGrey', 'tdir', 'count', 'b', '-v7.3')