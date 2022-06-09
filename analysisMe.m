% {}~
%% TO DO
% - verifica range correnti MEBT quads and dipoles;
% - prepara un po' di cycodes (tutte le linee trattamento): p/C 30mm, 90mm, 270mm;
% - acquisisci misure (singolo scan, scan parametrizzato);
% - mostra raw data;
% - infos per scans in HEBT;

%% include libraries and other general settings
% - include Matlab libraries
pathToLibrary="externals\MatLabTools";
addpath(genpath(pathToLibrary));
% - include lib folder
pathToLibrary="lib";
addpath(genpath(pathToLibrary));
% - path to K:
kPath="S:\Accelerating-System\Accelerator-data";
% kPath="K:";
% - fitting options
optimoptions('lsqcurvefit','OptimalityTolerance',1E-12,'FunctionTolerance',1E-8);

%% summary materiale a disposizione:
% - BL(I) of MEBT main dipoles:
%   D:\VMs\vb_share\repos\optics\MEBT\materiale_SIMO\MEBT - Calcolo I_v3.xlsx
%   NB: it contains also the info that dipole 02 is M2-001A-IDB.
%       check sheet: Dipoles; compare range B3:B8 and J36:J41;
% - LPOW map (.xls files by RBasso, MEBT and HEBT):
%   D:\VMs\vb_share\repos\optics
% - TM currents:
%   S:\Accelerating-System\Accelerator-data\Area dati MD\00Setting\MEBT\MEBTTM.xls
% - MADX table columns:
%   * 1, 2: Brho [Tm] and BraggPeak position [mm];
%   * 3, 4 and 5: x, betx and dx @monitor [m];
%   * 6, 7 and 8: y, bety and dy @monitor [m];
%   * 9  and 10: Iquad [A] and K1 [m-2];
%   * 11 and 12: Idip [A] and K0L [rad] of scanning dipole;
%   * 13 and 14: Idip [A] and K0L [rad] of following dipole;

%% varie input
beamPart="PROTON";
% - beam stat quantities (for MADX predictions on measurements): MEBT
emiGeo=[ 4.813808E-6 2.237630E-6 ]; % [pi m rad]
sigdpp=3E-3; avedpp=-8.436E-3; % []
% - magnet mapping
magnetNames=[ 
    "M1-016A-QIB"  "M2-001A-IDB"  "M2-009A-QIB"  "M3-001A-IDB"     ... % MEBT
    "H2-022A-QUE"  "H3-003A-SW2"  "H3-009A-MBS"  "H3-015A-MBS"     ... % HEBT-hor (H2-H3)
    "H4-013A-QUE"  "V1-001A-SWV"  "V1-005A-MBU"                    ... % HEBT-ver (H4-V1)
    "H4-003A-QUE"  "H4-007A-QUE"                                   ... % HEBT H4 quads
    "H5-005A-QUE"  "H5-009A-QUE"  "H5-015A-QUE"                    ... % 
    "H2-016A-QUE"                                                  ... %
    ];
nickNames=[
    "M7"           "M1"           "M8"           "M2"              ... % MEBT
    "H10"          "H4"           "H6"           "H7"              ... % HEBT-hor (H2-H3)
    "H13"          "V1"           "V2"                             ... % HEBT-ver (H4-V1)
    "H11"          "H12"                                           ... % HEBT H4 quads
    "H14"          "H15"          "H16"                            ...
    "H9"                                                           ... %
    ];
LGENnames=[   
    "P5-011A-LGEN" "P5-005A-LGEN" "P5-012A-LGEN" "P5-006A-LGEN"    ... % MEBT
    "P7-010A-LGEN" "P7-004A-LGEN" "P7-006A-LGEN" "P7-007A-LGEN"    ... % HEBT-hor (H2-H3)
    "P7-013A-LGEN" "PA-003A-LGEN" "PA-004A-LGEN"                   ... % HEBT-ver (H4-V1)
    "P7-011A-LGEN" "P7-012A-LGEN"                                  ... % HEBT H4 quads
    "P7-014A-LGEN" "P7-015A-LGEN" "P7-016A-LGEN"                   ...
    "P7-009A-LGEN"                                                 ...
    ];
TMcurrsProt=[ ... % [A]
    40.0           124.25         25.0           124.93            ... % 46.5           125.5          25.0           125.93            ... % MEBT
    21.934         664.5          663.5          662.71            ... % 11.934         664.5          663.5          662.71            ... % HEBT-hor (H2-H3), Sala 2V, Prot, 90mm
    34.17          656.7          670.96                           ... % HEBT-ver (H4-V1), Sala 2V, Prot, 90mm
    43.06          54.345                                          ... % HEBT H4 quads
    25.5           25.5           30.34                            ... % 25.5           25.5           10.34
    30.0                                                           ... % 34.2                                                           ...
    ];
DGcurrMins=[ ... % [A]
    0.5            0.5            0.5            0.5               ... % MEBT
    0.5            60.0           60.0           60.0              ... % HEBT-hor (H2-H3)
    0.5            60.0           60.0                             ... % HEBT-ver (H4-V1)
    0.5            0.5                                             ... % HEBT H4 quads
    0.5            0.5            0.5                              ...
    0.5                                                            ...
    ];
DGcurrMaxs=[ ... % [A]
    150.0          300.0          150.0          300.0             ... % MEBT
    350.0          2000.0         2990.0         2990.0            ... % HEBT-hor (H2-H3)
    350.0          2000.0         2990.0                           ... % HEBT-ver (H4-V1)
    350.0          350.0                                           ... % HEBT H4 quads
    350.0          350.0          350.0                            ...
    350.0
    ];
