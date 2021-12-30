function ShowResponses(BARs,ScanXs,ParXs,ScanName,ParName,myTitle,myPlanes)
    fprintf('plotting scans...\n');
    planes=["hor" "ver"];
    if ( ~exist('myPlanes','var') ), myPlanes=[ 1 2 ]; end % which planes to plot: 1="hor", 2="ver";
    
    figure();
    iPlot=0;
    % ParXs
    cm=colormap(parula(length(ScanXs)));
    for iP=1:length(myPlanes)
        iPlot=iPlot+1;
        axs(iPlot)=subplot(2,length(myPlanes),iPlot);
        for jj=1:length(ScanXs)
            if (jj>1), hold on; end
            plot(ParXs,reshape(BARs(jj,myPlanes(iP),:),[],1),"o","Color",cm(jj,:));
        end
        grid(); xlabel(sprintf("I_{%s} [A]",LabelMe(ParName))); ylabel(sprintf("BAR_{%s} [mm]",planes(myPlanes(iP))));
        % fit
        [Xs,Ys]=reshapeForFitting(BARs(:,myPlanes(iP),:),ParXs,1);
        P = polyfit(Xs,Ys,1);
        yfit = P(1)*Xs+P(2);
        hold on; plot(Xs,yfit,"r-");
        title(sprintf("fit: m=%.3E mm/A; q=%.3E mm;",P(1),P(2)));
    end
    % ScanXs
    cm=colormap(parula(length(ParXs)));
    for iP=1:length(myPlanes)
        iPlot=iPlot+1;
        axs(iPlot)=subplot(2,length(myPlanes),iPlot);
        for jj=1:length(ParXs)
            if (jj>1), hold on; end
            plot(ScanXs,reshape(BARs(:,myPlanes(iP),jj),[],1),"o","Color",cm(jj,:));
        end
        grid(); xlabel(sprintf("I_{%s} [A]",LabelMe(ScanName))); ylabel(sprintf("BAR_{%s} [mm]",planes(myPlanes(iP))));
        % fit
        [Xs,Ys]=reshapeForFitting(BARs(:,myPlanes(iP),:),ScanXs,3);
        P = polyfit(Xs,Ys,1);
        yfit = P(1)*Xs+P(2);
        hold on; plot(Xs,yfit,"r-");
        title(sprintf("fit: m=%.3E mm/A; q=%.3E mm;",P(1),P(2)));
    end
    %% general
    sgtitle(myTitle);
    fprintf('...done.\n');
end

function [Xs,Ys]=reshapeForFitting(BARs,origXs,whichSize)
    nVals=size(BARs,1)*size(BARs,3);
    sizeOrigXs=length(origXs);
    Xs=zeros(nVals,1); Ys=zeros(nVals,1);
    if ( whichSize==1 )
        for ii=1:size(BARs,whichSize)
            Xs((ii-1)*sizeOrigXs+1:ii*sizeOrigXs)=origXs;
            Ys((ii-1)*sizeOrigXs+1:ii*sizeOrigXs)=reshape(BARs(ii,1,:),[],1);
        end
    else
        for ii=1:size(BARs,whichSize)
            Xs((ii-1)*sizeOrigXs+1:ii*sizeOrigXs)=origXs;
            Ys((ii-1)*sizeOrigXs+1:ii*sizeOrigXs)=reshape(BARs(:,1,ii),[],1);
        end
    end
end