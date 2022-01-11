%��300�����patch���о��������ȡ��20��ݵ�patch����ѵ��
clear
close all
clc

sf = 3;
sigma = 1.6;
Filelist = ReadFileNameList(fullfile(fullfile(pwd,'Database'),'TrainList.txt'));
file_length = length(Filelist);
        
Folder_Position = fullfile(pwd,'Position');
Record_Patchnumbers = zeros(file_length,1);

for index_file = 1:file_length
    picname = Filelist{index_file};
    partname = picname(1:end-4);
    %load the position.mat to know the num_feature contained in
    %one file һ��ͼ����һ����˵��ƽ���Ĳ��������������������ԵĲ���
    pic_position = sprintf('%s_position.mat',partname);
    %ĳһ���ļ���·��
    pic_position_path = fullfile(Folder_Position,pic_position);
    fprintf('%d load %s\n',index_file,pic_position_path);
    load_data = load(pic_position_path,'table_position_center');
    %��ȡ������loaddata.table_position_center��������Ҳ����patch������
    patch_numbers = size(load_data.table_position_center,2);
    %��¼ÿһ��ͼ���ļ���patch����
    Record_Patchnumbers(index_file) = patch_numbers;
end
    %320��lrͼ�������patch������ 300�����patch
    total_patch_numbers = sum(Record_Patchnumbers);
    
    %���ȡ20���patch������
    random_select_patches_num = 2e5; 
    RandStream.setGlobalStream(RandStream('mcg16807','Seed',0))   
    array_rand = rand(random_select_patches_num,1);
    selected_patches = ceil(array_rand * total_patch_numbers);
    
    %�����300�����patch��ѡ��20���patch�����㣬�Ӷ����ټ�����,��������
    arr_idx_patch = sort(selected_patches,'ascend');
    %��¼���ѡ�������patches������[ͼƬ��ţ�patch���]
    record_patch_for_cluster = zeros(random_select_patches_num,2);
        
    index_file = 1;
    index_patch_start = 1;
    index_patch_end = index_patch_start + Record_Patchnumbers(index_file) -1;
    %��1��20���������
for idx_to_fill = 1:random_select_patches_num
    % idx_patch_overall_query�ǵ�ǰ���ʵ�patch��index(1��300����֮��������)
    idx_patch_overall_query = arr_idx_patch(idx_to_fill);
    %�����whileѭ���Ƕ�λ���ض���ͼƬλ�ã���Ϊidx_patch_overall_query�ǵ�����������
     while ~(index_patch_start <= idx_patch_overall_query && idx_patch_overall_query <= index_patch_end)
           index_file = index_file + 1;
           index_patch_start = index_patch_end + 1;
           index_patch_end = index_patch_start + Record_Patchnumbers(index_file) -1;
     end
            
     %use current date to fill the record
     idx_patch_in_image = idx_patch_overall_query - index_patch_start + 1;
     %��¼�ļ�����Լ���Ӧ��patch���
     record_patch_for_cluster(idx_to_fill,:) = [index_file, idx_patch_in_image];
     %end
end
        
%����
foldername = fullfile(pwd,'Cluster');
if ~exist(foldername,'dir')
    mkdir(foldername)
end
fn_save = sprintf('record_patch_for_cluster_sf%d_sigma%.1f.mat',sf,sigma);
save(fullfile(foldername,fn_save),'record_patch_for_cluster');
