function ShowMADXResponses(MADXtable,MADXtableHeaders)
    fprintf('plotting responses to magnet currents as from MADX...\n');
    Idip=unique(MADXtable(:,3)); Iqua=unique(MADXtable(:,4)); Brho=unique(MADXtable(:,1));
    dipName=GetEleName(MADXtableHeaders(3)); quaName=GetEleName(MADXtableHeaders(4));
    %
    figure();
    % K0L(Idip)
    subplot(2,3,1);
    K0L=unique(MADXtable(:,5));
    P = polyfit(Idip,K0L*Brho,1);
    yfit = P(1)*Idip+P(2);
    plot(Idip,rad2deg(K0L),"ko",Idip,rad2deg(yfit/Brho),"r-");
    grid(); xlabel(sprintf("I_{%s} [A]",LabelMe(dipName))); ylabel("KOL [deg]");
    legend("MADX data",sprintf("fit: m=%.3E Tm/A; q=%.3E Tm;",P(1),P(2)),"Location","best");
    % x(Idip)
    subplot(2,3,2);
    Xs=MADXtable(:,3); Ys=MADXtable(:,7)*1E3;
    P = polyfit(Xs,Ys,1);
    yfit = P(1)*Xs+P(2);
    plot(Xs,Ys,"ko",Xs,yfit,"r-");
    grid(); xlabel(sprintf("I_{%s} [A]",LabelMe(dipName))); ylabel("x [mm]");
    legend("MADX data",sprintf("fit: m=%.3E mm/A; q=%.3E mm;",P(1),P(2)),"Location","best");
    % y(Idip)
    subplot(2,3,3);
    Xs=MADXtable(:,3); Ys=MADXtable(:,10)*1E3;
    P = polyfit(Xs,Ys,1);
    yfit = P(1)*Xs+P(2);
    plot(Xs,Ys,"ko",Xs,yfit,"r-");
    grid(); xlabel(sprintf("I_{%s} [A]",LabelMe(dipName))); ylabel("y [mm]");
    legend("MADX data",sprintf("fit: m=%.3E mm/A; q=%.3E mm;",P(1),P(2)),"Location","best");
    % K1(Iquad)
    subplot(2,3,4);
    K1=unique(MADXtable(:,6));
    P = polyfit(Iqua,K1*Brho,1);
    yfit = P(1)*Iqua+P(2);
    plot(Iqua,K1,"ko",Iqua,yfit/Brho,"r-");
    grid(); xlabel(sprintf("I_{%s} [A]",LabelMe(quaName))); ylabel("K1 [m^{-2}]");
    legend("MADX data",sprintf("fit: m=%.3E T/m/A; q=%.3E T/m;",P(1),P(2)),"Location","best");
    % x(Idip)
    subplot(2,3,5);
    Xs=MADXtable(:,4); Ys=MADXtable(:,7)*1E3;
    P = polyfit(Xs,Ys,1);
    yfit = P(1)*Xs+P(2);
    plot(Xs,Ys,"ko",Xs,yfit,"r-");
    grid(); xlabel(sprintf("I_{%s} [A]",LabelMe(quaName))); ylabel("x [mm]");
    legend("MADX data",sprintf("fit: m=%.3E mm/A; q=%.3E mm;",P(1),P(2)),"Location","best");
    % y(Idip)
    subplot(2,3,6);
    Xs=MADXtable(:,4); Ys=MADXtable(:,10)*1E3;
    P = polyfit(Xs,Ys,1);
    yfit = P(1)*Xs+P(2);
    plot(Xs,Ys,"ko",Xs,yfit,"r-");
    grid(); xlabel(sprintf("I_{%s} [A]",LabelMe(quaName))); ylabel("y [mm]");
    legend("MADX data",sprintf("fit: m=%.3E mm/A; q=%.3E mm;",P(1),P(2)),"Location","best");
end
