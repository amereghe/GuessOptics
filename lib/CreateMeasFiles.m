function CreateMeasFiles(savePath,eleName,Irange,Istep,magnetNames,LGENnames,TMcurrs,DGcurrMaxs,DGcurrMins,part,myCyCode,LGENfileList,lDG)
    % eleName,Irange,Istep must be either 1 or 2 in length:
    % - first element is the scanning one;
    % - second element is the "parametric" one;
    if ( ~exist('LGENfileList','var') ), LGENfileList=eleName; end
    if ( ~exist('lDG','var') ), lDG=true; end
    [selectedLGENnames,indLGENs]=ReturnLGENnames(magnetNames,LGENnames,LGENfileList);
    ranges=zeros(length(LGENfileList),1); steps=zeros(length(LGENfileList),1);                          % keep al magnets at TM
    ranges(strcmp(LGENfileList,eleName(1)))=Irange(1); steps(strcmp(LGENfileList,eleName(1)))=Istep(1); % ...a part from the concerned one
    values=GenerateLGENvalsAroundTM(TMcurrs,magnetNames,DGcurrMaxs,LGENfileList,ranges,steps);
    if ( length(eleName)==1 )
        % single element scan
        [LGENfileName,APIfileName,~]=TreeStructure(part,savePath);
        nAPI=WriteLGENQAfile(LGENfileName,selectedLGENnames,values,DGcurrMaxs(indLGENs),DGcurrMins(indLGENs));
        WriteAPIfile(APIfileName,nAPI,myCyCode);
    else
        % combined elements scan (cartesian product of 2)
        scan2Values=GenerateLGENvalsAroundTM(TMcurrs,magnetNames,DGcurrMaxs,eleName(2:end),Irange(2:end),Istep(2:end),false);
        for iScan2=1:size(scan2Values,1)
            for iEle=2:length(eleName)
                values(:,strcmp(LGENfileList,eleName(iEle)))=scan2Values(iScan2,iEle-1);
            end
            [LGENfileName,APIfileName,~]=TreeStructure(part,savePath,scan2Values(iScan2,1));
            if ( lDG )
                nAPI=WriteLGENQAfile(LGENfileName,selectedLGENnames,values,DGcurrMaxs(indLGENs),DGcurrMins(indLGENs));
            else
                nAPI=WriteLGENQAfile(LGENfileName,selectedLGENnames,values);
            end
            WriteAPIfile(APIfileName,nAPI,myCyCode);
        end
    end
end
