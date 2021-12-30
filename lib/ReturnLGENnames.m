function [selectedLGENnames,indLGENs]=ReturnLGENnames(magnetNames,LGENnames,myMagnetNames)
    % magnetNames,LGENnames: mapping;
    % myMagnetNames: names to be queried
    fprintf("looking for magnet name(s)...\n");
    selectedLGENnames=strings(length(myMagnetNames),1);
    indLGENs=zeros(length(myMagnetNames),1);
    for ii=1:length(myMagnetNames)
        myIndex=find(magnetNames==myMagnetNames(ii));
        if (length(myIndex)>1), error("...something wrong with %s!",myMagnetNames(ii)); end
        selectedLGENnames(ii)=LGENnames(myIndex);
        indLGENs(ii)=myIndex;
    end
    fprintf("...done.\n");
end
