clear
close all
clc

sf = 3;
sigma = 1.6;

Folder_Position = fullfile(pwd,'Position');
Folder_Label = fullfile(pwd,'Label');
Folder_Regressor = fullfile(pwd,'Regressor');
Folder_Num_Inst = fullfile(pwd,'Num_Inst');
Folder_Database = fullfile(pwd,'Database');
Folder_Image = fullfile(Folder_Database,'Train');
Folder_Coef = fullfile(pwd,'Coef');
if ~exist(Folder_Coef,'dir')
    mkdir(Folder_Coef);
end
if ~exist(Folder_Regressor,'dir')
    mkdir(Folder_Regressor);
end
if ~exist(Folder_Num_Inst ,'dir')
    mkdir(Folder_Num_Inst);
end

FileNameList = ReadFileNameList(fullfile(Folder_Database,'TrainList.txt'));
File_numbers = length(FileNameList);

%arr_img_hr_ui8 存放的是320个图像文件对应的灰度图
hr_gray_img = cell(File_numbers,1);
for index = 1:File_numbers
    picname = FileNameList{index};
    img_read = imread(fullfile(Folder_Image,picname));
    hr_gray_img{index} = rgb2gray(img_read);
end
clear img_read

%arr_img_lr存放的是320张下采样之后的图片
lr_img = cell(File_numbers,1);
li_img_train = 320;
for index = 1:li_img_train
    picname = FileNameList{index};
    lr_img{index} = Gaussian_Bicub(hr_gray_img{index},sf,sigma);
end

%load label 每张图片每个patch 的 label
labels_arrary = cell(File_numbers,1);
for index = 1:File_numbers
    picname = FileNameList{index};
    partname = picname(1:end-4);
    file_label = sprintf('%s_label.mat',partname);
    data = load(fullfile(Folder_Label,file_label),'arr_label');
    labels_arrary{index} = uint16(data.arr_label);
end

%load 每张图片每个patch 的位置坐标
position_array = cell(File_numbers,1);
for index = 1:File_numbers
    picname = FileNameList{index};
    partname = picname(1:end-4);
    file_position = sprintf('%s_position.mat',partname);
    data = load(fullfile(Folder_Position,file_position),'table_position_center');
    position_array{index} = uint16(data.table_position_center);
end

ps = 7;
patch_length = 45;
hr_size = (3*sf)^2;
patcht_without_vector = [2:6 8:42 44:48];
patchsize_h = (ps-1)/2;
all_need_patch_nums = 1000;
label_start = 1;
label_end = 4096;

for index_label = label_start:label_end
    %检查文件是否存在，如果存在的话就直接跳过
    file_reg = sprintf('Regressor_%d.mat',index_label);
    reg_path = fullfile(Folder_Regressor,file_reg);
    if exist(reg_path,'file')
        fprintf('忽略 %s\n',reg_path);
        continue
    else
        fid = fopen(reg_path,'w+');
        fclose(fid);
        fprintf('计算 %s\n',reg_path);
    end

    v_matrix = [];
    c_matrix = [];
    % 长度为81的cell
    coef_mat = cell(1,hr_size);
    counter = 0;
    for index = 1:File_numbers
        % 记录标号为idx_image的图片中所有lebel为idx_label的patch的标号
        match_set = labels_arrary{index} == index_label;
        if nnz( match_set) > 0
            img_hr = im2double(hr_gray_img{index});
            img_lr = lr_img{index};
            %find的作用是除去0元素
            set_match = find(match_set);
            match_length = length(set_match);
            for idx_set_inst = 1:match_length
                %提取出符合条件的patch的横纵坐标
                r = position_array{index}(1,set_match(idx_set_inst));
                c = position_array{index}(2,set_match(idx_set_inst));
                rh = ((r-1)-1)*sf+1;rh1 = (r+1)*sf;
                ch = ((c-1)-1)*sf+1;ch1 = (c+1)*sf;
                patch_l = img_lr(r-patchsize_h:r+patchsize_h,c-patchsize_h:c+patchsize_h);
                patch_without = patch_l(patcht_without_vector);
                counter = counter + 1;
                %idx_inst*45,其中 %idx_inst为当前图片中符合label的patch数量
                v_matrix(counter,:) = patch_without - mean(patch_without);
                patch_h = img_hr(rh:rh1,ch:ch1);
                feature_hr = patch_h - mean(patch_without);
                 %idx_inst*144
                c_matrix(counter,:) = reshape(feature_hr,[hr_size,1]);
            end
        end
        % 每个聚类选则1000左右的patch来计算系数
        if counter >= all_need_patch_nums
            break
        end
    end
    
    %训练系数
    V = [v_matrix ones(counter,1)];
    if isempty(V)
        for j=1:hr_size
            coef_mat{j} = zeros(patch_length+1,1);
        end
    else
         for j=1:hr_size
            C = c_matrix(:,j);
            coef = V\C;
            coef_mat{j} = coef;
        end
    end
    %保存
    num_inst = counter;
    save(fullfile(Folder_Regressor,file_reg),'coef_matrix','num_inst');
    file_save = sprintf('num_inst_%d.mat',index_label);
    save(fullfile(Folder_Num_Inst,file_save),'num_inst');
end

coef_save = sprintf('coef_matrix_sf%d_sigma%.1f.mat',sf,sigma);
coef_matrix = zeros(hr_size,45+1,4096);
for index_label = 1:4096
    load_regressor = sprintf('Regressor_%d.mat',index_label);
    if exist(fullfile(Folder_Regressor,load_regressor),'file')
        loaddata = load(fullfile(Folder_Regressor,load_regressor),'coef_matrix');
        for i=1:hr_size
            coef_matrix(i,:,index_label) = loaddata.coef_matrix{i}';
        end
    end
end
save(fullfile(Folder_Coef,coef_save),'coef_matrix');
