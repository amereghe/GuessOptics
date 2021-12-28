% {}~
%% include libraries and other general settings
% % - include Matlab libraries
% pathToLibrary="externals\MatLabTools";
% addpath(genpath(pathToLibrary));
% % - include lib folder
% pathToLibrary="lib";
% addpath(genpath(pathToLibrary));
% % - path to K:
% kPath="S:\Accelerating-System\Accelerator-data";
% % kPath="K:";
% % - fitting options
% optimoptions('lsqcurvefit','OptimalityTolerance',1E-12,'FunctionTolerance',1E-8);

%% summary materiale a disposizione:
% - BL(I) of MEBT main dipoles:
%   D:\VMs\vb_share\repos\optics\MEBT\materiale_SIMO\MEBT - Calcolo I_v3.xlsx
% - MADX table columns:
%   * 1: Brho [Tm];
%   * 3 and 4: Idip and Iquad [A];
%   * 7, 8 and 9: x, betx and dx @monitor [m];
%   * 10, 11 and 12 : y, bety and dy @monitor [m];

%% varie input
emiGeo=[ 4.813808E-6 2.237630E-6 ]; % [pi m rad]
sigdpp=3E-3; avedpp=-8.436E-3; % []

%% main
% - acquire MADX data
[MADXtable,MADXtableHeaders]=ReadMADXData("externals\optics\MEBT\m2_scan.tfs");
% - show MADX scans
ShowMADXScans(MADXtable,MADXtableHeaders,emiGeo,sigdpp,avedpp);
% - show MADX responses (i.e. KOL(Idip), K1(Iqua), x,y(Idip), x,y(Iquad);
ShowMADXResponses(MADXtable,MADXtableHeaders);
% - show xy ellipses during scan
ShowMADXEllipses(MADXtable,emiGeo,sigdpp,avedpp);

%% functions

