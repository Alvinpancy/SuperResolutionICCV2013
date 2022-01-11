%Chih-Yuan Yang
%10/11/13
%For PP13a_PC14
function [Feature, patch_xy] = GenerateFeatureAndPosition( img_hr_raw, sf, sigma)
    patch_vector = [2:6 8:42 44:48];
    Thd = 0.05;
    SmoothGradient = 200;
    patch_length = 45;
    patchsize = 7;
    patchsize_half = (patchsize-1)/2;
    
    %由HrImage产生LrImage
    low_resolution = Gaussian_Bicub(img_hr_raw,sf,sigma);
    [h, w] = size(low_resolution);
    low_grad = SuppressBoundary(low_resolution);
    %一张图片中的patch的数量
    patch_numbers = (h-patchsize+1)*(w-patchsize+1);
    %low resolution feature space
    Feature = zeros(patch_length,patch_numbers);
    %记录patch的中心坐标的信息
    patch_xy = zeros(2,patch_numbers);
    
    counter = 0;
    %r和c分别表示每个patch中心的横、纵坐标
    for r=patchsize_half+1:h-patchsize_half
        for c=patchsize_half+1:w-patchsize_half
            grad_res = low_grad(r-2:r+2,c-2:c+2,:);     %2 for detecting smooth region
            ResGradient = nnz(abs(grad_res) <= Thd);
            %neglect smooth patch 忽略光滑的patches，加快计算速度
            if ResGradient < SmoothGradient
                counter = counter + 1;
                %记录patch中心坐标的信息
                patch_xy(:,counter) = [r;c];
                patch_pic = low_resolution(r-patchsize_half:r+patchsize_half,c-patchsize_half:c+patchsize_half);
                patch_pic_without_corner = patch_pic(patch_vector);
                %45维的特征列向量
                Feature(:,counter) = patch_pic_without_corner -  mean(patch_pic_without_corner);
            end
        end
    end
    Feature = Feature(:,1:counter);
    patch_xy = patch_xy(:,1:counter);
end
