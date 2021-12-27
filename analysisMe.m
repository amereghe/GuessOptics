% {}~
%% include libraries and other general settings
% - include Matlab libraries
pathToLibrary="externals\MatLabTools";
addpath(genpath(pathToLibrary));
% - path to K:
kPath="S:\Accelerating-System\Accelerator-data";
% kPath="K:";
% - fitting options
optimoptions('lsqcurvefit','OptimalityTolerance',1E-12,'FunctionTolerance',1E-8);

%% summary materiale a disposizione:
% - BL(I) of MEBT main dipoles:
%   D:\VMs\vb_share\repos\optics\MEBT\materiale_SIMO\MEBT - Calcolo I_v3.xlsx

%% main
% - acquire MADX data
[MADXtable,MADXtableHeaders]=readMADXData("externals\optics\MEBT\m2_scan.tfs");
% - show MADX scans
ShowMADXScans(MADXtable,MADXtableHeaders);

%% function
function [MADXtable,MADXtableHeaders]=readMADXData(MADXpath)
    fprintf('parsing file %s ...\n',MADXpath);
    MADXtable=readmatrix(MADXpath,'Delimiter',',','NumHeaderLines',1,'FileType','text');
    fprintf('...acquired %d lines;\n',size(MADXtable,1));
    % get header
    fid = fopen(MADXpath, 'r');
    header = fgets(fid);
    fclose(fid);
    MADXtableHeaders=upper(strip(split(string(header(2:end)),",")))';
end

function eleName=GetEleName(temp)
    % example: temp="I:m1_016a_qib[A]";
    eleName=split(temp,":"); eleName=split(eleName(2),"["); eleName=eleName(1);
end

function ShowMADXScans(MADXtable,MADXtableHeaders)
    % MADX table columns:
    % - 3: Idip;
    % - 4: Iquad;
    % - 7, 8 and 9: x, betx and dx @monitor;
    % - 10, 11 and 12 : y, bety and dy @monitor;
    fprintf('plotting MADX scans...\n');
    Idip=unique(MADXtable(:,3)); Iqua=unique(MADXtable(:,4)); nDipCurrs=length(Idip);
    dipName=GetEleName(MADXtableHeaders(3)); quaName=GetEleName(MADXtableHeaders(4));
    emiGeoX=4.813808E-6; emiGeoY=2.237630E-6; % [pi m rad]
    sigdpp=3E-3; avedpp=-8.436E-3; % []
    figure();
    cm=colormap(parula(nDipCurrs));
    Xs=Iqua;
    tmpLeg=string(Idip)+" [A]";
    planes=["hor" "ver"];
    iOrb =[ 7 10 ]; iBeta=[ 8 11 ]; iDisp=[ 9 12 ];
    myPlanes=[ 1 2 ]; % which planes to plot
    iPlot=0;
    % - FWHM
    for iP=1:length(myPlanes)
        iPlot=iPlot+1;
        axs(iPlot)=subplot(2,length(myPlanes),iPlot);
        for iDipCurr=1:nDipCurrs
            if (iDipCurr>1), hold on; end
            indices=(MADXtable(:,3)==Idip(iDipCurr));
            Ys=sqrt(MADXtable(indices,iBeta(myPlanes(iP)))*emiGeoX+(MADXtable(indices,iDisp(myPlanes(iP)))*sigdpp).^2)*1E3;
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
    linkaxes(axs,"x");
    fprintf('...done.\n');
end