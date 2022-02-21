function [ReducedFWxM]=GetReducedFWxM(FWxM,fracEst,lFull)
    ReducedFWxM=FWxM;
    for iLev=1:length(fracEst)
        ReducedFWxM(:,:,iLev,:)=ReducedFWxM(:,:,iLev,:)/sqrt(2*log(1/fracEst(iLev)));
    end
    if ( lFull ), ReducedFWxM=ReducedFWxM/2; end
end
