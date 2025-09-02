indirbase1 = '\\vast\proj\nes-lter\Stingray\data\NESLTER_AR88\Basler_a2a2840-14gmBAS\';
indirhr = dir(indirbase1); indirhr = {indirhr([indirhr.isdir]).name};
indirhr(ismember(indirhr,{'.' '..' 'skip'})) = [];
%outdirbase = 'c:\work\Stingray\data\NESLTER_AR88\Basler_a2a2840-14gmBAS\';
%outdirbase = '\\sosiknas2\Stingray_data\Stingray_products\ROI\';
outdirbase = '\\sosiknas2\Stingray_products\ROIs\NESLTER_AR88\Basler_a2a2840-14gmBAS\';
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

%indirhr = indirhr(1:10:end);
%indirhr = indirhr(99:-10:2);
numhrs = length(indirhr);
%parpool(2)
%DONE hcount = 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,...
% 40,41,42,43,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,97,98,99
%in proc  (60 is empty? - 20250427T125758.030Z; 23 empty?; 44 empty)
for hcount = 1:numhrs % %80:80 %99:99 %numhrs
    disp(hcount)
    outdir = strcat(outdirbase, indirhr{hcount}, filesep);
    if ~exist(outdir,'dir')
        mkdir(outdir)
    end
    flist = dir([indirbase1 indirhr{hcount} filesep '*.avi']);
    temp_prop_name = [prop_out indirhr{hcount} '.mat'];
  %%
    if exist(temp_prop_name,'file')
        load(temp_prop_name)
        fcount1 = fcount+1;
    else
        fcount1 = 1;
        Prop = Prop_empty;
    end
    %%
    for fcount = fcount1:length(flist) % 
    %for fcount = 7:length(flist) %
        filename = strrep(flist(fcount).name, '.avi', '');
        disp(filename)
        indir = [indirbase1 indirhr{hcount} filesep];
        
        v = VideoReader(fullfile(indir, strcat(filename, ".avi")));
        f = read(v);
        f = squeeze(f(:,:,1,:));

        PM = single(median(f,3));
        imref = imref2d(size(PM));
        [optimizer,metric] = imregconfig('monomodal');
        %
        for iif = 1:size(f,3)
            f1 = single(f(:,:,iif));
            tform = imregtform(PM(2200:end,2200:end),f1(2200:end,2200:end),'translation',optimizer,metric);
            PM_reg = imwarp(PM, tform, "OutputView",imref);
            t = (PM_reg==0); PM_reg(t) = PM(t); 
            PFF = abs(f1-PM_reg);
  %          disp(iif)

            %Edges = edge(PFF,'canny',[0 .25],1.5);
            Edges = edge(PFF,'canny',[.1 .25],.9);
            %Edges = edge(PFF,'canny',[0 .7],2);
            se = strel('square',4);
            EdgesD = imclose(Edges, se);
            EdgesD(PFF>100) = 1;
            RFP = imfill(EdgesD,4,'holes');

            lg_area1 = 350;
            RFP2 = bwareaopen(RFP,lg_area1,4); %8-->4
            %if 0
            %    tiledlayout(1,4,'TileSpacing','none')
            %    nexttile, imshow(f1), caxis([0 255])
            %    nexttile, imshow(PFF), caxis([0 100])
            %    nexttile, imshow(EdgesD)
            %    nexttile, imshow(RFP2)
            %    pause
            %end
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
        clear f
        save([prop_out indirhr{hcount} '.mat'], 'Prop', 'fcount')
    end
    Prop(1,:) = [];
    writetable(Prop,[prop_out indirhr{hcount} '.csv']);
    %%
end

