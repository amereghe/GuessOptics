function ShowMADXEllipses(MADXtable,emiGeo,sigdpp,avedpp)
    fprintf('plotting MADX ellipses...\n');
    zLim=50; % [mm]
    Idip=unique(MADXtable(:,3)); Iqua=unique(MADXtable(:,4)); nDipCurrs=length(Idip); nQuaCurrs=length(Iqua);
    figure();
    [nRows,nCols]=GetNrowsNcols(nDipCurrs);
    cm=colormap(parula(nQuaCurrs));
    iPlot=0;
    for iDipCurr=1:nDipCurrs
        iPlot=iPlot+1;
        subplot(nRows,nCols,iPlot);
        indices=(MADXtable(:,3)==Idip(iDipCurr));
        aa=sqrt(MADXtable(indices,8 )*emiGeo(1)+(MADXtable(indices,9 )*sigdpp).^2)*1E3;
        bb=sqrt(MADXtable(indices,11)*emiGeo(2)+(MADXtable(indices,12)*sigdpp).^2)*1E3;
        x0=(MADXtable(indices,7 )+MADXtable(indices,9 )*avedpp)*1E3;
        y0=(MADXtable(indices,10)+MADXtable(indices,12)*avedpp)*1E3;
        [Xs,Ys]=ComputeEllipse(aa,bb,x0,y0);
        for iQuaCurr=1:nQuaCurrs
            if (iQuaCurr>1), hold on; end
            plot(Xs(:,iQuaCurr),Ys(:,iQuaCurr),"-","Color",cm(iQuaCurr,:));
        end
        grid(); xlabel("x [mm]"); ylabel("y [mm]"); title(sprintf("1\\sigma_{RMS} ellipse - I_{dip}=%g A",Idip(iDipCurr)));
        xlim([-zLim zLim]); ylim([-zLim zLim]);
    end
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