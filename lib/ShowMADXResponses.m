function ShowMADXResponses(MADXtable,ScanName,ParName)
    fprintf('plotting responses to magnet currents as from MADX...\n');
    nPars=length(ParName);
    Brho=unique(MADXtable(:,1));
    Idip=unique(MADXtable(:,11:2:11+(nPars-1)*2),'rows');
    Iqua=unique(MADXtable(:,9));
    K0L=unique(MADXtable(:,12:2:12+(nPars-1)*2),'rows');
    K1=unique(MADXtable(:,10));
    %%
    figure();
    [nRows,nCols]=GetNrowsNcols(nPars+1);
    % - K1(Iquad)
    subplot(nRows,nCols,1);
    P = polyfit(Iqua,K1*Brho,1);
    yfit = P(1)*Iqua+P(2);
    plot(Iqua,K1,"ko",Iqua,yfit/Brho,"r-");
    grid(); xlabel(sprintf("I_{%s} [A]",LabelMe(ScanName))); ylabel("K1 [m^{-2}]");
    legend("MADX data",sprintf("fit: m=%.3E T/m/A; q=%.3E T/m;",P(1),P(2)),"Location","best");
    % - K0L(Idip)
    for iPar=1:nPars
        subplot(nRows,nCols,iPar+1);
        P = polyfit(Idip(:,iPar),K0L(:,iPar)*Brho,1);
        yfit = P(1)*Idip(:,iPar)+P(2);
        plot(Idip(:,iPar),rad2deg(K0L(:,iPar)),"ko",Idip(:,iPar),rad2deg(yfit/Brho),"r-");
        grid(); xlabel(sprintf("I_{%s} [A]",LabelMe(ParName(iPar)))); ylabel("KOL [deg]");
        legend("MADX data",sprintf("fit: m=%.3E Tm/A; q=%.3E Tm;",P(1),P(2)),"Location","best");
    end
end
