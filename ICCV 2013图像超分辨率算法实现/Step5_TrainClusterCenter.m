clc
clear
close all

folder_yang13 = pwd;
folder_code = fileparts(folder_yang13);
folder_thisproject = fileparts(folder_code);
folder_dataset = fullfile(folder_thisproject,'Dataset');
folder_filelist = fullfile(folder_dataset,'FileList');
folder_feature_root = fullfile(folder_yang13,'Feature');
folder_cluster_root = fullfile(folder_yang13,'Cluster');
fn_filelist = 'AllFive.txt';

FileNameList = ReadFileNameList(fullfile(fullfile(pwd,'Database'),'TrainList.txt'));
random_select_patches_num = 2e5;
patch_length = 45;

sf = 3;
sigma = 1.6;

%提取出 record_patch_for_cluster
Folder_Cluster = fullfile(pwd,'Cluster');
file_record = sprintf('record_patch_for_cluster_sf%d_sigma%.1f.mat',sf,sigma);
load_fmatrix =load(fullfile(Folder_Cluster,file_record),'record_patch_for_cluster');
record_patch_for_cluster = load_fmatrix.record_patch_for_cluster;
clear loaddata

unique_file_index = unique(record_patch_for_cluster(:,1));
unique_num_file  = length(unique_file_index);
train_cluster_matrix = zeros(random_select_patches_num,patch_length);

idx_feature_end = 0;
folder_feature = fullfile(pwd,'Feature');
%num_file_idx_to_load 等于320
for index = 1:unique_num_file
    idx_feature_start = idx_feature_end + 1;
    %提取编号为index的图像文件
    index_file = unique_file_index(index);
    picname = FileNameList{index_file};
    partname = picname(1:end-4);
    %特征文件夹里面保存的是每张图片各自的一部分的patch的特征
    file_feature = sprintf('%s_feature.mat',partname);
    file_feature_path = fullfile(folder_feature,file_feature);
    %loaddate为每一张图片的feature举证
    load_fmatrix = load(file_feature_path,'feature_used');
    feature_mat = load_fmatrix.feature_used;       %here, column vector
    num_patch_totrain = size(feature_mat,2);
    idx_feature_end = idx_feature_start + num_patch_totrain -1;
    %每一次循环提取出一张图片所有patch的特征
    train_cluster_matrix(idx_feature_start:idx_feature_end,:) = feature_mat';
end

%20万个patch的特征都存在data_to_train_cluster中，20万*45的矩阵

%训练聚类
seed = RandStream('mcg16807','Seed',0);
RandStream.setGlobalStream(seed)
train_iteration = 100;      %use a small iteratio nnumber for sanity test
train_cluster = 4096;
operations = statset('Display','iter','MaxIter',train_iteration);
% [IDX, C] = kmeans(feature_10percent,num_clusterk,'start','cluster','emptyaction','drop','options',opts);     %use uniform option to prevent randomness
% Idx :N*1的向量，存储的是每个点的聚类标号
% C: K*P的矩阵，存储的是K个聚类质心位置
[IDX, C] = kmeans(train_cluster_matrix,train_cluster,'emptyaction','drop','options',operations);
%fn_save = sprintf('ClusterResults_sf%d_sigma%.1f.mat',sf,sigma);
%save(fullfile(folder_cluster,fn_save),'IDX','C');

%save the sorted C
arr_training_instance = hist(IDX,train_cluster);
[arr_training_instance_sort,IX] = sort(arr_training_instance,'descend');
%clustercenter是按照每个聚类的patch的数量的多少按照降序来排列的
%第一行对应patch最多的聚类的质心位置
clustercenter = C(IX,:);
file_save = sprintf('ClusterCenter_sf%d_sigma%.1f.mat',sf,sigma);
save(fullfile(folder_cluster,file_save),'clustercenter');
