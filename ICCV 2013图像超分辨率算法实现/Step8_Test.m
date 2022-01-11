clc
clear
close all

sf = 3;
sigma = 1.6;

%load TestList
FileNameList = ReadFileNameList(fullfile(fullfile(pwd,'Database'),'TestList.txt'));
File_numbers = length(FileNameList);

%提取出每个聚类的中心
folder_cluster = fullfile(pwd,'Cluster');
fn_clustercenter = sprintf('ClusterCenter_sf%d_sigma%.1f.mat',sf,sigma);
loaddata = load(fullfile(folder_cluster, fn_clustercenter),'clustercenter');
clustercenter = loaddata.clustercenter';        %transpose, to make each feature as a column

%提取出每个聚类的系数矩阵
folder_coef = fullfile(pwd,'Coef');
fn_coef_matrix = sprintf('coef_matrix_sf%d_sigma%.1f.mat',sf,sigma);
loaddata = load(fullfile(folder_coef, fn_coef_matrix),'coef_matrix');
coef_matrix = loaddata.coef_matrix;

%test_input图像文件的路径pwd/Database/Test_Input
folder_database = fullfile(pwd,'Database');
folder_testinput = fullfile(folder_database,'Test_Input');

%得到的结果存放的路径 pwd/Database/TestResult
folder_output = fullfile(folder_database,'TestReault');
if ~exist(folder_output,'dir')
    mkdir(folder_output);
    fprintf('创建 %s\n', folder_output);
end