% - cycle codes
myCyCode="240006cc0900"; % Sala 1, Prot, 90mm
% myCyCode="240002cc0900"; % Sala 2H, Prot, 90mm
% myCyCode="240004cc0100"; % Sala 2V, Prot, 90mm
% myCyCode="240000cc0900"; % Sala 3, Prot, 90mm

%% set up
% % M2
% scanMADname="externals\optics\MEBT\m2_scan.tfs";
% quadName="M1-016A-QIB";
% dipName="M2-001A-IDB";
% % M3
% scanMADname="externals\optics\MEBT\m3_scan.tfs";
% quadName="M2-009A-QIB";
% dipName="M3-001A-IDB";
% % M2-M3
% scanMADname="externals\optics\MEBT\m2m3_scan.tfs";
% quadName="M1-016A-QIB";
% dipName="M3-001A-IDB";
% all MEBT magnets of interest
MEBTmagnetNames=[ "M1-016A-QIB" "M2-001A-IDB" "M2-009A-QIB" "M3-001A-IDB" ];
% % H3, 2 dipoles
% scanMADname="externals\optics\HEBT\h3_scan_2dips.tfs";
% quadName="H2-022A-QUE";
% dipName="H3-003A-SW2";
% H3, 3 dipoles
scanMADname="externals\optics\HEBT\h3_scan_3dips.tfs";
quadName="H2-016A-QUE";
dipName="H3-003A-SW2";
% dipName="H3-009A-MBS";
% dipName="H3-015A-MBS";
% % V1
% scanMADname="externals\optics\HEBT\v1_scan.tfs";
% % quadName="H4-003A-QUE";
% quadName="H4-007A-QUE";
% % quadName="H4-013A-QUE";
% dipName="V1-001A-SWV";
% % dipName="V1-005A-MBU";
% % H5
% quadName="H5-009A-QUE";
%
HEBTmagnetNames=[ "H2-016A-QUE" "H3-003A-SW2" "H3-009A-MBS" "H3-015A-MBS" ];
% HEBTmagnetNames=[ "H4-013A-QUE" "V1-001A-SWV" "V1-005A-MBU" ];
% HEBTmagnetNames=[ "H4-007A-QUE" "V1-001A-SWV" "V1-005A-MBU" ];

%% main - MADX
% - acquire data
[MADXtable,MADXtableHeaders]=ReadMADXData(scanMADname);
ScanName=GetEleName(MADXtableHeaders(9));
ParNames=GetEleName(MADXtableHeaders(11:2:end)');
MonName=GetEleName(MADXtableHeaders(3));
MADXtitle=sprintf("MADX - %s - %s",LabelMe(ScanName),LabelMe(MonName));
% - convert MADX optics data into FWHMs and BARs
[MADxFWHMs,MADxBARs,MADxScanXs,MADxParXs]=MADXtoFWHMsBARs(MADXtable,emiGeo,sigdpp,avedpp);
% - show scans
ShowScans(MADxFWHMs,MADxBARs,MADxScanXs,MADxParXs,ScanName,ParNames(1),MADXtitle);
% - show MADX responses, i.e. KOL(Idip) and K1(Iqua);
ShowMADXResponses(MADXtable,ScanName,ParNames);
% - show responses, i.e. x,y(Idip), x,y(Iquad);
ShowResponses(MADxBARs,MADxScanXs,MADxParXs,ScanName,ParNames(1),MADXtitle);
% - show xy ellipses during scans
ShowEllipses(MADxFWHMs,MADxBARs,MADxScanXs,MADxParXs,ScanName,ParNames(1),MADXtitle);

%% main - create configuration files
% - paths
pathQuaAlone=sprintf("alone_%s",quadName);
pathDipAlone=sprintf("alone_%s",dipName);
pathCombined=sprintf("combined_%s_%s_correct",quadName,dipName);
pathQuaDipDip=sprintf("combined_%s_allDips",quadName);
% - LGEN files (ask all 4 LGENs in .xls file, such that used currents are logged in LPOW error log)
%   . quad alone: +/-15A around TM, 1A of step
CreateMeasFiles(pathQuaAlone,quadName,30,2,magnetNames,LGENnames,TMcurrsProt,DGcurrMaxs,DGcurrMins,beamPart,myCyCode,quadName,false);% ,HEBTmagnetNames,false);
%   . dipole alone: +/-10A around TM, 0.5A of step
CreateMeasFiles(pathDipAlone,dipName,14,2,magnetNames,LGENnames,TMcurrsProt,DGcurrMaxs,DGcurrMins,beamPart,myCyCode,dipName,false); % HEBTmagnetNames);
%    . combined quad-dip scan
CreateMeasFiles(pathCombined,[quadName dipName],[20 5],[1 1],magnetNames,LGENnames,TMcurrsProt,DGcurrMaxs,DGcurrMins,beamPart,myCyCode,MEBTmagnetNames);
%    . combined quad-dip-dip scan
CreateMeasFiles(pathQuaDipDip,["M1-016A-QIB" "M2-001A-IDB" "M3-001A-IDB"],[10 2.5 2.5],[0.5 0.5 0.5],magnetNames,LGENnames,TMcurrsProt,DGcurrMaxs,DGcurrMins,beamPart,myCyCode,MEBTmagnetNames);

