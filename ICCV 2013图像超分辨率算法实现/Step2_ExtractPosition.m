%��ѵ����������ͼƬ����ȡ�����ھ����patch��Ȩ��ʱ����Ч�ʣ������ȽϹ⻬��patch���ӿ��ٶȡ�
clear
close all
clc

%��TrainList.txt����洢���ļ�����ȡ����
arr_filelist = ReadFileNameList(fullfile(fullfile(pwd,'Database'),'TrainList.txt'));
num_file = length(arr_filelist);

%patch size
patchsize = 7;
patchsize_half = (patchsize-1)/2;
featurelength_lr = 45;

% ȥ���ĸ��ǵľ���
patch_to_vector_exclude_corner = [2:6 8:42 44:48];
thd = 0.05;
num_smoothgradient = 200;

%sf ����scaling factor
sf = 3;
%hr���м���������
featurelength_hr = (sf * 3)^2;
sigma = 1.6;

%�����ļ���
folderposition = fullfile(pwd,'Position');
if ~exist(folderposition,'dir')
      mkdir(folderposition)
end


for idx_file = 1:num_file
    picname = arr_filelist{idx_file};
    partname = picname(1:end-4);
    filename = sprintf('%s_position.mat',partname);
    positonfile = fullfile(folderposition,filename);
     %����ļ��Ƿ���ڣ�������ھ�ֱ������
    if exist(positonfile,'file')
       fprintf('%d skip %s\n',idx_file, positonfile);
        continue
    end
    fid = fopen(positonfile,'w+');
    fclose(fid);   
    fprintf('%d extracting %s\n',idx_file, positonfile);
    %��Train�ļ����ж�ȡͼƬ����ת��Ϊ�Ҷ�ͼ��
    img_gray = rgb2gray(imread(fullfile(fullfile(fullfile(pwd,'Database'),'Train'),picname)));
    [~, table_position_center] = GenerateFeatureAndPosition(img_gray,sf,sigma);
    save(positonfile,'table_position_center');
end
