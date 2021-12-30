function [FWHMs,BARs,ScanXs,ParXs]=MADXtoFWHMsBARs(MADXtable,emiGeo,sigdpp,avedpp,myPlanes)
    fprintf('converting MADX data into FWHMs and BARs...\n');
    iOrb =[ 7 10 ]; iBeta=[ 8 11 ]; iDisp=[ 9 12 ]; % hor,ver planes
    iScanX=4; iParX=3; % Iquad and Idip [A];
    sig2FWHM=2*sqrt(2*log(2.0));
    
    %% sanity checks
    % which planes to process: 1="hor", 2="ver";
    if ( ~exist('myPlanes','var') ), myPlanes=[ 1 2 ]; end
    if ( sum(myPlanes>2 | myPlanes<1) )
        error("...please specify either hor (1) or ver (2) plane(s)!");
    end
    if ( ismissing(emiGeo) | isnan(emiGeo) ), emiGeo=zeros(2,1); end
    if ( sum(emiGeo<0) )
        error("...please provide me with positive values of emittance!");
    end
    if ( ismissing(sigdpp) | isnan(sigdpp) ) sigdpp=0.0; end
    if ( sum(sigdpp<0) )
        error("...please provide me with positive values of sigdpp!");
    end
    
    %% scanning variable and parameter
    ScanXs=unique(MADXtable(:,iScanX)); ParXs=unique(MADXtable(:,iParX));
    nScanXs=length(ScanXs); nParXs=length(ParXs);
    FWHMs=NaN(nScanXs,2,nParXs);
    BARs=NaN(nScanXs,2,nParXs);
    
    %% actual calculation
    for iP=1:length(myPlanes)
        for jParX=1:nParXs
            indices=(MADXtable(:,iParX)==ParXs(jParX));
            FWHMs(:,myPlanes(iP),jParX)=sqrt(MADXtable(indices,iBeta(myPlanes(iP)))*emiGeo(myPlanes(iP))+(MADXtable(indices,iDisp(myPlanes(iP)))*sigdpp).^2)*sig2FWHM*1E3;
            BARs (:,myPlanes(iP),jParX)=(MADXtable(indices,iOrb(myPlanes(iP)))+MADXtable(indices,iDisp(myPlanes(iP)))*avedpp)*1E3;
        end
    end
    
    %% done
    fprintf('...done.\n');
end
