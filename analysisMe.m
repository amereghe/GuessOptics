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
LPOWmonPath="LPOW_error_log";
machine="LineZ";
config="TM"; % select configuration: TM, RFKO
dataParentPath="scambio\Alessio\GuessOptics\data";
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
    "090mm\HEBT\alone_H5-015A-QUE\PRC-544-220109-0254_U1-021B-SFM" ...
    ];
scanMagnets=[
    "H2-016A-QUE" ...                                           % setting up H2-H3 combined scans
    "H2-022A-QUE" "H2-022A-QUE" "H2-022A-QUE" "H2-022A-QUE" ... %
    "H3-003A-SW2"                                           ... % 
    "H4-003A-QUE" "H4-007A-QUE" "H4-013A-QUE" "V1-001A-SWV" ... % setting up V1 combined scans
    "H5-009A-QUE" "H5-015A-QUE" ...                             % setting up H5-T1/U1/Z1 combined scans
    ];
parMagnets=[
    missing() ...
    missing()      missing()     missing()     missing() ...
    missing() ...
    missing()      missing()     missing()     missing() ...
    missing()      missing() ...
    ];
monitors=[
    "H5-002B-SFM" ...
    "H3-011A-QBM" "H3-011A-QBM" "H4-010B-SFM" "H4-018B-SFM" ...
    "H5-002B-SFM" ...
    "V1-007B-SFM" "V1-007B-SFM" "V1-007B-SFM" "V1-007B-SFM" ...
    "U1-021B-SFM" "U1-021B-SFM" ...
    ];
currentFiles=[
    "090mm\HEBT\alone_H2-016A-QUE\LGEN_PROTON_alone_H2-016A-QUE.xls"
    "090mm\HEBT\alone_H2-022A-QUE\LGEN_PROTON_alone_H2-022A-QUE.xls"
    "090mm\HEBT\alone_H2-022A-QUE\LGEN_PROTON_alone_H2-022A-QUE.xls"
    "090mm\HEBT\alone_H2-022A-QUE\LGEN_PROTON_alone_H2-022A-QUE.xls"
    "090mm\HEBT\alone_H2-022A-QUE\LGEN_PROTON_alone_H2-022A-QUE.xls"
    "090mm\HEBT\alone_H3-003A-SW2\LGEN_PROTON_alone_H3-003A-SW2.xls"
    ];
indices=zeros(2,2,length(profileDataPaths));
indices(1,:,1)=[3,33]; indices(2,:,1)=[1,31];
indices(1,:,2)=[3,43]; indices(2,:,2)=[1,41];
indices(1,:,3)=[3,43]; indices(2,:,3)=[1,41];
indices(1,:,4)=[3,43]; indices(2,:,4)=[1,41];
indices(1,:,5)=[3,43]; indices(2,:,5)=[1,41];
indices(1,:,6)=[3,17]; indices(2,:,6)=[1,15];
% 
% - select data set
iSet=6;
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
clear measData,cyCodes,cyProgs,sumData,BARs,FWHMs,INTs,IsXLS,LGENnamesXLS,nDataCurr,tableIs;
%
% ACTUALLY DO THE JOB!
[measData,cyCodes,cyProgs]=...                           % parse SFM/QBM data
    ParseSFMData(sprintf("%s\\Data*%s.csv",dataPath,monType),monType);
sumData=SumSpectra(measData);                            % get summary profiles
ShowSpectra(sumData,myTitle,cyProgs,"cyProg");           % 3D plots
saveas(gcf,myFigName);
[BARs,FWHMs,INTs]=StatDistributionsBDProcedure(sumData); % first statistical analysis (as BD procedure)
% - acquire .xls of scan
currentPath=sprintf("%s\\%s\\%s\\%s",kPath,dataParentPath,beamPart,currentFiles(iSet));
[IsXLS,LGENnamesXLS,nDataCurr]=AcquireCurrentData(currentPath);
% - show raw data
ShowScanRawPlots(IsXLS(1:nDataCurr,LGENnamesXLS==selectedLGENnames),FWHMs,BARs,INTs,size(FWHMs,1),scanMagnets(iSet),monitors(iSet));%,myFigName);
% - get TM currents
[cyCodesTM,rangesTM,EksTM,BrhosTM,currentsTM,fieldsTM,kicksTM,psNamesTM,FileNameCurrentsTM]=AcquireLGENValues(beamPart,machine,config);
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
ShowScanAligned(IsXLS(1:nDataCurr,LGENnamesXLS==selectedLGENnames),FWHMs,BARs,indices(:,:,iSet),scanMagnets(iSet),monitors(iSet));%,myFigName);

%% tests vari

%% functions