% HEBT
% pathH3full=sprintf("combined_%s_allDips",quadName);
% CreateMeasFiles(pathH3full,HEBTmagnetNames,[15 5 5 5],[1 1 1 1],magnetNames,LGENnames,TMcurrsProt,DGcurrMaxs,DGcurrMins,part,myCyCode,HEBTmagnetNames,false);
CreateMeasFiles(pathQuaDipDip,HEBTmagnetNames,[20 4 4 4],[1 1 1 1],magnetNames,LGENnames,TMcurrsProt,DGcurrMaxs,DGcurrMins,beamPart,myCyCode,HEBTmagnetNames,false);

% 2 magnets scan at the same time
% values=GenerateLGENvalsAroundTM(TMcurrsProt,magnetNames,missing(),quadName,15,1);
% values=GenerateLGENvalsAroundTM(TMcurrsProt,magnetNames,DGcurrMaxs,dipName,5,5,true,values);
% nAPI=WriteLGENQAfile("myLGEN.xls",selectedLGENnames,values,DGcurrMaxs(indLGENs),DGcurrMins(indLGENs));
% WriteAPIfile("myApiFile.txt",nAPI,myCyCode);

%% Parse distributions
% - some user variables
beamPart="PROTON";
LPOWmonPath="LPOW_error_log";
config="TM"; % select configuration: TM, RFKO
dataParentPath="scambio\Alessio\GuessOptics\data";
machines=[ "LineZ" "LineZ" "LineZ" "LineZ" "LineZ" "LineZ" ...
           "LineV" "LineV" "LineV" "LineV" ...
           "LineU" "LineU" "LineT" "LineT" "LineZ" "LineZ" ...
           "LineU"];
profileDataPaths=[ 
    "090mm\HEBT\alone_H2-016A-QUE\PRC-544-220109-0357_H5-002B-SFM" ...
    "090mm\HEBT\alone_H2-022A-QUE\PRC-544-220108-2243_H3-011A-QBM" ...
    "090mm\HEBT\alone_H2-022A-QUE\PRC-544-220108-2304_H3-011A-QBM_TM" ...
    "090mm\HEBT\alone_H2-022A-QUE\PRC-544-220108-2250_H4-010B-SFM" ...
    "090mm\HEBT\alone_H2-022A-QUE\PRC-544-220108-2257_H4-018B-SFM" ...
    "090mm\HEBT\alone_H3-003A-SW2\PRC-544-220109-0411_H5-002B-SFM" ...
    "090mm\HEBT\alone_H4-003A-QUE\PRC-544-220108-2359_V1-007B-SFM" ...
    "090mm\HEBT\alone_H4-007A-QUE\PRC-544-220109-0009_V1-007B-SFM" ...
    "090mm\HEBT\alone_H4-013A-QUE\PRC-544-220108-2330_V1-007B-SFM" ...
    "090mm\HEBT\alone_V1-001A-SWV\PRC-544-220109-0022_V1-007B-SFM" ...
    "090mm\HEBT\alone_H5-009A-QUE\PRC-544-220109-0259_U1-021B-SFM" ...
    "090mm\HEBT\alone_H5-009A-QUE\PRC-544-220109-0303_U1-005B-SFM" ...
    "090mm\HEBT\alone_H5-009A-QUE\PRC-544-220109-0316_T1-007B-SFM" ...
    "090mm\HEBT\alone_H5-009A-QUE\PRC-544-220109-0321_T1-016B-SFM" ...
    "090mm\HEBT\alone_H5-009A-QUE\PRC-544-220109-0329_Z1-007B-SFM" ...
    "090mm\HEBT\alone_H5-009A-QUE\PRC-544-220109-0334_Z1-016B-SFM" ...
    "090mm\HEBT\alone_H5-015A-QUE\PRC-544-220109-0254_U1-021B-SFM" ...
    ];
scanMagnets=[
    "H2-016A-QUE" ...                                           % setting up H2-H3 combined scans
    "H2-022A-QUE" "H2-022A-QUE" "H2-022A-QUE" "H2-022A-QUE" ... %
    "H3-003A-SW2"                                           ... % 
    "H4-003A-QUE" "H4-007A-QUE" "H4-013A-QUE" "V1-001A-SWV" ... % setting up V1 combined scans
    "H5-009A-QUE" "H5-009A-QUE" "H5-009A-QUE" "H5-009A-QUE" "H5-009A-QUE" "H5-009A-QUE" ...  % setting up H5-T1/U1/Z1 combined scans
    "H5-015A-QUE" 
    ];
parMagnets=[
    missing() ...
    missing()      missing()     missing()     missing() ...
    missing() ...
    missing()      missing()     missing()     missing() ...
    missing()      missing()     missing()     missing()     missing()     missing() ...
    missing()
    ];
monitors=[
    "H5-002B-SFM" ...
    "H3-011A-QBM" "H3-011A-QBM" "H4-010B-SFM" "H4-018B-SFM" ...
    "H5-002B-SFM" ...
    "V1-007B-SFM" "V1-007B-SFM" "V1-007B-SFM" "V1-007B-SFM" ...
    "U1-021B-SFM" "U1-005B-SFM" "T1-007B-SFM" "T1-016B-SFM" "Z1-007B-SFM" "Z1-016B-SFM" ...
    "U1-021B-SFM" ...
    ];
