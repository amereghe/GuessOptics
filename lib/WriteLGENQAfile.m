function nValues=WriteLGENQAfile(fileName,LGENnames,values,DGcurrMaxs,DGcurrMins,nTimes)
    % DGcurrMins,DGcurrMaxs,nTimes: optional
    fprintf("creating LGEN file %s ...\n",fileName);
    % original size of data
    nValues=size(values,1);
    nLGENs=size(values,2);
    % columns in final table with strings
    nColsStrings=2;
    iColStartVals=1;
    % lost cycles
    nColsLostCycles=2;
    iColStartVals=iColStartVals+nColsLostCycles;
    nValues=nValues+nColsLostCycles;
    
    %% should I add DeGaussing?
    lDG=exist('DGcurrMins','var') & exist('DGcurrMaxs','var');
    if ( lDG )
        % how many times min&max currents should be repeated
        if ( ~exist('nTimes','var') ), nTimes=4; end
        nValues=nValues+3*nTimes;
        iColStartVals=iColStartVals+3*nTimes;
    end
    
    %% build table
    BB=zeros(nValues,nLGENs);
    % lost cycles
    if (lDG), lostCyValues=DGcurrMaxs; else, lostCyValues=values(1,:); end
    for ii=1:nColsLostCycles
        BB(ii,:)=lostCyValues;
    end
    
    % DeGaussing
    if ( lDG )
        for ii=1:nTimes
            BB(nColsLostCycles+ii         ,:)=DGcurrMaxs;
            BB(nColsLostCycles+ii+  nTimes,:)=DGcurrMins;
            BB(nColsLostCycles+ii+2*nTimes,:)=values(1,:);
        end
    end
    
    % actual content
    BB(iColStartVals:end,:)=values;
    
    %% crosscheck current values against min/max
    if ( lDG )
        for ii=1:nLGENs
            indices=(BB(:,ii)>DGcurrMaxs(ii)); BB(indices,ii)=DGcurrMaxs(ii);
            indices=(BB(:,ii)<DGcurrMins(ii)); BB(indices,ii)=DGcurrMins(ii);
        end
    end
    
    %% actually write to file
    CC=cell(nLGENs+1,nValues+nColsStrings); % do not forget the header (1st row) and the first two cols
    % - first column
    CC(2:end,1)=cellstr(LGENnames);
    % - second column
    CC(1,2)=cellstr("Property");  CC(2:end,2)=cellstr("CCV");
    % - first row
    CC(1,1+nColsStrings:end)=num2cell(1:nValues);
    % - actual content
    CC(2:end,1+nColsStrings:end)=num2cell(BB');
    % - write
    writecell(CC,fileName); % in case: writecell(C,fileName,"Sheet","Sheet1");
    
    %%
    nValues=nValues-nColsLostCycles; % actual values...
    fprintf("...done.\n");
end
