function [MADXtable,MADXtableHeaders]=ReadMADXData(MADXpath)
    fprintf('parsing file %s ...\n',MADXpath);
    MADXtable=readmatrix(MADXpath,'Delimiter',',','NumHeaderLines',1,'FileType','text');
    fprintf('...acquired %d lines;\n',size(MADXtable,1));
    % get header
    fid = fopen(MADXpath, 'r');
    header = fgets(fid);
    fclose(fid);
    MADXtableHeaders=upper(strip(split(string(header(2:end)),",")))';
end