currentFiles=[
    "090mm\HEBT\alone_H2-016A-QUE\LGEN_PROTON_alone_H2-016A-QUE.xls"
    "090mm\HEBT\alone_H2-022A-QUE\LGEN_PROTON_alone_H2-022A-QUE.xls"
    "090mm\HEBT\alone_H2-022A-QUE\LGEN_PROTON_alone_H2-022A-QUE.xls"
    "090mm\HEBT\alone_H2-022A-QUE\LGEN_PROTON_alone_H2-022A-QUE.xls"
    "090mm\HEBT\alone_H2-022A-QUE\LGEN_PROTON_alone_H2-022A-QUE.xls"
    "090mm\HEBT\alone_H3-003A-SW2\LGEN_PROTON_alone_H3-003A-SW2.xls"
    ""
    ""
    ""
    ""
    "090mm\HEBT\alone_H5-009A-QUE\LGEN_PROTON_alone_H5-009A-QUE.xls"
    "090mm\HEBT\alone_H5-009A-QUE\LGEN_PROTON_alone_H5-009A-QUE.xls"
    "090mm\HEBT\alone_H5-009A-QUE\LGEN_PROTON_alone_H5-009A-QUE.xls"
    "090mm\HEBT\alone_H5-009A-QUE\LGEN_PROTON_alone_H5-009A-QUE.xls"
    "090mm\HEBT\alone_H5-009A-QUE\LGEN_PROTON_alone_H5-009A-QUE.xls"
    "090mm\HEBT\alone_H5-009A-QUE\LGEN_PROTON_alone_H5-009A-QUE.xls"
    "090mm\HEBT\alone_H5-009A-QUE\LGEN_PROTON_alone_H5-009A-QUE.xls"
    ];
indices=zeros(2,2,length(profileDataPaths));
indices(1,:,1)=[3,33]; indices(2,:,1)=[1,31];
indices(1,:,2)=[3,43]; indices(2,:,2)=[1,41];
indices(1,:,3)=[3,43]; indices(2,:,3)=[1,41];
indices(1,:,4)=[3,43]; indices(2,:,4)=[1,41];
indices(1,:,5)=[3,43]; indices(2,:,5)=[1,41];
indices(1,:,6)=[3,17]; indices(2,:,6)=[1,15];
indices(1,:,11)=[3,43]; indices(2,:,11)=[1,41];
indices(1,:,12)=[3,43]; indices(2,:,12)=[1,41];
indices(1,:,13)=[3,43]; indices(2,:,13)=[1,41];
indices(1,:,14)=[3,43]; indices(2,:,14)=[1,41];
indices(1,:,15)=[3,43]; indices(2,:,15)=[1,41];
indices(1,:,16)=[3,43]; indices(2,:,16)=[1,41];
%
fitIndices=zeros(2,2,length(profileDataPaths)); % 1: min/max; 2:hor/ver; 3:measurement;
fitIndices(:,1,11)=[ 27 37 ]; fitIndices(:,2,11)=[ 18 25 ];
fitIndices(:,1,12)=[ 27 41 ]; fitIndices(:,2,12)=[ 10 23 ];
fitIndices(:,1,13)=[ 28 41 ]; fitIndices(:,2,13)=[ 13 27 ];
fitIndices(:,1,14)=[ 24 34 ]; fitIndices(:,2,14)=[ 16 27 ];
fitIndices(:,1,15)=[ 29 41 ]; fitIndices(:,2,15)=[ 13 27 ];
% 
MADRmatFileNames=[
    ""
    ""
    ""
    ""
    ""
    ""
    ""
    ""
    ""
    ""
    "externals\optics\HEBT\h5_009a_que_scan_u1_021b_sfh_remat.tfs"
    "externals\optics\HEBT\h5_009a_que_scan_u1_005b_sfh_remat.tfs"
    "externals\optics\HEBT\h5_009a_que_scan_t1_007b_sfh_remat.tfs"
    "externals\optics\HEBT\h5_009a_que_scan_t1_016b_sfh_remat.tfs"
    "externals\optics\HEBT\h5_009a_que_scan_z1_007b_sfh_remat.tfs"
    ""
    ];
%
%% single set
% - select data set
iSet=15;
%
% - inflate some variables
if ( ismissing(parMagnets(iSet)) )
    myTitle=sprintf("%s alone",LabelMe(scanMagnets(iSet)));
    myFigName=sprintf("%s_alone",scanMagnets(iSet));
else
    myTitle=sprintf("scan: %s - param: %s",LabelMe(scanMagnets(iSet)),LabelMe(parMagnets(iSet)));
    myFigName=sprintf("%s_%s",scanMagnets(iSet),parMagnets(iSet));
end
myTitle=LabelMe(sprintf("%s - monitor: %s",myTitle,monitors(iSet)));
myFigName=sprintf("%s_%s",myFigName,monitors(iSet));
dataPath=sprintf("%s\\%s\\%s\\%s",kPath,dataParentPath,beamPart,profileDataPaths(iSet));
monType=upper(split(monitors(iSet),"-")); monType=monType(end);
LPOWmonPaths=sprintf("%s\\%s\\%s\\2022-01-*\\*.txt",kPath,dataParentPath,LPOWmonPath);
[selectedLGENnames,indLGENs]=ReturnLGENnames(magnetNames,LGENnames,scanMagnets(iSet));
%
% CLEAR EXISTING DATA
clear measData cyCodes cyProgs sumData BARs FWHMs INTs LGENnamesXLS nDataCurr IsXLS tableIs;
%
% ACTUALLY DO THE JOB!
[measData,cyCodes,cyProgs]=...                           % parse SFM/QBM data
    ParseSFMData(sprintf("%s\\Data*%s.csv",dataPath,monType),monType);
