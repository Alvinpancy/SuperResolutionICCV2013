clear
close all
clc

fid = fopen(fullfile(fullfile(pwd,'Database'),'TestList.txt'),'w+');
filelist = dir(fullfile(fullfile(fullfile(pwd,'Database'),'Test_GroundTruth'),['*' '.bmp']));
filenums = length(filelist);
filelist_sort(1:filenums,1) = struct('name',[]);
filesindex = zeros(filenums,1);
for i=1:filenums
    filename = filelist(i).name;
    partname = filename(1:strfind(filename, '.bmp')-1);
    filesindex(i) = str2double(partname);
end
[~, arr] = sort(filesindex);
for i=1:filenums
    filelist_sort(i).name = filelist(arr(i)).name;
end
filenumber = length(filelist_sort);
for j=1:filenumber
    fprintf(fid,'%d %s\n',j,filelist_sort(j).name);
end
fclose(fid);

Folder_Database = fullfile(pwd,'Database');
FileNameList = ReadFileNameList(fullfile(Folder_Database,'TestList.txt'));
File_numbers = length(FileNameList);
sf = 3;
sigma = 1.6;
hsize = ceil(3*sigma)*2+1;
kernel = fspecial('gaussian',hsize,sigma);
Folder_Test = fullfile(Folder_Database,'Test_Input');
if ~exist(Folder_Test,'dir')
    mkdir(Folder_Test);
end
folder_source = fullfile(fullfile(pwd,'Database'),'Test_GroundTruth')
for idx_file = 1:File_numbers
    picname = FileNameList{idx_file};
    partname = picname(1:end-4);
    img_hr = im2double(imread(fullfile(folder_source,picname)));
    img_lr = Gaussian_Bicub(img_hr,sf,sigma);
    fn_write = sprintf('%s.bmp',partname);
    imwrite(img_lr,fullfile(Folder_Test,fn_write));
end
