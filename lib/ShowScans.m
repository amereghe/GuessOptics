function ShowScans(FWHMs,BARs,ScanXs,ParXs,ScanName,ParName,myTitle,myPlanes)
    fprintf('plotting scans...\n');
    planes=["hor" "ver"];
    if ( ~exist('myPlanes','var') ), myPlanes=[ 1 2 ]; end % which planes to plot: 1="hor", 2="ver";
    %%
    figure();
    cm=colormap(parula(length(ParXs)));
    tmpLeg=string(ParXs)+" A";
    iPlot=0;
    % - FWHMs
    for iP=1:length(myPlanes)
        iPlot=iPlot+1;
        axs(iPlot)=subplot(2,length(myPlanes),iPlot);
        for iParXs=1:length(ParXs)
            if (iParXs>1), hold on; end
            plot(ScanXs,FWHMs(:,myPlanes(iP),iParXs),"o","Color",cm(iParXs,:));
        end
        grid(); xlabel(sprintf("I_{%s} [A]",LabelMe(ScanName))); ylabel(sprintf("FWHM_{%s} [mm]",planes(myPlanes(iP))));
    end
    % - BARs
    for iP=1:length(myPlanes)
        iPlot=iPlot+1;
        axs(iPlot)=subplot(2,length(myPlanes),iPlot);
        for iParXs=1:length(ParXs)
            if (iParXs>1), hold on; end
            plot(ScanXs,BARs(:,myPlanes(iP),iParXs),"o","Color",cm(iParXs,:));
        end
        grid(); xlabel(sprintf("I_{%s} [A]",LabelMe(ScanName))); ylabel(sprintf("BAR_{%s} [mm]",planes(myPlanes(iP))));
    end
    %% general
    legend(tmpLeg,"Location","best");
    linkaxes(axs,"x");
    sgtitle(myTitle);
    fprintf('...done.\n');
end
