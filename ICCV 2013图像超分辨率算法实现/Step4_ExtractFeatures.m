%��ȡ��ѵ��ʹ�õ�patch������
clear
close all
clc

FileNameList = ReadFileNameList(fullfile(fullfile(pwd,'Database'),'TrainList.txt'));
patch_length = 45;
sf = 3;
sigma = 1.6;

Folder_Feature = fullfile(pwd,'Feature');
if ~exist(Folder_Feature,'dir')
    mkdir(Folder_Feature)
end

%��ȡ�� record_patch_for_cluster
Folder_Cluster = fullfile(pwd,'Cluster');
file_record = sprintf('record_patch_for_cluster_sf%d_sigma%.1f.mat',sf,sigma);
load(fullfile(Folder_Cluster,file_record),'record_patch_for_cluster');

unique_file_index = unique(record_patch_for_cluster(:,1));
unique_file_toload = length(unique_file_index);       
for i = 1:unique_file_toload
    index_file = unique_file_index(i);
    picname = FileNameList{index_file};
    partname = picname(1:end-4);
    file_feature = sprintf('%s_feature.mat',partname);
    feature_path = fullfile(Folder_Feature,file_feature);
    %����Ƿ���ڣ�������ھ�ֱ������
    if exist(feature_path,'file')
        fprintf('index:%d skip %s\n',index_file,feature_path);
        continue
    else
        %�����µ��ļ�
        fid = fopen(feature_path,'w+');
        fclose(fid);
    end  
    fprintf('���� index_file:%d %s\n',index_file,feature_path);
    train_img = rgb2gray(imread(fullfile(fullfile(fullfile(pwd,'Database'),'Train'),picname)));
    %feature_matrix ��45*patches��������������
    feature_matrix = GenerateFeatureAndPosition(train_img, sf, sigma);
    match_set = record_patch_for_cluster(:,1) == index_file;
    index_patch_set = record_patch_for_cluster(match_set,2);
    feature_used = feature_matrix(:,index_patch_set);
    %����
    save(feature_path,'feature_used');
end
