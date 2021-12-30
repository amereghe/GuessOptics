function ShowMADXResponses(MADXtable,ScanName,ParName)
    fprintf('plotting responses to magnet currents as from MADX...\n');
    Brho=unique(MADXtable(:,1));
    Idip=unique(MADXtable(:,3));
    Iqua=unique(MADXtable(:,4));
    K0L=unique(MADXtable(:,5));
    K1=unique(MADXtable(:,6));
    %%
    figure();
    % - K0L(Idip)
    subplot(1,2,1);
    P = polyfit(Idip,K0L*Brho,1);
    yfit = P(1)*Idip+P(2);
    plot(Idip,rad2deg(K0L),"ko",Idip,rad2deg(yfit/Brho),"r-");
    grid(); xlabel(sprintf("I_{%s} [A]",LabelMe(ParName))); ylabel("KOL [deg]");
    legend("MADX data",sprintf("fit: m=%.3E Tm/A; q=%.3E Tm;",P(1),P(2)),"Location","best");
    % - K1(Iquad)
    subplot(1,2,2);
    P = polyfit(Iqua,K1*Brho,1);
    yfit = P(1)*Iqua+P(2);
    plot(Iqua,K1,"ko",Iqua,yfit/Brho,"r-");
    grid(); xlabel(sprintf("I_{%s} [A]",LabelMe(ScanName))); ylabel("K1 [m^{-2}]");
    legend("MADX data",sprintf("fit: m=%.3E T/m/A; q=%.3E T/m;",P(1),P(2)),"Location","best");
end
