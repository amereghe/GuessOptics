function WriteAPIfile(fileName,nAPI,myCyCode)
    nAdd=4;
    fprintf("writing API file %s ...\n",fileName);
    fileID=fopen(fileName,"w");
    fprintf(fileID,'%s\n',repmat(myCyCode,nAPI+nAdd,1));
    fclose(fileID);
    fprintf("...done.\n");
end
