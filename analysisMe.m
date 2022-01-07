% {}~
%% TO DO
% - verifica range correnti MEBT quads and dipoles;
% - prepara un po' di cycodes (tutte le linee trattamento): p/C 30mm, 90mm, 270mm;
% - acquisisci misure (singolo scan, scan parametrizzato);
% - mostra raw data;
% - mostra distribuzioni 3D;
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
part="PROTON";
% - beam stat quantities (for MADX predictions on measurements): MEBT
emiGeo=[ 4.813808E-6 2.237630E-6 ]; % [pi m rad]
sigdpp=3E-3; avedpp=-8.436E-3; % []
% - magnet mapping
magnetNames=[ 
    "M1-016A-QIB"  "M2-001A-IDB"  "M2-009A-QIB"  "M3-001A-IDB"     ... % MEBT
    "H2-022A-QUE"  "H3-003A-SW2"  "H3-009A-MBS"  "H3-015A-MBS"     ... % HEBT-hor (H2-H3)
    "H4-013A-QUE"  "V1-001A-SWV"  "V1-005A-MBU"                    ... % HEBT-ver (H4-V1)
    ];
nickNames=[
    "M7"           "M1"           "M8"           "M2"              ... % MEBT
    "H10"          "H4"           "H6"           "H7"              ... % HEBT-hor (H2-H3)
    "H13"          "V1"           "V2"                             ... % HEBT-ver (H4-V1)
    ];
LGENnames=[   
    "P5-011A-LGEN" "P5-005A-LGEN" "P5-012A-LGEN" "P5-006A-LGEN"    ... % MEBT
    "P7-010A-LGEN" "P7-004A-LGEN" "P7-006A-LGEN" "P7-007A-LGEN"    ... % HEBT-hor (H2-H3)
    "P7-013A-LGEN" "PA-003A-LGEN" "PA-004A-LGEN"                   ... % HEBT-ver (H4-V1)
    ];
TMcurrsProt=[ ... % [A]
    46.5           125.5          25.0           125.93            ... % MEBT
    11.934         664.5          663.5          662.71            ... % HEBT-hor (H2-H3), Sala 2V, Prot, 90mm
    34.17          656.7          670.96                           ... % HEBT-ver (H4-V1), Sala 2V, Prot, 90mm
    ];
DGcurrMins=[ ... % [A]
    0.5            0.5            0.5            0.5               ... % MEBT
    0.5            60.0           60.0           60.0              ... % HEBT-hor (H2-H3)
    0.5            60.0           60.0                             ... % HEBT-ver (H4-V1)
    ];
DGcurrMaxs=[ ... % [A]
    150.0          300.0          150.0          300.0             ... % MEBT
    350.0          2000.0         2990.0         2990.0            ... % HEBT-hor (H2-H3)
    350.0          2000.0         2990.0                           ... % HEBT-ver (H4-V1)
    ];
% - cycle codes
myCyCode="240004cc0100"; % Sala 2V, Prot, 90mm

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
% quadName="H3-003A-QUE";
% dipName="H3-003A-SW2";
% H3, 3 dipoles
scanMADname="externals\optics\HEBT\h3_scan_3dips.tfs";
quadName="H3-003A-QUE";
dipName="H3-003A-SW2";
% % V1
% scanMADname="externals\optics\HEBT\v1_scan.tfs";
% quadName="H4-013A-QUE";
% dipName="V1-001A-SWV";
%
HEBTmagnetNames=[ "H2-022A-QUE" "H3-003A-SW2" "H3-009A-MBS" "H3-015A-MBS" ];
% HEBTmagnetNames=[ "H4-013A-QUE" "V1-001A-SWV" "V1-005A-MBU" ];

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
return

%% main - create configuration files
% - paths
pathQuaAlone=sprintf("alone_%s",quadName);
pathDipAlone=sprintf("alone_%s",dipName);
pathCombined=sprintf("combined_%s_%s",quadName,dipName);
pathQuaDipDip=sprintf("combined_%s_allDips",quadName);
% - LGEN files (ask all 4 LGENs in .xls file, such that used currents are logged in LPOW error log)
%   . quad alone: +/-15A around TM, 1A of step
CreateMeasFiles(pathQuaAlone,quadName,15,1,magnetNames,LGENnames,TMcurrsProt,DGcurrMaxs,DGcurrMins,part,myCyCode,MEBTmagnetNames);
%   . dipole alone: +/-10A around TM, 0.5A of step
CreateMeasFiles(pathDipAlone,dipName,10,0.5,magnetNames,LGENnames,TMcurrsProt,DGcurrMaxs,DGcurrMins,part,myCyCode,MEBTmagnetNames);
%    . combined quad-dip scan
CreateMeasFiles(pathCombined,[quadName dipName],[15 5],[1 1],magnetNames,LGENnames,TMcurrsProt,DGcurrMaxs,DGcurrMins,part,myCyCode,MEBTmagnetNames);
%    . combined quad-dip-dip scan
CreateMeasFiles(pathQuaDipDip,["M1-016A-QIB" "M2-001A-IDB" "M3-001A-IDB"],[15 5 5],[1 1 1],magnetNames,LGENnames,TMcurrsProt,DGcurrMaxs,DGcurrMins,part,myCyCode,MEBTmagnetNames);

% HEBT
pathH3full=sprintf("combined_%s_allDips",quadName);
CreateMeasFiles(pathH3full,HEBTmagnetNames,[15 5 5 5],[1 1 1 1],magnetNames,LGENnames,TMcurrsProt,DGcurrMaxs,DGcurrMins,part,myCyCode,HEBTmagnetNames,false);

% 2 magnets scan at the same time
% values=GenerateLGENvalsAroundTM(TMcurrsProt,magnetNames,missing(),quadName,15,1);
% values=GenerateLGENvalsAroundTM(TMcurrsProt,magnetNames,DGcurrMaxs,dipName,5,5,true,values);
% nAPI=WriteLGENQAfile("myLGEN.xls",selectedLGENnames,values,DGcurrMaxs(indLGENs),DGcurrMins(indLGENs));
% WriteAPIfile("myApiFile.txt",nAPI,myCyCode);

%% functions
