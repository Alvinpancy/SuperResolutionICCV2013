function Grad = SuppressBoundary(img)
    [height, width] = size(img);
    Grad = zeros(height,width,8);
    rowsupress = cell(2,1);
    colsupress = cell(2,1);
    for i=1:8
        switch i
            case 1              %上
                 rsupress = -1;
                csupress = 0;
                rowsupress{1} = 1;
                colsupress{1} = 'all';
                supnumber = 1;
            case 2              %右上
                rsupress = -1;
                csupress = 1;
                rowsupress{1} = 'all';
                colsupress{1} = width;
                rowsupress{2} = 1;
                colsupress{2} = 'all';
                supnumber = 2;
            case 3              %右
                rsupress = 0;
                csupress = 1;
                rowsupress{1} = 'all';
                colsupress{1} = width;
                supnumber = 1;
            case 4              %左上
                rsupress = -1;
                csupress = -1;
                rowsupress{1} = 1;
                colsupress{1} = 'all';
                rowsupress{2} = 'all';
                colsupress{2} = 1;
                supnumber = 2;
            case 5          %左
                rsupress = 0;
                csupress = -1;
                rowsupress{1} = 'all';
                colsupress{1} = 1;
                supnumber = 1;
            case 6          %左下
                rsupress = 1;
                csupress = -1;
                rowsupress{1} = 'all';
                colsupress{1} = 1;
                rowsupress{2} = height;
                colsupress{2} = 'all';
                supnumber = 2;
            case 7          %下
                rsupress = 1;
                csupress = 0;
                rowsupress{1} = height;
                colsupress{1} = 'all';
                supnumber = 1;
            case 8          %右下
                rsupress = 1;
                csupress = 1;
                rowsupress{1} = height;
                colsupress{1} = 'all';
                rowsupress{2} = 'all';
                colsupress{2} = width;
                supnumber = 2;
        end
        Grad(:,:,i) = circshift(img,[-rsupress,-csupress]) - img ;
        for supidx = 1:supnumber
            if ischar(colsupress{supidx}) && strcmp(colsupress{supidx},'all')
                r = rowsupress{supidx};
                Grad(r,:,i) = 0;
            end  
            if ischar(rowsupress{supidx}) && strcmp(rowsupress{supidx},'all')
                c = colsupress{supidx};
                Grad(:,c,i) = 0;
            end          
        end
    end
end
