
%dirlist = dir('D:\OTZ_SG2105\ROIs_test\OTZ_SG2105_18*');
%indirbase = 'D:\OTZ_SG2105\ROIs_test\';
indirbase = 'D:\OTZ_SG2105\training_set_10Aug2021\';
dirlist = dir([indirbase '*']);
dirlist(strncmp({dirlist.name}, '.',1)) = [];
numdir = length(dirlist);
outdir = [indirbase 'features\'];

if ~exist(outdir, 'dir')
    mkdir(outdir)
end
for dircount = 8:numdir
    tdir = dirlist(dircount).name;
    indir = [indirbase tdir '\'];
    outfile = [outdir tdir];
    if 1 %~exist([outfile '.mat'], 'file')
        getROIfeatures(indir, outfile)
    else
        disp(['skipping ' outfile ', already done'])
    end
end

function [ ] = getROIfeatures(indir, outfile) %(indirbase, outdir, tdir)
num2view = 6;
se = strel('square',5); %consider making this larger 5*1.8 = 9
%indir = [indirbase tdir '\'];
%outfile = [outdir tdir];
%if ~exist([outfile '.mat'], 'file')
    
    roilist = dir([indir '\**\*.png']);
    if ~isempty(roilist)
        %%
       % disp(tdir)
        PFF =  imread([roilist(1).folder filesep roilist(1).name]);
        Edges = edge(PFF,'canny',[.2 .4],1.5); %used for 13March2020
        EdgesD = imclose(Edges, se);
        EdgesD(PFF<100) = 1;
        RFP = imfill(EdgesD,8,'holes');
        RFP2 = bwareaopen(RFP,100,8);
        Props = struct2table(regionprops(RFP2, 'area', 'boundingbox', 'MajorAxis', 'MinorAxis', 'Eccentricity', 'MaxFeretProperties', 'MinFeretProperties', 'Perimeter', 'Centroid', 'Orientation'), 'AsArray', 1);
        
        if size(Props,1) > 1
            [~, ia] = max(Props.Area);
            Props = Props(ia,:);
        end
        nanrow = Props; %make this in case needed later for ROIs with no blob
        for iii = 1:size(Props,2)
            temp = nanrow{1,iii};
            if iscell(temp)
                nanrow{1,iii} = {(cell2mat(nanrow{1,iii})*NaN)};
            else
                nanrow{1,iii} = temp*NaN;
            end
        end
        Props.roiID = roilist(1).name;
        Props = movevars(Props, 'roiID', 'before', 1);
        Props.meanPFF = mean(PFF(RFP2));
        Props.stdPFF = std(double(PFF(RFP2)));
        Props = repmat(Props,length(roilist),1);
        Props.roiID = char({roilist.name}');
        %%
        [~,f] = fileparts(outfile);
        for ii = 1:min([num2view length(roilist)])
            if ~rem(ii,1000)
                disp([f ': ' num2str(ii) ' of ' num2str(length(roilist))])
            end
            PFF =  imread([roilist(ii).folder filesep roilist(ii).name]);
            %PFF = imread("D:\OTZ_SG2105\ROIs_test\OTZ_SG2105_18May2021_002\Basler_avA2300-25gm__22955661__20210518_051646920_176_781_1263.png");
            Edges = edge(PFF,'canny',[.2 .4],1.5); %used for 13March2020
            EdgesD = imclose(Edges, se);
            EdgesD(PFF<100) = 1;
            RFP = imfill(EdgesD,8,'holes');
            RFP2 = bwareaopen(RFP,100,8);
            s = struct2table(regionprops(RFP2, 'area', 'boundingbox', 'MajorAxis', 'MinorAxis', 'Eccentricity', 'MaxFeretProperties', 'MinFeretProperties', 'Perimeter', 'Centroid', 'Orientation'), 'AsArray', 1);
            ia = 1;
            if size(s,1) == 0
                s = nanrow;
            end
            if size(s,1) > 1
                [~, ia] = max(s.Area);
                s = s(ia,:);
            end
            s.meanPFF = mean(PFF(RFP2)); %NOTE: this is all the blobs, not just the largest one
            s.stdPFF = std(double(PFF(RFP2)));
            Props(ii,2:end) = s;
            
            if 1 % plot edges and blobs with props
                phi = linspace(0,2*pi,50);
                cosphi = cos(phi);
                sinphi = sin(phi);
                figure(1), clf
                tiledlayout(2,2)
                nexttile, imshow(PFF)
                nexttile, imshow(EdgesD)
                nexttile, imshow(RFP2), hold on
                MaxFeretCoor = cell2mat(s.MaxFeretCoordinates);
                MinFeretCoor = cell2mat(s.MinFeretCoordinates);
                plot(MaxFeretCoor(:,1), MaxFeretCoor(:,2), 'r*-')
                plot(MinFeretCoor(:,1), MinFeretCoor(:,2), 'r*-')
                
                xbar = s.Centroid(1);
                ybar = s.Centroid(2);
                a = s.MajorAxisLength/2;
                b = s.MinorAxisLength/2;
                theta = pi*s.Orientation/180;
                R = [ cos(theta)   sin(theta); -sin(theta)   cos(theta)];
                xy = [a*cosphi; b*sinphi];
                xy = R*xy;
                x = xy(1,:) + xbar;
                y = xy(2,:) + ybar;
                plot(x,y,'m','LineWidth',2);
                
                nexttile, imshow(PFF), hold on
                [B,L] = bwboundaries(RFP2,'noholes');
                boundary = B{ia};
                plot(boundary(:,2), boundary(:,1),'r','LineWidth',.75);
                figure(2), clf, imshow(EdgesD)
             %   keyboard
                tpos = get(gcf, 'position'); 
                tpos2 = get(gca, 'position');
                txlim = xlim; tylim = ylim;
                perimeter_img = compute_perimeter_img(RFP2);
                dm = bwdist(perimeter_img); dm(~RFP2) = NaN;
                surf(dm), hold on, surf(-dm+1), shading flat
                zlim(zlim*4)
                set(gca, 'visible', 'off', 'zdir', 'rev')
                view([0 -90])
                set(gcf, 'position', tpos)
                set(gca, 'position', tpos2)
                xlim(txlim), ylim(tylim)
                pause
            end
        end
        
  %      save(outfile, 'Props')
    else
        disp(['skipping ' outfile ', no ROIs'])    
    end
end
