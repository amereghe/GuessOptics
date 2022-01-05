% {}~
%% TO DO
% - verifica range correnti MEBT quads and dipoles;
% - prepara un po' di cycodes (tutte le linee trattamento): p/C 30mm, 90mm, 270mm;
% - acquisisci misure (singolo scan, scan parametrizzato);
% - mostra raw data;
% - mostra distribuzioni 3D;
% - scan 1 quad, n dipoles;
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
%   NB: it contains also the info that dipole 02 is M2-001A-IDB (Sheet:
%   Dipoles; compare range B3:B8 and J36:J41);
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
% - beam stat quantities
part="PROTON";
emiGeo=[ 4.813808E-6 2.237630E-6 ]; % [pi m rad]
sigdpp=3E-3; avedpp=-8.436E-3; % []
% - magnet mapping
magnetNames=[ "M1-016A-QIB"  "M2-001A-IDB"  "M2-009A-QIB"  "M3-001A-IDB"  ];
LGENnames=[   "P5-011A-LGEN" "P5-005A-LGEN" "P5-012A-LGEN" "P5-006A-LGEN" ];
TMcurrsProt=[ 46.5           125.5          25.0           125.93         ]; % [A]
DGcurrMins=[  0.5            0.5            0.5            0.5            ]; % [A]
DGcurrMaxs=[  60.0           300.0          60.0           300.0          ]; % [A]
% - cycle codes
myCyCode="240006cc0900"; % Sala 1, Prot, 90 mm

%% set up
% % M2
% scanMADname="externals\optics\MEBT\m2_scan.tfs";
% quadName="M1-016A-QIB";
% dipName="M2-001A-IDB";
% % M3
% scanMADname="externals\optics\MEBT\m3_scan.tfs";
% quadName="M2-009A-QIB";
% dipName="M3-001A-IDB";
% M2-M3
scanMADname="externals\optics\MEBT\m2m3_scan.tfs";
quadName="M1-016A-QIB";
dipName="M3-001A-IDB";
% all
pathQuaAlone=sprintf("alone_%s",quadName);
pathDipAlone=sprintf("alone_%s",dipName);
pathCombined=sprintf("combined_%s_%s",quadName,dipName);
% all MEBT magnets of interest
MEBTmagnetNames=[ "M2-001A-IDB"  "M2-009A-QIB"  "M3-001A-IDB"  "M1-016A-QIB"  ];

%% main - MADX
% - acquire data
[MADXtable,MADXtableHeaders]=ReadMADXData(scanMADname);
ScanName=GetEleName(MADXtableHeaders(9));
ParName=GetEleName(MADXtableHeaders(11));
MonName=GetEleName(MADXtableHeaders(3));
MADXtitle=sprintf("MADX - %s - %s",LabelMe(ScanName),LabelMe(MonName));
% - convert MADX optics data into FWHMs and BARs
[MADxFWHMs,MADxBARs,MADxScanXs,MADxParXs]=MADXtoFWHMsBARs(MADXtable,emiGeo,sigdpp,avedpp);
% - show scans
ShowScans(MADxFWHMs,MADxBARs,MADxScanXs,MADxParXs,ScanName,ParName,MADXtitle);
% - show MADX responses, i.e. KOL(Idip) and K1(Iqua);
ShowMADXResponses(MADXtable,ScanName,ParName);
% - show responses, i.e. x,y(Idip), x,y(Iquad);
ShowResponses(MADxBARs,MADxScanXs,MADxParXs,ScanName,ParName,MADXtitle);
% - show xy ellipses during scans
ShowEllipses(MADxFWHMs,MADxBARs,MADxScanXs,MADxParXs,ScanName,ParName,MADXtitle);

%% main - create configuration files
% - LGEN files
%   . quad alone: +/-15A around TM, 1A of step
[selectedLGENnames,indLGENs]=ReturnLGENnames(magnetNames,LGENnames,quadName);
quaValues=GenerateLGENvalsAroundTM(TMcurrsProt,magnetNames,DGcurrMaxs,quadName,15,1);
[LGENfileName,APIfileName,~]=TreeStructure(part,pathQuaAlone);
nAPI=WriteLGENQAfile(LGENfileName,selectedLGENnames,quaValues,DGcurrMaxs(indLGENs),DGcurrMins(indLGENs));
WriteAPIfile(APIfileName,nAPI,myCyCode);
%   . dipole alone: +/-10A around TM, 0.5A of step
[selectedLGENnames,indLGENs]=ReturnLGENnames(magnetNames,LGENnames,dipName);
dipValues=GenerateLGENvalsAroundTM(TMcurrsProt,magnetNames,DGcurrMaxs,dipName,5,0.5);
[LGENfileName,APIfileName,~]=TreeStructure(part,pathDipAlone);
nAPI=WriteLGENQAfile(LGENfileName,selectedLGENnames,dipValues,DGcurrMaxs(indLGENs),DGcurrMins(indLGENs));
WriteAPIfile(APIfileName,nAPI,myCyCode);
%    . combined quad-dip scan
[selectedLGENnames,indLGENs]=ReturnLGENnames(magnetNames,LGENnames,[quadName dipName]);
for iDip=1:length(dipValues)
    values=quaValues;
    values(:,size(values,2)+1)=dipValues(iDip);
    [LGENfileName,APIfileName,~]=TreeStructure(part,pathCombined,dipValues(iDip));
    nAPI=WriteLGENQAfile(LGENfileName,selectedLGENnames,values,DGcurrMaxs(indLGENs),DGcurrMins(indLGENs));
    WriteAPIfile(APIfileName,nAPI,myCyCode);
end

%   . all 4 MEBT LGENs:
[selectedLGENnames,indLGENs]=ReturnLGENnames(magnetNames,LGENnames,MEBTmagnetNames);
[LGENfileName,APIfileName,~]=TreeStructure(part,pathQuaAlone);
%   . quad alone: +/-15A around TM, 1A of step
quaValues=GenerateLGENvalsAroundTM(TMcurrsProt,magnetNames,DGcurrMaxs,quadName,15,1);
values=zeros(length(quaValues),1);
for iMag=1:length(MEBTmagnetNames)
    if ( strcmp(MEBTmagnetNames(iMag),quadName) )
        values(:,iMag)=quaValues;
    else
        values(:,iMag)=TMcurrsProt(indLGENs(iMag));
    end
end
nAPI=WriteLGENQAfile(LGENfileName,selectedLGENnames,values,DGcurrMaxs(indLGENs),DGcurrMins(indLGENs));
WriteAPIfile(APIfileName,nAPI,myCyCode);

% values=GenerateLGENvalsAroundTM(TMcurrsProt,magnetNames,missing(),quadName,15,1);
% values=GenerateLGENvalsAroundTM(TMcurrsProt,magnetNames,DGcurrMaxs,dipName,5,5,values);
% nAPI=WriteLGENQAfile("myLGEN.xls",selectedLGENnames,values,DGcurrMaxs(indLGENs),DGcurrMins(indLGENs));
% WriteAPIfile("myApiFile.txt",nAPI,myCyCode);

%% functions
