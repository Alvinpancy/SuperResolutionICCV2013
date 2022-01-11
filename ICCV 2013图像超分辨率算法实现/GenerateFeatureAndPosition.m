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
    
    %��HrImage����LrImage
    low_resolution = Gaussian_Bicub(img_hr_raw,sf,sigma);
    [h, w] = size(low_resolution);
    low_grad = SuppressBoundary(low_resolution);
    %һ��ͼƬ�е�patch������
    patch_numbers = (h-patchsize+1)*(w-patchsize+1);
    %low resolution feature space
    Feature = zeros(patch_length,patch_numbers);
    %��¼patch�������������Ϣ
    patch_xy = zeros(2,patch_numbers);
    
    counter = 0;
    %r��c�ֱ��ʾÿ��patch���ĵĺᡢ������
    for r=patchsize_half+1:h-patchsize_half
        for c=patchsize_half+1:w-patchsize_half
            grad_res = low_grad(r-2:r+2,c-2:c+2,:);     %2 for detecting smooth region
            ResGradient = nnz(abs(grad_res) <= Thd);
            %neglect smooth patch ���Թ⻬��patches���ӿ�����ٶ�
            if ResGradient < SmoothGradient
                counter = counter + 1;
                %��¼patch�����������Ϣ
                patch_xy(:,counter) = [r;c];
                patch_pic = low_resolution(r-patchsize_half:r+patchsize_half,c-patchsize_half:c+patchsize_half);
                patch_pic_without_corner = patch_pic(patch_vector);
                %45ά������������
                Feature(:,counter) = patch_pic_without_corner -  mean(patch_pic_without_corner);
            end
        end
    end
    Feature = Feature(:,1:counter);
    patch_xy = patch_xy(:,1:counter);
end
