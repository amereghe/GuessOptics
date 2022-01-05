function values=GenerateLGENvalsAroundTM(TMcurrs,magnetNames,peakCurrs,myMagnetNames,deltas,steps,laddBump,values)
    % generate just the bare values for a scan in current around TM values
    % TMcurrs,magnetNames,peakCurrs must have the same length
    % myMagnetNames,deltas,steps must have the same length
    % next step: give the possibility to have ranges of deltas and steps
    nPeakCurrs=4;
    fprintf("generating LGEN values for %d magnets...\n",length(myMagnetNames));
    if ( ~exist('laddBump','var') ), laddBump=true; end
    if ( exist('values','var') )
        nVals=size(values,1); nSeries=size(values,2);
    else
        nVals=0; nSeries=0;
    end
    
    for iMag=1:length(myMagnetNames)
        fprintf("...for magnet %s ...\n",myMagnetNames(iMag));
        % generate scan values
        index=find(magnetNames==myMagnetNames(iMag));
        if ( deltas(iMag)==0 )
            if ( nVals==0 )
                tmpValues=TMcurrs(index);
            else
                tmpValues=ones(1,nVals)*TMcurrs(index);
            end
            nTmpValues=length(tmpValues);
        else
            tmpValues=TMcurrs(index)-deltas(iMag):steps(iMag):TMcurrs(index)+deltas(iMag);
            nTmpValues=length(tmpValues);
            % add bump in current at end of scan
            if ( laddBump & ~ismissing(peakCurrs) )
                tmpValues(nTmpValues+1:nTmpValues+nPeakCurrs)=peakCurrs(index);
                nTmpValues=nTmpValues+nPeakCurrs;
            end
        end
        % fill in existing array
        newCol=nSeries+1;
        values(1:nTmpValues,newCol)=tmpValues';

        if ( nSeries>0 )
            if ( nVals<nTmpValues )
                % the last value of the other series should be repeated till the (new) end
                for ii=1:nTmpValues-nVals
                    values(nVals+ii,1:nSeries)=values(nVals,1:nSeries);
                end
            else
                % the last value of the current series should be repeated till the end
                values(nTmpValues+1:end,newCol)=tmpValues(end);
            end
        end
        nVals=size(values,1); nSeries=size(values,2);
    end
    fprintf("...done.\n");
end
