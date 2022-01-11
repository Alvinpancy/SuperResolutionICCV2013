%因为scale = 3,那么就只考虑奇数的情况
function low_img = Gaussian_Bicub(high_img,s,sigma)
    if isa(high_img,'uint8')
        high_img = im2double(high_img);
    end
    [h, w, d] = size(high_img);
    h1 = h-mod(h,s);
    w1 = w-mod(w,s);
    im1 = high_img(1:h1,1:w1,1:d);
    masksize = ceil(sigma * 3)*2+1;
    mask = fspecial('gaussian',masksize,sigma);
    if d == 1
        filterimg = imfilter(im1,mask,'replicate');
    elseif d == 3
        filterimg = zeros(h1,w1,d);
        for i=1:3
            filterimg(:,:,i) = imfilter(im1(:,:,i),mask,'replicate');
        end
    end
    low_img = imresize(filterimg,1/s,'bicubic');     
end
