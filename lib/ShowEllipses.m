function ShowEllipses(FWHMs,BARs,ScanXs,ParXs,ScanName,ParName,myTitle)
    fprintf('plotting ellipses...\n');
    zLim=50; % [mm]
    nScanXs=length(ScanXs); nParXs=length(ParXs);
    figure();
    [nRows,nCols]=GetNrowsNcols(nParXs);
    cm=colormap(parula(nScanXs));
    for iPar=1:nParXs
        subplot(nRows,nCols,iPar);
        aa=FWHMs(:,1,iPar)/(2*sqrt(2*log(2.0))); bb=FWHMs(:,2,iPar)/(2*sqrt(2*log(2.0)));
        x0=BARs(:,1,iPar); y0=BARs(:,2,iPar);
        [Xs,Ys]=ComputeEllipse(aa,bb,x0,y0);
        for iScanXs=1:nScanXs
            if (iScanXs>1), hold on; end
            plot(Xs(:,iScanXs),Ys(:,iScanXs),"-","Color",cm(iScanXs,:));
        end
        grid(); xlabel("x [mm]"); ylabel("y [mm]"); title(sprintf("I_{par}=%g A",ParXs(iPar)));
        xlim([-zLim zLim]); ylim([-zLim zLim]);
    end
    sgtitle(sprintf("1\\sigma_{RMS} ellipse - %s - Par: %s",myTitle,LabelMe(ParName)));
    fprintf('...done.\n');
end

function [Xs,Ys]=ComputeEllipse(aa,bb,x0,y0)
    Nsteps=100;
    Xs=zeros(2*(2*Nsteps+1),length(aa)); Ys=zeros(2*(2*Nsteps+1),length(aa));
    for ii=1:length(aa)
        Xs(1:2*Nsteps+1,ii)=(aa(ii):-aa(ii)/Nsteps:-aa(ii))';
        Xs(2*Nsteps+2:2*(2*Nsteps+1),ii)=-Xs(1:2*Nsteps+1,ii);
        Ys(1:2*Nsteps+1,ii)=bb(ii)*sqrt(1-(Xs(1:2*Nsteps+1,ii)/aa(ii)).^2);
        Ys(2*Nsteps+2:2*(2*Nsteps+1),ii)=-bb(ii)*sqrt(1-(Xs(2*Nsteps+2:2*(2*Nsteps+1),ii)/aa(ii)).^2);
        Xs(:,ii)=Xs(:,ii)+x0(ii);
        Ys(:,ii)=Ys(:,ii)+y0(ii);
    end
end