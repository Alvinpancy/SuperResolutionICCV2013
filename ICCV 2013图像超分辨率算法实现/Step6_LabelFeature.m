clear
close all
clc

sf = 3;
sigma = 1.6;
FileNameList = ReadFileNameList(fullfile(fullfile(pwd,'Database'),'TrainList.txt'));
File_numbers = length(FileNameList);
Folder_Label = fullfile(pwd,'Label');
if ~exist(Folder_Label ,'dir')
    mkdir(Folder_Label );
end

%提取出 cluster center
Folder_Cluster = fullfile(pwd,'Cluster');
file_load = sprintf('ClusterCenter_sf%d_sigma%.1f.mat',sf,sigma);
loaddata = load(fullfile(Folder_Cluster,file_load),'clustercenter');
clustercenter = loaddata.clustercenter;
Cluster_numbers = size(clustercenter,1);
clear loaddata

for index_file = 1:File_numbers
    picname = FileNameList{index_file};
    partname = picname(1:end-4);
    file_save = sprintf('%s_label.mat',partname);
    %create a file
    label_path = fullfile(Folder_Label,file_save);
    
    %如果文件存在就直接忽略
    if exist(label_path,'file')
        fprintf('skip %d %s\n',index_file,label_path);
        continue
    else
        file_id = fopen(label_path,'w+');
        fclose(file_id);
        fprintf('labeling %d %s\n',index_file,label_path);
    end
    
    %label each file, and save it
    database = fullfile(pwd,'Database');
    Features_Matrix = GenerateFeatureAndPosition(rgb2gray(imread(fullfile(fullfile(database,'Train'), picname))),sf,sigma);
    %patch的数量
    patch_numbers = size(Features_Matrix,2);
    %给每一个patch打标签
    arr_label = zeros(patch_numbers,1);
    for i=1:patch_numbers
        thisf = Features_Matrix(:,i);
        cha = repmat(thisf',[Cluster_numbers,1]) - clustercenter;
        [~,label_index] = min(sqrt(sum(cha.^2,2)));
        arr_label(i) = label_index;
    end
    %保存
    save(label_path,'arr_label');
end
