indirbase1 = '\\vast\proj\nes-lter\Stingray\data\NESLTER_AR88\Basler_a2a2840-14gmBAS\';
indirhr = dir(indirbase1); indirhr = {indirhr([indirhr.isdir]).name};
indirhr(ismember(indirhr,{'.' '..'})) = [];
outdirbase = 'c:\work\Stingray\data\NESLTER_AR88\Basler_a2a2840-14gmBAS\';
prop_out = [outdirbase 'features' filesep];
if ~exist(prop_out, 'dir')
    mkdir(prop_out)
end
%v = VideoReader("\\vast\proj\nes-lter\Stingray\data\NESLTER_AR88\Basler_a2a2840-14gmBAS\20250429T004111.917Z\Basler_a2a2840-14gmBAS-078-20250429T005156.522Z.avi");
%filename = 'Basler_a2a2840-14gmBAS-289-20250425T001115.598Z';
%"\\vast\proj\nes-lter\Stingray\data\NESLTER_AR88\Basler_a2a2840-14gmBAS\20250424T234055.539Z\Basler_a2a2840-14gmBAS-289-20250425T001115.598Z.avi");

regionpropsList = {'area', 'boundingbox', 'MajorAxis', 'MinorAxis', 'Eccentricity', 'MaxFeretProperties', 'MinFeretProperties', 'Perimeter', 'Centroid', 'Orientation'};
Prop_empty = struct2table(regionprops([1 0; 0 0], regionpropsList), 'AsArray', 1);
Prop_empty.roiID = {'junk'};
Prop_empty.mn_grayscale = 0;
Prop_empty.std_grayscale = 0;
Prop_empty = movevars(Prop_empty, 'roiID', Before=1);

for hcount = 1:1 %:5:length(indirhr)
    outdir = strcat(outdirbase, indirhr{hcount}, filesep);
    if ~exist(outdir,'dir')
        mkdir(outdir)
    end
    flist = dir([indirbase1 indirhr{hcount} filesep '*.avi']);
    Prop = Prop_empty;
    for fcount = 1:2 %length(flist)
        filename = strrep(flist(fcount).name, '.avi', '');
        disp(filename)
        indir = [indirbase1 indirhr{hcount} filesep];
        %indir = '\\vast\proj\nes-lter\Stingray\data\NESLTER_AR88\Basler_a2a2840-14gmBAS\20250426T132707.035Z\';
        %filename = 'Basler_a2a2840-14gmBAS-170-20250426T135804.971Z';

        v = VideoReader(fullfile(indir, strcat(filename, ".avi")));
        f = read(v);
        f = squeeze(f(:,:,1,:));

        PM = single(median(f,3));
        imref = imref2d(size(PM));
        [optimizer,metric] = imregconfig('monomodal');
        %%
        for iif = 1:size(f,3)
            f1 = single(f(:,:,iif));
            tform = imregtform(PM(2200:end,2200:end),f1(2200:end,2200:end),'translation',optimizer,metric);
            PM_reg = imwarp(PM, tform, "OutputView",imref);
            t = (PM_reg==0); PM_reg(t) = PM(t); clear t
            PFF = abs(f1-PM_reg);
            disp(iif)

            %Edges = edge(PFF,'canny',[0 .25],1.5);
            Edges = edge(PFF,'canny',[.1 .25],.9);
            %Edges = edge(PFF,'canny',[0 .7],2);
            se = strel('square',4);
            EdgesD = imclose(Edges, se);
            EdgesD(PFF>100) = 1;
            RFP = imfill(EdgesD,4,'holes');

            lg_area1 = 350;
            RFP2 = bwareaopen(RFP,lg_area1,4); %8-->4
            if 1
                tiledlayout(1,4,'TileSpacing','none')
                nexttile, imshow(f1), caxis([0 255])
                %subplot(2,2,1), imshow(f1), caxis([0 255])
                nexttile, imshow(PFF), caxis([0 100])
                nexttile, imshow(EdgesD)
                nexttile, imshow(RFP2)
                pause
            end
            r = struct2table(regionprops(RFP2, 'area', 'boundingbox', 'MajorAxis', 'MinorAxis', 'Eccentricity', 'MaxFeretProperties', 'MinFeretProperties', 'Perimeter', 'Centroid', 'Orientation'), 'AsArray', 1);

            for ii = 1:size(r,1)
                %bb = r{count}(ind(ii)).BoundingBox;
                bb = r.BoundingBox(ii,:);
                bb(1:2) = bb(1:2) - 5; % 20;
                bb(3:4) = bb(3:4) + 5*2;  %20*2;
                bb(bb<0) = 0;
                img = imcrop(f(:,:,iif),bb);
                blob = imcrop(RFP2,bb);
                fout = [filename '_' num2str(iif,'%03.f') '_' num2str(floor(bb(1))) '_' num2str(floor(bb(2)))];
                imwrite(uint8(img), [outdir fout '.png'])
                s = r(ii,:);
                s.mn_grayscale = mean(img(blob));
                s.std_grayscale = std(single(img(blob)));
                s.roiID = {fout};
                Prop = [Prop; s];
            end
        end
    end
    Prop(1,:) = [];
    writetable(Prop,[prop_out filename]);
end

%%
tic, tform = imregtform(PM,f1,'translation',optimizer,metric); toc
tic, tform2 = imregtform(PM(2000:end,2000:end),f1(2000:end,2000:end),'translation',optimizer,metric); toc
tic, tform3 = imrtic, tform4 = imregtform(PM(2200:end,2200:end),f1(2200:end,2200:end),'translation',optimizer,metric); toc
tic, tform4 = imregtform(PM(2200:end,2200:end),f1(2200:end,2200:end),'translation',optimizer,metric); toc

imref = imref2d(size(f1));
PM_reg1 = imwarp(PM, tform, "OutputView",imref);
PM_reg2 = imwarp(PM, tform2, "OutputView",imref);
PM_reg3 = imwarp(PM, tform3, "OutputView",imref);
PM_reg4 = imwarp(PM, tform4, "OutputView",imref);