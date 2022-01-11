%从训练集的所有图片中提取出用于聚类的patch，权衡时间与效率，丢弃比较光滑的patch，加快速度。
clear
close all
clc

%把TrainList.txt里面存储的文件名提取出来
arr_filelist = ReadFileNameList(fullfile(fullfile(pwd,'Database'),'TrainList.txt'));
num_file = length(arr_filelist);

%patch size
patchsize = 7;
patchsize_half = (patchsize-1)/2;
featurelength_lr = 45;

% 去掉四个角的矩形
patch_to_vector_exclude_corner = [2:6 8:42 44:48];
thd = 0.05;
num_smoothgradient = 200;

%sf 代表scaling factor
sf = 3;
%hr的中间特征部分
featurelength_hr = (sf * 3)^2;
sigma = 1.6;

%创建文件夹
folderposition = fullfile(pwd,'Position');
if ~exist(folderposition,'dir')
      mkdir(folderposition)
end


for idx_file = 1:num_file
    picname = arr_filelist{idx_file};
    partname = picname(1:end-4);
    filename = sprintf('%s_position.mat',partname);
    positonfile = fullfile(folderposition,filename);
     %检查文件是否存在，如果存在就直接跳过
    if exist(positonfile,'file')
       fprintf('%d skip %s\n',idx_file, positonfile);
        continue
    end
    fid = fopen(positonfile,'w+');
    fclose(fid);   
    fprintf('%d extracting %s\n',idx_file, positonfile);
    %从Train文件夹中读取图片，并转化为灰度图。
    img_gray = rgb2gray(imread(fullfile(fullfile(fullfile(pwd,'Database'),'Train'),picname)));
    [~, table_position_center] = GenerateFeatureAndPosition(img_gray,sf,sigma);
    save(positonfile,'table_position_center');
end
