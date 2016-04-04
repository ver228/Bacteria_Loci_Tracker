clear all
%%
addpath ./Segmentation_PhC
addpath ../Matlab' General'/
%addpath Y:\Matlab_Code\Matlab' General'\
%addpath Y:\Matlab_Code\Matlab' New Tracking'\
%addpath Y:\Matlab_Code\PhC_Segmentation\
%addpath Y:\Matlab_Scripts\FM_segmentation

imSize = [512 512];
SET_PhC.polVal = getPolyVal(imSize, 3);
SET_PhC.gKernel = fspecial('gaussian',7,1);
SET_PhC.alphaLocMax = 0.1;%SET.alphaLocMax = 1e-4;

%% DATA FROM THE DIFFERENT DATA SETS

%% Boccard SHORT
%{
expodatadir='\\sf3\space\aej35\Boccard\Results\Avelino-LowSNR_300312_N\'; %Export directory
dataBaseFile='\\Sf3\space\aej35\Boccard\Results\Avelino-Nikon_300312.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = []; %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}
%{
expodatadir='\\sf3\space\aej35\Boccard\Results\Avelino-LowSNR_100612_N\'; %Export directory
dataBaseFile='\\Sf3\space\aej35\Boccard\Results\Avelino-Nikon_100612.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = [];%1:1266; %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}

%{
expodatadir='\\Sf3\space\aej35\Boccard\Results\Kenny_summer2012_N\'; %Export directory
dataBaseFile='\\sf3\space\aej35\Boccard\Results\Kenny_summer2012.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = [];%303:507; %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}


%{
expodatadir='\\sf3\space\aej35\Boccard\Results\Fixed-Nikon_LowSNR_N\'; %Export directory
dataBaseFile='\\Sf3\space\aej35\Boccard\Results\Fixed-Nikon_141211.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP=1:233; %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}

%% Zhicheng
%{
expodatadir='\\Sf3\space\aej35\Boccard\Results\Zhicheng_LowSNR_N\'; %Export directory
dataBaseFile='\\Sf3\space\aej35\Boccard\Results\Zhicheng_CAAGlu.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
CMD='set lim 1 -1 65536;set lim 2 0 5;set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';
    %REMEMBER TO CHANGE UPERBOUND FOR LIM1 AND LIM5 IN UINT16

INSP = 154:333%[1:25, 68:333];%26:67 %rows in the database to be analysed
%ZHICHENG 1/15.48=0.0646
del_pix= 0.0646; %REMEMBER TO USE THE DOUBLE FOR 26:67
SET.MAXMOVE = 2;
SET.isMask = true;


set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}


%% Boccard long
%{
expodatadir='\\sf3\space\aej35\Boccard\Results\Avelino-LowSNR_060413_long_N\'; %Export directory
dataBaseFile='\\Sf3\space\aej35\Boccard\Results\Avelino-Nikon_060413_long.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

min_track_lenght = 25; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = 530:703%:703; %rows in the database to be analysed
SET.MAXMOVE = 5;
SET.isMask = true;
SET.integWindow = 1;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}

%{
expodatadir='\\sf3\space\aej35\Boccard\Results\Avelino_050413_long10s_N\'; %Export directory
dataBaseFile='\\Sf3\space\aej35\Boccard\Results\Avelino-Nikon_050413_long10s.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

min_track_lenght = 25; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = []; %rows in the database to be analysed
SET.MAXMOVE = 5;
SET.isMask = true;
SET.integWindow = 1;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}

%% GROWTH CURVE
%{
expodatadir='\\sf3\space\aej35\Boccard\Results\Growth_Curve\'; %Export directory
dataBaseFile='\\Sf3\space\aej35\Boccard\Results\Growth_Curve.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP= 110:141; %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}

%{
expodatadir='\\sf3\space\aej35\Boccard\Results\Growth_Curve_110813\'; %Export directory
dataBaseFile='\\Sf3\space\aej35\Boccard\Results\Growth_Curve_110813.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = 105:479%341:479; %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}

%{
expodatadir='\\sf3\space\aej35\Boccard\Results\Growth_Curve_290813\'; %Export directory
dataBaseFile='\\Sf3\space\aej35\Boccard\Results\Growth_Curve_290813.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = 111:518; %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}
%% NAPS
%{
expodatadir='\\sf3\space\aej35\Boccard\Results\Avelino-NAPs_060313_N\'; %Export directory
dataBaseFile='\\Sf3\space\aej35\Boccard\Results\Avelino-NAPs_060313.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = 8:388;%1:1266; %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}

%{
expodatadir='\\sf3\space\aej35\Boccard\Results\Avelino-NAPs_050613_N\'; %Export directory
dataBaseFile='\\Sf3\space\aej35\Boccard\Results\Avelino-NAPs_050613.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = 705:759;%1:1266; %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}

%{
expodatadir='\\sf3\space\aej35\Boccard\Results\Avelino-NAPs_010413_N\'; %Export directory
dataBaseFile='\\Sf3\space\aej35\Boccard\Results\Avelino-NAPs_010413.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = 541:673;%1:1266; %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}

%{
expodatadir='\\sf3\space\aej35\Boccard\Results\Avelino-NAPs_240813_N\'; %Export directory
dataBaseFile='\\Sf3\space\aej35\Boccard\Results\Avelino-NAPs_240813.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = [203:260 442:590];%590:802%1:1266; %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}
%% NAPS long
%{
expodatadir='\\sf3\space\aej35\Boccard\Results\Avelino-NAPs_180613_long_N\'; %Export directory
dataBaseFile='\\Sf3\space\aej35\Boccard\Results\Avelino-NAPs_180613_long.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = [];%1:1266; %rows in the database to be analysed
SET.MAXMOVE = 5;
SET.isMask = false;
SET.integWindow = 1;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}
%% Different lag times
%{
expodatadir='\\sf3\space\aej35\Boccard\Results\Diff_Lag_180813\'; %Export directory
dataBaseFile='\\Sf3\space\aej35\Boccard\Results\Diff_Lag_180813.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = 15:18; %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}
%% Sherratt
%{
expodatadir='\\Sf3\space\aej35\Tracking_Results\Avelino-Sherratt_210113\'; %Export directory
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; minigrad';
dataBaseFile='\\sf3\space\aej35\Boccard\Results\Avelino-Sherratt_all_210113.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

phCDir = [expodatadir 'PhC\'];

SET.integWindow = 7;
expodatadir='\\Sf3\space\aej35\Tracking_Results\Avelino-Sherratt_210113_check\'; %Export directory

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers

INSP = 21:40%225:302%260:265;

SET.integWindow = 3;
dum = '\\Sf3\space\aej35\Tracking_Results\Avelino-Sherratt_210113_av'; %Export directory
expodatadir = sprintf('%s%i\\',dum, SET.integWindow); min_track_lenght = 100/SET.integWindow;

SET.MAXMOVE=2;
SET.isMask = true;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 5;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}

%{
expodatadir='\\Sf3\space\aej35\Tracking_Results\Avelino-Sherratt_Long1s\'; %Export directory
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; minigrad';
dataBaseFile='\\sf3\space\aej35\Boccard\Results\Avelino-Sherratt_Long_280113.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

INSP = 1:35;
min_track_lenght=150; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers

SET.MAXMOVE = 10;
SET.isMask = true;
SET.alphaLocMax = 0.05;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 5;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}
%{
expodatadir='\\Sf3\space\aej35\Boccard\Results\Avelino-Sherratt_Long10s_310113\'; %Export directory
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';
dataBaseFile='\\sf3\space\aej35\Boccard\Results\Avelino-Sherratt_Long10s_310113.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

INSP = 1:33;

min_track_lenght = 50; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers

SET.MAXMOVE = 3;
SET.isMask = true;
SET.alphaLocMax = 0.05;

set_dedrift.minTrackDedrift = 25;
set_dedrift.minParticles = 5;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}


%{
expodatadir='\\Sf3\space\aej35\Tracking_Results\Avelino-Sherratt_070413\'; %Export directory
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; minigrad';
dataBaseFile='\\sf3\space\aej35\Boccard\Results\Avelino-Sherratt_YFP_070413.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)


min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers

INSP = 38:60%225:302%260:265;

SET.integWindow = 1;

SET.MAXMOVE=2;
SET.isMask = true;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 5;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}
%{
expodatadir='\\Sf3\space\aej35\Tracking_Results\Avelino-Sherratt_070413_long1s\'; %Export directory
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; minigrad';
dataBaseFile='\\sf3\space\aej35\Boccard\Results\Avelino-Sherratt_YFP_070413_long1s.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

INSP = 1:27;
min_track_lenght=150; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers

SET.MAXMOVE = 10;
SET.isMask = true;
SET.alphaLocMax = 0.05;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 5;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}
%% NAPS
%{
expodatadir='\\sf3\space\aej35\Boccard\Results\DminCDE_211113\'; %Export directory
dataBaseFile='\\Sf3\space\aej35\Boccard\Results\DminCDE_211113.csv'; %the data base localization. Database must be a cvs file containing, (number)(label)(time btw frames)(Images directory)(type CAA=1,Glu=2)

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = 320:324;%168:335; %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}
%% IPTG
%{
expodatadir = 'C:\Tracking_Results\Results\IPTG_291113\';
dataBaseFile = 'C:\Tracking_Results\DataBase\IPTG_291113.csv';

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = []; %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}

%% YEAST
%{
expodatadir = '/Users/ver228/Desktop/14.7.2014/yeast_140714/';
dataBaseFile = '/Users/ver228/Desktop/14.7.2014/yeast_140714.csv';

min_track_lenght=50; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = []; %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

SET.integWindow = 5;
SET.iniImage = 5;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 1;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}

%{
expodatadir = '/Volumes/MyPassport/Data/Tracking_Results/Results/Yeast_120914/';
dataBaseFile = '/Volumes/MyPassport/Data/Tracking_Results/DataBase/Yeast_120914.csv';

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = 24:70% %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 3;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}
expodatadir = '/Volumes/MyPassport/Data/Tracking_Results/Results/Yeast_190914/';
dataBaseFile = '/Volumes/MyPassport/Data/Tracking_Results/DataBase/Yeast_190914.csv';

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = []% %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 3;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}

%% SIMULATIONS
%{
expodatadir = '/Volumes/MyPassport/Data/Tracking_Results/Results/simulations_210714/';
dataBaseFile = '/Volumes/MyPassport/Data/Tracking_Results/DataBase/simulations_210714.csv';

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = 65:73 %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}

%% IPTG diff excitation
%{
expodatadir = '/Volumes/MyPassport/Data/Tracking_Results/Results/IPTG_diffExc_100914/';
dataBaseFile = '/Volumes/MyPassport/Data/Tracking_Results/DataBase/IPTG_diffExc_100914.csv';

min_track_lenght=100; %minimun number of frames a trajectory must contain to be considered in the analysis.
del_pix= 0.106; %pixel size in micrometers
CMD = 'set lim 1 -1 65536; set lim 2 0 5; set lim 3 -2.2 2.2;set lim 4 -2.2 2.2;set lim 5 -1 65536; fix 2;minigrad';

INSP = []%181:-1:143%198:-1:115 %47:114% %rows in the database to be analysed
SET.MAXMOVE=2;
SET.isMask = false;

set_dedrift.minTrackDedrift = 50;
set_dedrift.minParticles = 10;
set_dedrift.particlesUsed = [];
set_dedrift.excludeBigMov = true;
%}


%% SETTINGS PARAMETERS
%SET.imageDir='U:\Nikon\12-Dec-2011 B(8 9 12 13 22 25)\B9_CAA+Glu\Before\Before_Pos009_Fluo\';
%='U:\Nikon\19-March-2012 B(9 15 19)\B9_Gly\Before\Before_Pos010_Fluo\';

SET.numImagesRaw = []; %can be used to select a particular set in imList

SET.gKernel = fspecial('gaussian',7,1);
SET.cmd = CMD;
SET.fun2fit = 'MLEwG_Xi';
SET.EMPTY_ALLOWED = 5; %empty frames allowed

SET.TOTALPIX = 5; %used to calculate signal and bgnd

if ~isfield(SET,'iniImage')
    SET.iniImage = 1;
end


if ~isfield(SET,'alphaLocMax')
    SET.alphaLocMax = 0.01;
end
if ~isfield(SET, 'integWindow')
    SET.integWindow = 1; %number of image to integrate
end

if ~exist('wavelength', 'var')
    wavelength = 510;
end
SET.sigma = 0.21*wavelength/(1.4*(del_pix*1000)); 


%% PRELOADING DATA
fileData = getFileData2(dataBaseFile); %DATA BASE

if ~exist(expodatadir,'dir'), mkdir(expodatadir), end

expodatadirD = [expodatadir 'dedrift_data' filesep];
if ~exist(expodatadirD, 'dir'), mkdir(expodatadirD), end

expodatadirS = [expodatadir 'Shape' filesep];
if ~exist(expodatadirS, 'dir'), mkdir(expodatadirS), end


expodatadirSR = [expodatadir 'Shape_result' filesep];
if ~exist(expodatadirSR, 'dir'), mkdir(expodatadirSR), end


%% REAL PROGRAM
if isempty(INSP)
    INSP = 1:numel(fileData.datadirs);
end

TOTMOVIE=numel(INSP);
for inp = 1:TOTMOVIE; 
    
    SSSS=INSP(inp);
    fprintf('Analysing movie %i of %i ...\n', inp, TOTMOVIE); 
    
    %fileData.datadirs{SSSS}(1) = 'F';
    SET.imageDir = fileData.datadirs{SSSS};
    
    imList=getImList(SET.imageDir);
    SET.MASKCELL = [];
 
    %% DOT TRACKING
    %
    %dots = find_peaks_diffsub_av(SET);
    %save([expodatadir 'Dots_' num2str(SSSS)], 'dots', 'SET')
    
    load([expodatadir 'Dots_' num2str(SSSS)], 'dots', 'SET')
    
    [positionsx,positionsy, indSparse] = create_trajectories_ind(dots,SET);
    [positionsx,positionsy, indSparse] = join_tracks_ind(positionsx, positionsy, indSparse, []);
    save([expodatadir 'TrackData_' num2str(SSSS)],'positionsx','positionsy','indSparse', 'SET')
    
    SNRStats = calculate_snr2_av(positionsx, positionsy, imList, SET);
    save([expodatadir 'SNR_' num2str(SSSS)],'SNRStats');
    
    [positionsx, positionsy, CM] = dedrift_correction(positionsx, positionsy, set_dedrift);
    save([expodatadirD 'TrackData_' num2str(SSSS)],'positionsx','positionsy','CM')
    %}
    %
    %load([expodatadir 'TrackData_' num2str(SSSS)])
    if ~isempty(positionsx)
        showTracks_label(imList, positionsx,positionsy, min_track_lenght)
    else
        if SET.iniImage<= numel(imList), dum = SET.iniImage; else dum = 1; end
        figure, imshow(imread(imList{dum}),[]);
        
    end
    saveas(gcf,[expodatadir 'showTracks_' num2str(SSSS) ,'.jpg'],'jpg')
    close(gcf)
    %}
    %%
    
    imDir = fileData.datadirs{SSSS};
    Ind_PhC_database(imDir, SSSS, expodatadirS, SET_PhC.polVal); %get the phC to the database...
    Ind_PhC_Seg(imDir, SSSS, expodatadirS, expodatadirSR, SET_PhC);
    
end