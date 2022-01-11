function filenamelist = ReadFileNameList( fn_list )
    fid = fopen(fn_list,'r');
    res = textscan(fid,'%d %s\n');
    fclose(fid);
    filenamelist = res{2};
end