sumData=SumSpectra(measData);                            % get summary profiles
ShowSpectra(sumData,myTitle);                            % 3D plots
% ShowSpectra(sumData,myTitle,cyProgs,"cyProg");           % 3D plots
saveas(gcf,myFigName);
[BARs,FWHMs,INTs]=StatDistributionsBDProcedure(sumData); % first statistical analysis (as BD procedure)
tmpX=reshape(measData(:,1,1:2,1),[size(measData,1) 2]);
myMask=ReturnMask(iSet,tmpX);
% myMask=ReturnMask(-1,tmpX);
fracEst=0.5:0.1:0.9;
[AdvBARs,AdvFWHMs,AdvINTs,advFWxMls,advFWxMrs]=StatDistributions(sumData,fracEst,0.12,missing(),myMask);
ShowScanRawPlots(missing(),AdvFWHMs(:,:,fracEst==0.5),AdvBARs,AdvINTs,size(AdvFWHMs,1),scanMagnets(iSet),monitors(iSet));
FWxMPlots(missing(),AdvFWHMs,AdvBARs,fracEst,indices(:,:,iSet),sprintf("%s - FWxM",scanMagnets(iSet)),monitors(iSet));
FWxMPlots(missing(),advFWxMls,AdvBARs,fracEst,indices(:,:,iSet),sprintf("%s - left HWxM",scanMagnets(iSet)),monitors(iSet),false);
FWxMPlots(missing(),advFWxMrs,AdvBARs,fracEst,indices(:,:,iSet),sprintf("%s - right HWxM",scanMagnets(iSet)),monitors(iSet),false);
compBARs=BARs; compSigmas=GetReducedFWxM(FWHMs,0.5,true); compINTs=INTs; compIndices=indices(2,:,iSet);
compBARs(:,:,2)=AdvBARs; compSigmas(:,:,2)=GetReducedFWxM(AdvFWHMs(:,:,fracEst==0.8),0.8,true); compINTs(:,:,2)=AdvINTs;
CompareStats(compBARs,compSigmas,compINTs,compIndices,["BD" "adv"]);
% - acquire .xls of scan
currentPath=sprintf("%s\\%s\\%s\\%s",kPath,dataParentPath,beamPart,currentFiles(iSet));
[IsXLS,LGENnamesXLS,nDataCurr]=AcquireCurrentData(currentPath);
% - show raw data
ShowScanRawPlots(IsXLS(1:nDataCurr,LGENnamesXLS==selectedLGENnames),FWHMs,BARs,INTs,size(FWHMs,1),scanMagnets(iSet),monitors(iSet));
ShowScanRawPlots(IsXLS(1:nDataCurr,LGENnamesXLS==selectedLGENnames),FWHMs,BARs,INTs,size(FWHMs,1),scanMagnets(iSet),monitors(iSet),myFigName);
% - get TM currents
[cyCodesTM,rangesTM,EksTM,BrhosTM,currentsTM,fieldsTM,kicksTM,psNamesTM,FileNameCurrentsTM]=AcquireLGENValues(beamPart,machines(iSet),config);
psNamesTM=string(psNamesTM);
cyCodesTM=upper(string(cyCodesTM));
% - parse LPOW monitor log
[tStampsLPOWMon,LGENsLPOWMon,LPOWsLPOWMon,racksLPOWMon,repoValsLPOWMon,appValsLPOWMon,cyCodesLPOWMon,cyProgsLPOWMon,endCycsLPOWMon]=ParseLPOWLog(LPOWmonPaths);
% - cyProgs of LPOWmon are off!!!!
if ( ~ismissing(LGENsLPOWMon) )
    cyProgsLPOWMon=string(str2double(cyProgsLPOWMon)+1);
end
% - build table of currents
[tableIs]=BuildCurrentTable(cyCodes,cyProgs,selectedLGENnames,IsXLS,LGENnamesXLS,psNamesTM,cyCodesTM,currentsTM,LGENsLPOWMon,cyProgsLPOWMon,appValsLPOWMon,indices(:,:,iSet));
% - show data aligned
ShowScanAligned(IsXLS(1:nDataCurr,LGENnamesXLS==selectedLGENnames),FWHMs,BARs,indices(:,:,iSet),scanMagnets(iSet),monitors(iSet),myFigName);
ShowScanAligned(IsXLS(1:nDataCurr,LGENnamesXLS==selectedLGENnames),AdvFWHMs,AdvBARs,indices(:,:,iSet),scanMagnets(iSet),monitors(iSet));

return
for ii=1:size(measData,4)
    ShowSpectra(measData(:,:,:,ii),myTitle);
    pause();
end
myID=2;
ShowSpectra(measData(:,:,:,myID),sprintf("%s - ID=%d",myTitle,myID));
myID=38;
ShowSpectra(measData(:,:,:,myID),sprintf("%s - ID=%d",myTitle,myID));

