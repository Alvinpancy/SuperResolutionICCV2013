%从300多万的patch当中均匀随机提取出20万份的patch用于训练
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
    %one file 一张图像中一般来说不平滑的部分是特征是特征最明显的部分
    pic_position = sprintf('%s_position.mat',partname);
    %某一个文件的路径
    pic_position_path = fullfile(Folder_Position,pic_position);
    fprintf('%d load %s\n',index_file,pic_position_path);
    load_data = load(pic_position_path,'table_position_center');
    %提取出矩阵loaddata.table_position_center的列数，也就是patch的数量
    patch_numbers = size(load_data.table_position_center,2);
    %记录每一个图像文件的patch数量
    Record_Patchnumbers(index_file) = patch_numbers;
end
    %320张lr图像的所有patch的数量 300多万个patch
    total_patch_numbers = sum(Record_Patchnumbers);
    
    %随机取20万个patch来计算
    random_select_patches_num = 2e5; 
    RandStream.setGlobalStream(RandStream('mcg16807','Seed',0))   
    array_rand = rand(random_select_patches_num,1);
    selected_patches = ceil(array_rand * total_patch_numbers);
    
    %随机从300多万个patch中选择20万个patch来计算，从而减少计算量,进行排序
    arr_idx_patch = sort(selected_patches,'ascend');
    %记录随机选择出来的patches的坐标[图片编号，patch编号]
    record_patch_for_cluster = zeros(random_select_patches_num,2);
        
    index_file = 1;
    index_patch_start = 1;
    index_patch_end = index_patch_start + Record_Patchnumbers(index_file) -1;
    %从1到20万依次填充
for idx_to_fill = 1:random_select_patches_num
    % idx_patch_overall_query是当前访问的patch的index(1到300多万之间的随机数)
    idx_patch_overall_query = arr_idx_patch(idx_to_fill);
    %下面的while循环是定位到特定的图片位置，因为idx_patch_overall_query是单调不连续的
     while ~(index_patch_start <= idx_patch_overall_query && idx_patch_overall_query <= index_patch_end)
           index_file = index_file + 1;
           index_patch_start = index_patch_end + 1;
           index_patch_end = index_patch_start + Record_Patchnumbers(index_file) -1;
     end
            
     %use current date to fill the record
     idx_patch_in_image = idx_patch_overall_query - index_patch_start + 1;
     %记录文件编号以及对应的patch编号
     record_patch_for_cluster(idx_to_fill,:) = [index_file, idx_patch_in_image];
     %end
end
        
%保存
foldername = fullfile(pwd,'Cluster');
if ~exist(foldername,'dir')
    mkdir(foldername)
end
fn_save = sprintf('record_patch_for_cluster_sf%d_sigma%.1f.mat',sf,sigma);
save(fullfile(foldername,fn_save),'record_patch_for_cluster');
