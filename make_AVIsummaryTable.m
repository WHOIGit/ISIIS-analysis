avidrive = 'G:\';
avibase = 'NESLTER_EN687';
f = dir([avidrive avibase '\**\*.avi']);

aviTable = table;
aviTable.path = regexprep({f.folder}', avidrive, '');
aviTable.file = {f.name}';

dt = char(aviTable.file);
aviTable.datetime = datetime(dt(:,26:45), 'inputFormat', 'yyyyMMdd''T''HHmmss.SSS''Z', 'timezone', 'UTC');

%%
for c = 1:size(aviTable,1)
    disp(c)
    v = VideoReader([avidrive aviTable.path{c} filesep aviTable.file{c}]);
    aviTable.NumFrames(c) = v.NumFrames;
    aviTable.FrameRate(c) = v.FrameRate;
    aviTable.Duration(c) = v.Duration;
    %save('D:\Stingray_summary\NESLTER_EN687\g23_test', 'aviTable', 'v')
    f1 = read(v1);
    f1 = squeeze(f1(:,:,1,:));

end

function target = (target);
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
        RFP2 = bwareaopen(RFP,100,8);
    r = struct2table(regionprops(RFP2, 'area', 'boundingbox', 'MajorAxis', 'MinorAxis', 'Eccentricity', 'MaxFeretProperties', 'MinFeretProperties', 'Perimeter', 'Centroid', 'Orientation'), 'AsArray', 1);

    end
