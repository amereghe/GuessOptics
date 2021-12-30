function [LGENfileName,APIfileName,savePath]=TreeStructure(part,subpath,Iother)
    if ( exist('Iother','var') )
        savePath=sprintf("data\\%s\\%s\\Idip_%6.2f",part,subpath,Iother);
        LGENfileName=sprintf("%s\\LGEN_%s_%s_%6.2f.xls",savePath,part,subpath,Iother);
        APIfileName=sprintf("%s\\API_%s_%s_%6.2f.txt",savePath,part,subpath,Iother);
    else
        savePath=sprintf("data\\%s\\%s",part,subpath);
        LGENfileName=sprintf("%s\\LGEN_%s_%s.xls",savePath,part,subpath);
        APIfileName=sprintf("%s\\API_%s_%s.txt",savePath,part,subpath);
    end
    if ~exist(savePath, 'dir'), mkdir(savePath); end
end