%% aggregati di scansioni (plot 1x3x2) - acquisisci dati
nRows=1; nCols=3; nSetsPerPlot=2;
mySets=zeros(nRows,nCols,nSetsPerPlot);
mySets(1,1,1)=15; mySets(1,1,2)=16; % lineZ
mySets(1,2,1)=12; mySets(1,2,2)=11; % lineU
mySets(1,3,1)=13; mySets(1,3,2)=14; % lineT
myMonitors=strings(nRows,nCols,nSetsPerPlot);
% myIndices=zeros(2,nRows,nCols,nSetsPerPlot);
for iRowSet=1:nRows
    for iColSet=1:nCols
        for iDataSet=1:nSetsPerPlot
            myMonitors(iRowSet,iColSet,iDataSet)=monitors(mySets(iRowSet,iColSet,iDataSet));
            % myIndices(:,iRowSet,iColSet,iDataSet)=indices(2,:,mySets(iRowSet,iColSet,iDataSet));
        end
    end
end

lFirst=true;
nMeasData=zeros(size(mySets));
% % CLEAR EXISTING DATA
% clear measData cyCodes cyProgs sumData BARs FWHMs INTs IsXLS LGENnamesXLS nDataCurr;
measData=NaN(); cyCodes=strings(1); cyProgs=NaN(); sumData=NaN(); BARs=NaN(); FWHMs=NaN(); INTs=NaN(); IsXLS=NaN(); LGENnamesXLS=NaN(); nDataCurr=NaN(); 
for iRowSet=1:nRows
    for iColSet=1:nCols
        for iDataSet=1:nSetsPerPlot
            if ( ~lFirst ), clear tmpMeasData tmpCyCodes tmpCyProgs tmpSumData tmpBARs tmpFWHMs tmpINTs; end
            % acquire profiles
            dataPath=sprintf("%s\\%s\\%s\\%s",kPath,dataParentPath,beamPart,profileDataPaths(mySets(iRowSet,iColSet,iDataSet)));
            monType=upper(split(monitors(iSet),"-")); monType=monType(end);
            % parse SFM/QBM data
            [tmpMeasDataT,tmpCyCodesT,tmpCyProgsT]=...
                ParseSFMData(sprintf("%s\\Data*%s.csv",dataPath,monType),monType);
            
            % select only actual data set
            myFilterMeasIDs=indices(2,1,mySets(iRowSet,iColSet,iDataSet)):indices(2,2,mySets(iRowSet,iColSet,iDataSet));
            tmpMeasData=tmpMeasDataT(:,:,:,myFilterMeasIDs);
            tmpCyCodes=tmpCyCodesT(myFilterMeasIDs);
            tmpCyProgs=tmpCyProgsT(myFilterMeasIDs);
            
            % get summary profiles
            tmpSumData=SumSpectra(tmpMeasData);
            % first statistical analysis (as BD procedure)
            [tmpBARs,tmpFWHMs,tmpINTs]=StatDistributionsBDProcedure(tmpSumData);
            
            % acquire .xls of scan
            if ( lFirst )
                currentPath=sprintf("%s\\%s\\%s\\%s",kPath,dataParentPath,beamPart,currentFiles(mySets(iRowSet,iColSet,iDataSet)));
                [IsXLSt,LGENnamesXLS,nDataCurr]=AcquireCurrentData(currentPath);
                % select only actual data set
                IsXLS=IsXLSt(indices(1,1,mySets(iRowSet,iColSet,iDataSet)):indices(1,2,mySets(iRowSet,iColSet,iDataSet)));
                % myIndicesIs=indices(1,:,mySets(iRowSet,iColSet,iDataSet));
                myScanMagnet=scanMagnets(mySets(iRowSet,iColSet,iDataSet));
                lFirst=false;
            end
            
            % storage
            measData=CopyMe(tmpMeasData,measData,iRowSet,iColSet,iDataSet);
            cyCodes=CopyMe(tmpCyCodes,cyCodes,iRowSet,iColSet,iDataSet);
            cyProgs=CopyMe(tmpCyProgs,cyProgs,iRowSet,iColSet,iDataSet);
            sumData=CopyMe(tmpSumData,sumData,iRowSet,iColSet,iDataSet);
            BARs=CopyMe(tmpBARs,BARs,iRowSet,iColSet,iDataSet);
            FWHMs=CopyMe(tmpFWHMs,FWHMs,iRowSet,iColSet,iDataSet);
            INTs=CopyMe(tmpINTs,INTs,iRowSet,iColSet,iDataSet);
        end
    end
end

%% aggregati di scansioni (plot 1x3x2) - mostra dati
% CompareSpectraSingleShot(IsXLS,sumData,myScanMagnet,myMonitors);%,myIndices,myIndicesIs);
CompareSpectra(IsXLS,sumData,myScanMagnet,myMonitors);%,myIndices,myIndicesIs);

