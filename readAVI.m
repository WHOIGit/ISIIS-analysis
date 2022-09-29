function imgdata = readAVI(fname)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    global v2
    %v = VideoReader([fname 'avi']);
    imgdata = readFrame(v2);
    %v = videoreader([fns{1} '.avi']);
    %fns = split(fname, '__');
    %v = VideoReader([fns{1} '.avi']);
    %imgdata = read(v,str2num(fns{2}));
    %imgdata = imgdata(:,:,1);
    whos imgdata
end

