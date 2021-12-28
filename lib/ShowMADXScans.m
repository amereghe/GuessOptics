function ShowMADXScans(MADXtable,MADXtableHeaders,emiGeo,sigdpp,avedpp)
    fprintf('plotting MADX scans...\n');
    Idip=unique(MADXtable(:,3)); Iqua=unique(MADXtable(:,4)); nDipCurrs=length(Idip);
    dipName=GetEleName(MADXtableHeaders(3)); quaName=GetEleName(MADXtableHeaders(4));
    %
    planes=["hor" "ver"];
    iOrb =[ 7 10 ]; iBeta=[ 8 11 ]; iDisp=[ 9 12 ];
    %
    figure();
    cm=colormap(parula(nDipCurrs));
    Xs=Iqua;
    tmpLeg=string(Idip)+" A";
    myPlanes=[ 1 2 ]; % which planes to plot: 1="hor", 2="ver";
    iPlot=0;
    % - FWHM
    for iP=1:length(myPlanes)
        iPlot=iPlot+1;
        axs(iPlot)=subplot(2,length(myPlanes),iPlot);
        for iDipCurr=1:nDipCurrs
            if (iDipCurr>1), hold on; end
            indices=(MADXtable(:,3)==Idip(iDipCurr));
            Ys=sqrt(MADXtable(indices,iBeta(myPlanes(iP)))*emiGeo(myPlanes(iP))+(MADXtable(indices,iDisp(myPlanes(iP)))*sigdpp).^2)*1E3;
            plot(Xs,Ys,"o","Color",cm(iDipCurr,:));
        end
        grid(); xlabel(sprintf("I_{%s} [A]",LabelMe(quaName))); ylabel(sprintf("FWHM_{%s} [mm]",planes(myPlanes(iP))));
    end
    % - BAR
    for iP=1:length(myPlanes)
        iPlot=iPlot+1;
        axs(iPlot)=subplot(2,length(myPlanes),iPlot);
        for iDipCurr=1:nDipCurrs
            if (iDipCurr>1), hold on; end
            indices=(MADXtable(:,3)==Idip(iDipCurr));
            Ys=(MADXtable(indices,iOrb(myPlanes(iP)))+MADXtable(indices,iDisp(myPlanes(iP)))*avedpp)*1E3;
            plot(Xs,Ys,"o","Color",cm(iDipCurr,:));
        end
        grid(); xlabel(sprintf("I_{%s} [A]",LabelMe(quaName))); ylabel(sprintf("BAR_{%s} [mm]",planes(myPlanes(iP))));
    end
    % general
    legend(tmpLeg,"Location","best");
    linkaxes(axs,"x");
    fprintf('...done.\n');
end
