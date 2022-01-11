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

%��ȡ�� record_patch_for_cluster
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
%num_file_idx_to_load ����320
for index = 1:unique_num_file
    idx_feature_start = idx_feature_end + 1;
    %��ȡ���Ϊindex��ͼ���ļ�
    index_file = unique_file_index(index);
    picname = FileNameList{index_file};
    partname = picname(1:end-4);
    %�����ļ������汣�����ÿ��ͼƬ���Ե�һ���ֵ�patch������
    file_feature = sprintf('%s_feature.mat',partname);
    file_feature_path = fullfile(folder_feature,file_feature);
    %loaddateΪÿһ��ͼƬ��feature��֤
    load_fmatrix = load(file_feature_path,'feature_used');
    feature_mat = load_fmatrix.feature_used;       %here, column vector
    num_patch_totrain = size(feature_mat,2);
    idx_feature_end = idx_feature_start + num_patch_totrain -1;
    %ÿһ��ѭ����ȡ��һ��ͼƬ����patch������
    train_cluster_matrix(idx_feature_start:idx_feature_end,:) = feature_mat';
end

%20���patch������������data_to_train_cluster�У�20��*45�ľ���

%ѵ������
seed = RandStream('mcg16807','Seed',0);
RandStream.setGlobalStream(seed)
train_iteration = 100;      %use a small iteratio nnumber for sanity test
train_cluster = 4096;
operations = statset('Display','iter','MaxIter',train_iteration);
% [IDX, C] = kmeans(feature_10percent,num_clusterk,'start','cluster','emptyaction','drop','options',opts);     %use uniform option to prevent randomness
% Idx :N*1���������洢����ÿ����ľ�����
% C: K*P�ľ��󣬴洢����K����������λ��
[IDX, C] = kmeans(train_cluster_matrix,train_cluster,'emptyaction','drop','options',operations);
%fn_save = sprintf('ClusterResults_sf%d_sigma%.1f.mat',sf,sigma);
%save(fullfile(folder_cluster,fn_save),'IDX','C');

%save the sorted C
arr_training_instance = hist(IDX,train_cluster);
[arr_training_instance_sort,IX] = sort(arr_training_instance,'descend');
%clustercenter�ǰ���ÿ�������patch�������Ķ��ٰ��ս��������е�
%��һ�ж�Ӧpatch���ľ��������λ��
clustercenter = C(IX,:);
file_save = sprintf('ClusterCenter_sf%d_sigma%.1f.mat',sf,sigma);
save(fullfile(folder_cluster,file_save),'clustercenter');
