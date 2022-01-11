% ����ѵ����ͼƬ����������
clear
close all
clc

%��TrainList.txt�ļ����ڼ�¼�ļ����б�
fid = fopen(fullfile(fullfile(pwd,'Database'),'TrainList.txt'),'w+');
filelist = dir(fullfile(fullfile(fullfile(pwd,'Database'),'Train'),['*' '.jpg']));
filenums = length(filelist);
filelist_sort(1:filenums,1) = struct('name',[]);
filesindex = zeros(filenums,1);
for i=1:filenums
    filename = filelist(i).name;
    partname = filename(1:strfind(filename, '.jpg')-1);
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
