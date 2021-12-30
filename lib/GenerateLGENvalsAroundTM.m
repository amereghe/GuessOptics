function values=GenerateLGENvalsAroundTM(TMcurrs,magnetNames,peakCurrs,myMagnetNames,deltas,steps,values)
    % generate just the bare values for a scan in current around TM values
    % peakCurrs,myMagnetNames,deltas,steps must have the same length
    % next step: give the possibility to have ranges of deltas and steps
    nPeakCurrs=4;
    if ( length(myMagnetNames)==1 )
        fprintf("generating LGEN values for magnet %s ...\n",myMagnetNames);
    else
        fprintf("generating LGEN values for %d magnets...\n",length(myMagnetNames));
    end
    if ( exist('values','var') )
        nVals=size(values,1); nSeries=size(values,2);
    else
        nVals=0; nSeries=0;
    end
    
    for iMag=1:length(myMagnetNames)
        % generate scan values
        index=find(magnetNames==myMagnetNames(iMag));
        tmpValues=TMcurrs(index)-deltas(iMag):steps(iMag):TMcurrs(index)+deltas(iMag);
        nTmpValues=length(tmpValues);
        if ( ~ismissing(peakCurrs) )
            tmpValues(nTmpValues+1:nTmpValues+nPeakCurrs)=peakCurrs(index);
            nTmpValues=nTmpValues+nPeakCurrs;
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
            nSeries=size(values,2);
        end
    end
    fprintf("...done.\n");
end