%% aggregati di scans (plot 2x2xN) - acquisisci dati
mySets=12; %[ 15 12 11 13 14 ]; 
myMonitors=monitors(mySets)';
fracEst=0.5:0.1:0.9;
% CLEAR EXISTING DATA
clear measData cyCodes cyProgs sumData AdvBARs AdvFWHMs AdvINTs advFWxMls advFWxMrs;
for iMySet=1:length(mySets)
    % acquire profiles
    dataPath=sprintf("%s\\%s\\%s\\%s",kPath,dataParentPath,beamPart,profileDataPaths(mySets(iMySet)));
    monType=upper(split(myMonitors(iMySet),"-")); monType=monType(end);
    % parse SFM/QBM data
    [tmpMeasDataT,tmpCyCodesT,tmpCyProgsT]=...
        ParseSFMData(sprintf("%s\\Data*%s.csv",dataPath,monType),monType);

    % select only actual data set
    myFilterMeasIDs=indices(2,1,mySets(iMySet)):indices(2,2,mySets(iMySet));
    measData(:,:,:,:,iMySet)=tmpMeasDataT(:,:,:,myFilterMeasIDs);
    cyCodes(:,iMySet)=tmpCyCodesT(myFilterMeasIDs);
    cyProgs(:,iMySet)=tmpCyProgsT(myFilterMeasIDs);

    % get summary profiles
    sumData(:,:,:,iMySet)=SumSpectra(measData(:,:,:,:,iMySet));
    % statistical analysis
    tmpX=reshape(measData(:,1,1:2,1,iMySet),[size(measData(:,1,1:2,1,iMySet),1) 2]);
    myMask=ReturnMask(mySets(iMySet),tmpX);
    [AdvBARs(:,:,iMySet),AdvFWHMs(:,:,:,iMySet),AdvINTs(:,:,iMySet),advFWxMls(:,:,:,iMySet),advFWxMrs(:,:,:,iMySet)]=StatDistributions(sumData(:,:,:,iMySet),fracEst,0.12,missing(),myMask,false);
    
end
% acquire .xls of scan
currentPath=sprintf("%s\\%s\\%s\\%s",kPath,dataParentPath,beamPart,currentFiles(mySets(iMySet)));
[IsXLSt,LGENnamesXLS,nDataCurr]=AcquireCurrentData(currentPath);
% select only actual data set
IsXLS=IsXLSt(indices(1,1,mySets(iMySet)):indices(1,2,mySets(iMySet)));
myScanMagnet=scanMagnets(mySets(iMySet));

%%  aggregati di scans (plot 1x2) - mostra dati
figure();
planes=["HOR" "VER"];
iPlot=0;
% sigmas
for iPlane=1:length(planes)
    iPlot=iPlot+1;
    ax(iPlot)=subplot(2,2,iPlot);
    for iMySet=1:length(mySets)
        if ( iMySet>1 ), hold on; end
        myFilterIDs=fitIndices(1,iPlane,mySets(iMySet)):fitIndices(2,iPlane,mySets(iMySet));
        plot(IsXLS(myFilterIDs),GetReducedFWxM(AdvFWHMs(myFilterIDs,iPlane,fracEst==0.8,iMySet),0.8,true),"*-");
        % plot(myFilterIDs,GetReducedFWxM(AdvFWHMs(myFilterIDs,iPlane,fracEst==0.8,iMySet),0.8,true),"*-");
        grid on; ylabel("\sigma [mm]"); legend(myMonitors,"Location","best");
    end
    title(sprintf("%s plane",planes(iPlane)));
end
% baricentres
for iPlane=1:length(planes)
    iPlot=iPlot+1;
    ax(iPlot)=subplot(2,2,iPlot);
    for iMySet=1:length(mySets)
        if ( iMySet>1 ), hold on; end
        myFilterIDs=fitIndices(1,iPlane,mySets(iMySet)):fitIndices(2,iPlane,mySets(iMySet));
        plot(IsXLS(myFilterIDs),AdvBARs(myFilterIDs,iPlane,iMySet),"*-");
        % plot(myFilterIDs,AdvBARs(myFilterIDs,iPlane,iMySet),"*-");
        grid on; ylabel("BAR [mm]"); legend(myMonitors,"Location","best");
        xlabel("I [A]");
        % xlabel("ID []");
    end
end
linkaxes(ax,"x");
sgtitle(sprintf("%s",LabelMe(myScanMagnet)));

%% fit per ricostruire ottica - acquisisci dati
nn=[0 0];
planes=["H" "V"];
% CLEAR EXISTING DATA
clear rMatrix TM TT SS;
for iMySet=1:length(mySets)
    % acquire file with scans of response matrices
    reMatFileName=MADRmatFileNames(mySets(iMySet));
    fprintf('parsing file %s ...\n',reMatFileName);
    rMatrix = readmatrix(reMatFileName,'HeaderLines',1,'Delimiter',',','FileType','text');
    
    % compute necessary matrices and arrays
    for iPlane=1:length(planes)
        myFilterIDs=fitIndices(1,iPlane,mySets(iMySet)):fitIndices(2,iPlane,mySets(iMySet));
        nData=length(myFilterIDs);
        TM(:,:,nn(iPlane)+1:nn(iPlane)+nData,iPlane)=GetTransMatrix(rMatrix(myFilterIDs,:),planes(iPlane),"SCAN");
        TT(nn(iPlane)+1:nn(iPlane)+nData,iPlane)=AdvBARs(myFilterIDs,iPlane,iMySet);
        SS(nn(iPlane)+1:nn(iPlane)+nData,iPlane)=GetReducedFWxM(AdvFWHMs(myFilterIDs,iPlane,fracEst==0.8,iMySet),0.8,true);
        nn(iPlane)=nn(iPlane)+nData;
    end
end

%% fit per ricostruire ottica - fai il fit
% CLEAR EXISTING DATA
clear beta0 alpha0 emiG z pz;
% solve systems
for iPlane=1:length(planes)
    % only betatron fit
    [beta0(iPlane),alpha0(iPlane),emiG(iPlane),~,~,~]=FitOpticsThroughSigmaData(TM(1:2,1:2,:,iPlane),SS(:,iPlane));
    [z(iPlane),pz(iPlane),~]=FitOpticsThroughOrbitData(TM(1:2,1:2,:,iPlane),TT(:,iPlane));
end

%% funzioni