for idx_file = 1:File_numbers
    tic;
    picname = FileNameList{idx_file};
    partname = picname(1:end-4);
    pic_save = sprintf('%s.bmp',partname);
    pic_save_path = fullfile(folder_output,pic_save);
    %如果图像存在就直接忽略
    if exist(pic_save_path,'file')
        fprintf('忽略 %s\n', pic_save_path);
        continue
    else
        fid = fopen(pic_save_path,'w+');
        fclose(fid);
        fprintf('正在计算 %s\n',pic_save_path);
        img_rgb = im2double(imread(fullfile(folder_testinput,picname)));
        if size(img_rgb,3) == 3
            % RGB 2 YIQ
            img_yiq = RGB2YIQ(img_rgb);
            img_y = img_yiq(:,:,1);
            img_iq = img_yiq(:,:,2:3);
            %GetHighResolutionImg
            hr_patchsize = 3*sf;
            hr_img_res = (hr_patchsize)^2;
            num_cluster = size(clustercenter,2);
            [height_lr, width_lr] = size(img_y);
            patch_lr_bian = 7;
            half_bian = (patch_lr_bian - 1) /2;
            img_y_plus = wextend('2d','symw',img_y,half_bian);
            cluster_record = zeros(height_lr*width_lr,1);
            grad_imgyplus = SuppressBoundary(img_y_plus);
            patch_vector_without = [2:6 8:42 44:48];
            arr_smoothpatch = false(height_lr*width_lr,1);
            img_yplusb = imresize(img_y_plus,sf);
            [hr_height, hr_weight] = size(img_yplusb);
            img_hrplus_counter = zeros(hr_height,hr_weight);
            img_hrplus_sum = zeros(hr_height,hr_weight);
            hr_value = zeros(hr_img_res,height_lr*width_lr);
            
            for index = 1:height_lr*width_lr
                row = mod(index-1,height_lr)+1;col = ceil(index/height_lr);
                row1 = row+patch_lr_bian-1;col1 = col+patch_lr_bian-1;
                patch_lr_grad = grad_imgyplus(row+1:row1-1,col+1:col1-1,:);
                smooth_grad = abs(patch_lr_grad) <= 0.05;
                if sum(smooth_grad(:)) ~= 200
                    patch_lowr = img_y_plus(row:row1,col:col1);
                    patch_without = patch_lowr(patch_vector_without);
                    patchl_mean = mean(patch_without);
                    lr_feature = patch_without' - patchl_mean;
                    diff = repmat(lr_feature,[1 num_cluster]) - clustercenter;
                    squ = sum((diff.^2));
                    [~,clusteridx] = min(squ);
                    cluster_record(index) = clusteridx;
                    if nnz(coef_matrix(:,:,clusteridx) > 10000)
                        arr_smoothpatch(index) = true;
                        feature_hr = coef_matrix(:,:,clusteridx) * [lr_feature;1];
                        intensity_hr_this = feature_hr + patchl_mean;
                        hr_value(:,index) = intensity_hr_this;
                    else
                        feature_hr = coef_matrix(:,:,clusteridx) * [lr_feature;1];
                        intensity_hr_this = feature_hr + patchl_mean;
                        hr_value(:,index) = intensity_hr_this;
                    end
                else
                    arr_smoothpatch(index) = true;
                end
            end
            
            hr_value(hr_value>1) = 1;
            hr_value(hr_value<0) = 0;
            dist = 2 * sf;
            for index=1:height_lr*width_lr
                row = mod(index-1,height_lr)+1;col = ceil(index/height_lr);
                ch = (col-1)*sf +1 + dist;ch1 = ch + hr_patchsize -1;
                rh = (row-1)*sf+1 + dist;rh1 = rh+hr_patchsize-1;
                if arr_smoothpatch(index)
                    img_hrplus_sum(rh:rh1,ch:ch1) = img_hrplus_sum(rh:rh1,ch:ch1) + img_yplusb(rh:rh1,ch:ch1);
                else
                    img_hrplus_sum(rh:rh1,ch:ch1) = img_hrplus_sum(rh:rh1,ch:ch1) + reshape(hr_value(:,index),[hr_patchsize, hr_patchsize]);
                end
                img_hrplus_counter(rh:rh1,ch:ch1) = img_hrplus_counter(rh:rh1,ch:ch1) + 1;
            end
            
            img_hrplus_av = img_hrplus_sum ./ img_hrplus_counter;
            img_hr = img_hrplus_av(half_bian * sf+1:end-half_bian * sf,half_bian * sf+1:end-half_bian * sf);
            img_yiq_hr = img_hr;
            img_yiq_hr(:,:,2:3) = imresize(img_iq,sf);
            % YIQ 2 RGB
            img_rgb_hr = YIQ2RGB(img_yiq_hr);
            imwrite(img_rgb_hr,pic_save_path);
        else
            img_y = img_rgb;
            % GetHighResolutionImg
            hr_patchsize = 3*sf;
            hr_img_res = (hr_patchsize)^2;
            num_cluster = size(clustercenter,2);
            [height_lr, width_lr] = size(img_y);
            patch_lr_bian = 7;
            half_bian = (patch_lr_bian - 1) /2;
            img_y_plus = wextend('2d','symw',img_y,half_bian);
            cluster_record = zeros(height_lr*width_lr,1);
            grad_imgyplus = SuppressBoundary(img_y_plus);
            patch_vector_without = [2:6 8:42 44:48];
            arr_smoothpatch = false(height_lr*width_lr,1);
            img_yplusb = imresize(img_y_plus,sf);
            [hr_height, hr_weight] = size(img_yplusb);
            img_hrplus_counter = zeros(hr_height,hr_weight);
            img_hrplus_sum = zeros(hr_height,hr_weight);
            hr_value = zeros(hr_img_res,height_lr*width_lr);
            
            for index = 1:height_lr*width_lr
                row = mod(index-1,height_lr)+1;col = ceil(index/height_lr);
                row1 = row+patch_lr_bian-1;col1 = col+patch_lr_bian-1;
                patch_lr_grad = grad_imgyplus(row+1:row1-1,col+1:col1-1,:);
                smooth_grad = abs(patch_lr_grad) <= 0.05;
                if sum(smooth_grad(:)) ~= 200
                    patch_lowr = img_y_plus(row:row1,col:col1);
                    patch_without = patch_lowr(patch_vector_without);
                    patchl_mean = mean(patch_without);
                    lr_feature = patch_without' - patchl_mean;
                    diff = repmat(lr_feature,[1 num_cluster]) - clustercenter;
                    squ = sum((diff.^2));
                    [~,clusteridx] = min(squ);
                    cluster_record(index) = clusteridx;
                    if nnz(coef_matrix(:,:,clusteridx) > 10000)
                        arr_smoothpatch(index) = true;
                        feature_hr = coef_matrix(:,:,clusteridx) * [lr_feature;1];
                        intensity_hr_this = feature_hr + patchl_mean;
                        hr_value(:,index) = intensity_hr_this;
                    else
                        feature_hr = coef_matrix(:,:,clusteridx) * [lr_feature;1];
                        intensity_hr_this = feature_hr + patchl_mean;
                        hr_value(:,index) = intensity_hr_this;
                    end
                else
                    arr_smoothpatch(index) = true;
                end
            end
            
            hr_value(hr_value>1) = 1;
            hr_value(hr_value<0) = 0;
            dist = 2 * sf;
            for index=1:height_lr*width_lr
                row = mod(index-1,height_lr)+1;col = ceil(index/height_lr);
                ch = (col-1)*sf +1 + dist;ch1 = ch + hr_patchsize -1;
                rh = (row-1)*sf+1 + dist;rh1 = rh+hr_patchsize-1;
                if arr_smoothpatch(index)
                    img_hrplus_sum(rh:rh1,ch:ch1) = img_hrplus_sum(rh:rh1,ch:ch1) + img_yplusb(rh:rh1,ch:ch1);
                else
                    img_hrplus_sum(rh:rh1,ch:ch1) = img_hrplus_sum(rh:rh1,ch:ch1) + reshape(hr_value(:,index),[hr_patchsize, hr_patchsize]);
                end
                img_hrplus_counter(rh:rh1,ch:ch1) = img_hrplus_counter(rh:rh1,ch:ch1) + 1;
            end
            
            img_hrplus_av = img_hrplus_sum ./ img_hrplus_counter;
            img_hr = img_hrplus_av(half_bian * sf+1:end-half_bian * sf,half_bian * sf+1:end-half_bian * sf);
            imwrite(img_hr,pic_save_path);
        end
    end
    toc;
end
