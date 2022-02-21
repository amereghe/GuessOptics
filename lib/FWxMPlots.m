function FWxMPlots(Is,FWHMs,BARs,fracEst,indices,scanDescription,titleSeries,lFull,actPlotName)
    fprintf("plotting FWxM data (scan plots)...\n");
    nMons=size(FWHMs,4);
    nPlotsPerMon=5;
    nLevels=size(FWHMs,3);
    planes=[ "HOR" "VER" ];
    if ( ~exist('titleSeries','var') || sum(ismissing(titleSeries)) )
        titleSeries=compose("Series %02i",(1:nMons)');
    end
    
    if ( ~exist('lFull','var') ), lFull=true; end
    if ( lFull ), what="FWxM"; else what="HWxM"; end
    
    if ( exist('actPlotName','var') )
        ff = figure('visible','off');
    else
        ff = figure();
    end
    % increase by 10 figure dimensions
    ff.Position(1:2)=ff.Position(1:2)/20.;
    ff.Position(3)=ff.Position(3)*4;
    ff.Position(4)=ff.Position(4)*nMons;
    
    iPlot=0;
    if ( ismissing(Is) )
        myXlabel="ID []";
    else
        Xs=Is(indices(1,1):indices(1,2));
        myXlabel="I [A]";
    end
    [ReducedFWxM]=GetReducedFWxM(FWHMs,fracEst,lFull);
    for iMon=1:nMons % CAMeretta,DDS
        if ( ismissing(Is) ), Xs=indices(iMon+1,1):indices(iMon+1,2); end
        % FWxM
        for iPlane=1:length(planes)
            iPlot=iPlot+1; ax(iPlot)=subplot(nMons,nPlotsPerMon,iPlot);
            for iLev=1:nLevels
                if (iLev>1), hold on; end
                Ys=FWHMs(indices(iMon+1,1):indices(iMon+1,2),iPlane,iLev,iMon);
                plot(Xs,Ys,"*-");
            end
            if (iPlot==1), legend(string(fracEst*100)+"%","Location","best"); end
            grid on; xlabel(myXlabel); ylabel("[mm]");
            title(sprintf("%s_{%s} - %s",what,planes(iPlane),titleSeries(iMon))); % legend("HOR","VER","Location","best");
            yl=ylim(); ylim([0 yl(2)]);
        end
        % normalised FWxM
        for iPlane=1:length(planes)
            iPlot=iPlot+1; ax(iPlot)=subplot(nMons,nPlotsPerMon,iPlot);
            for iLev=1:nLevels
                if (iLev>1), hold on; end
                Ys=ReducedFWxM(indices(iMon+1,1):indices(iMon+1,2),iPlane,iLev,iMon);
                plot(Xs,Ys,"*-");
            end
            % legend(string(fracEst*100)+"%","Location","best");
            grid on; xlabel(myXlabel); ylabel("[mm]");
            title(sprintf("\\sigma_{%s} - %s",planes(iPlane),titleSeries(iMon))); % legend("HOR","VER","Location","best");
            yl=ylim(); ylim([0 yl(2)]);
        end
        % BAR 
        iPlot=iPlot+1; ax(iPlot)=subplot(nMons,nPlotsPerMon,iPlot);
        % - hor
        yyaxis left; iPlane=1;
        Ys=BARs(indices(iMon+1,1):indices(iMon+1,2),iPlane,iMon); plot(Xs,Ys,"*-");
        ylabel(sprintf("%s [mm]",planes(iPlane)));
        % - ver
        yyaxis right; iPlane=2;
        Ys=BARs(indices(iMon+1,1):indices(iMon+1,2),iPlane,iMon); plot(Xs,Ys,"*-");
        ylabel(sprintf("%s [mm]",planes(iPlane)));
        yyaxis left;
        grid on; xlabel(myXlabel);
        title(sprintf("BARicentre - %s",titleSeries(iMon))); % legend("HOR","VER","Location","best");
    end
    % general
    sgtitle(scanDescription);
    linkaxes(ax,"x");
    if ( exist('actPlotName','var') )
        MapFileOut=sprintf("%s_scans_FWxM.png",actPlotName);
        fprintf("...saving to file %s ...\n",MapFileOut);
        exportgraphics(ff,MapFileOut,'Resolution',300); % resolution=DPI
    end
    fprintf("...done.\n");
end