function CompareSpectraSingleShot(IsXLS,sumData,myScanMagnet,myMonitors,myIndices)%,myIndices,myIndicesIs)
    planes=[ "HOR plane" "VER plane"];
    if ( ~exist('myIndices','var') ), myIndices=1:size(sumData,2)-1; end
    nRows=size(sumData,4);
    nCols=size(sumData,5);
    nSetsPerPlot=size(sumData,6);
    ff=figure();
    % iCurr=myIndicesIs(1):myIndicesIs(2);
    % yMax=max(sumData,[],"all"); yMin=0;
    for iScan=myIndices%length(iCurr)
        for iPlane=1:2
            yMax=max(sumData(:,1+iScan,iPlane,:,:,:),[],"all"); yMin=0;
            if ( iPlane==1 ), iPlot=0; else iPlot=nCols*nRows; end
            for iRowSet=1:nRows
                for iColSet=1:nCols
                    iPlot=iPlot+1;
                    subplot(2*nRows,nCols,iPlot);
                    for iDataSet=1:nSetsPerPlot
                        if ( iDataSet>1 ), hold on; end
                        % mySel=myIndices(1,iRowSet,iColSet,iDataSet)+iScan-1;
                        % plot(sumData(:,1,iPlane,iRowSet,iColSet,iDataSet),sumData(:,1+mySel,iPlane,iRowSet,iColSet,iDataSet),"*-");
                        plot(sumData(:,1,iPlane,iRowSet,iColSet,iDataSet),sumData(:,1+iScan,iPlane,iRowSet,iColSet,iDataSet),"*-");
                    end
                    grid on; xlabel("fiber position [mm]"); ylabel("counts []"); title(planes(iPlane));
                    legend(myMonitors(iRowSet,iColSet,:),"Location","best");
                    ylim([yMin yMax]);
                    hold off;
                end
            end
        end
        % sgtitle(sprintf("I_{%s}=%g A",LabelMe(myScanMagnet),IsXLS(iCurr(iScan))));
        sgtitle(sprintf("I_{%s}=%g A (ID=%d)",LabelMe(myScanMagnet),IsXLS(iScan),iScan));
        pause();
    end
end

function CompareSpectra(IsXLS,sumData,myScanMagnet,myMonitors,myIndices)%,myIndices,myIndicesIs)
    planes=[ "HOR plane" "VER plane"];
    if ( ~exist('myIndices','var') ), myIndices=1:size(sumData,2)-1; end
    nRows=size(sumData,4);
    nCols=size(sumData,5);
    nSetsPerPlot=size(sumData,6);
    cm=colormap(parula(length(myIndices)));
    % iCurr=myIndicesIs(1):myIndicesIs(2);
    % yMax=max(sumData,[],"all"); yMin=0;
    for iPlane=1:2
        ff=figure();
        iPlot=0;
        for iRowSet=1:nRows
            for iDataSet=1:nSetsPerPlot
                for iColSet=1:nCols
                    iPlot=iPlot+1;
                    subplot(nRows*nSetsPerPlot,nCols,iPlot);
                    for iScan=myIndices
                        if ( iScan>1 ), hold on; end
                        Plot3D(sumData(:,1,iPlane,iRowSet,iColSet,iDataSet),sumData(:,1+iScan,iPlane,iRowSet,iColSet,iDataSet),iScan,cm(iScan,:));
                    end
                    grid on; xlabel("[mm]"); ylabel("ID []"); zlabel("counts []"); title(myMonitors(iRowSet,iColSet,iDataSet));
                end
            end
        end
        sgtitle(sprintf("%s - %s",LabelMe(myScanMagnet),planes(iPlane)));
    end
end

function Plot3D(xx,yy,iSet,color)
    plotX=xx;
    if ( size(plotX,2)== 1 )
        plotX=plotX';
    end
    plotY=yy;
    if ( size(plotY,2)== 1 )
        plotY=plotY';
    end
    % get non-zero values
    indices=(plotY~=0.0);
    plotX=plotX(indices);
    plotY=plotY(indices);
    nn=size(plotX,2);
    zz=iSet*ones(1,nn);
    plot3(plotX,zz,plotY,"color",color);%,'FaceAlpha',0.3,'EdgeColor',color);
end

function [matrOut]=CopyMe(matrIn,matrOut,iRowSet,iColSet,iDataSet)
    switch length(size(matrIn))
        case 2
            if ( size(matrIn,2)==1 )
                % actually, one dimension only
                matrOut(1:size(matrIn,1),iRowSet,iColSet,iDataSet)= ...
                 matrIn(1:size(matrIn,1));
            else
                matrOut(1:size(matrIn,1),1:size(matrIn,2),iRowSet,iColSet,iDataSet)= ...
                 matrIn(1:size(matrIn,1),1:size(matrIn,2));
            end
        case 3
            matrOut(1:size(matrIn,1),1:size(matrIn,2),1:size(matrIn,3),iRowSet,iColSet,iDataSet)=...
             matrIn(1:size(matrIn,1),1:size(matrIn,2),1:size(matrIn,3));
        case 4
            matrOut(1:size(matrIn,1),1:size(matrIn,2),1:size(matrIn,3),1:size(matrIn,4),iRowSet,iColSet,iDataSet)=...
             matrIn(1:size(matrIn,1),1:size(matrIn,2),1:size(matrIn,3),1:size(matrIn,4));
        otherwise
            error("...please increase number of handled dimensions!");
    end
end

%% tests vari

%% functions
