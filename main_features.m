clear all
addpath(genpath(fullfile(pwd, 'Main_Code')));
%% INPUT PARAMETERS
track_results_dir = './Example/Tracking_Results/'; %where the results of the tracking analysis are stored?
data_base_file = './Example/database.csv'; %the field naems in the database is going to be used to group the data from the different videos.
feature_result_dir = './Example/Features_Results/'; %directory where teh results are going to be stored.

expected_number_of_frames = 40; %what is the number of frames expected, to filter trajectories that are to short and likely to be spurious
%%
param.maxTrackLength = expected_number_of_frames;
param.maxLag = expected_number_of_frames/2;
param.minTrackLength = param.maxLag*2; %min track length
param.iniFrame = 1;

param.del_pix = 0.106;
param.exp_time = 0.1;

param.alpha.WStep = 4;
param.alpha.Bin = linspace(-1, 2, 25);

param.alpha2.limits = [0.4 10];

param.isDedrift = false; %already dedrifted by main_tracking.m
param.minParticles = 10;
param.minTrackDedrift = 50;
%param.err.BB = 0.05;
param.Nlag = [1 4 96];%[1 4 16 64 96];
%param.Nlag = [];
%{
param.err.bias = [94.5 97.5];
param.err.noise = [5.6 4.6];
param.err.BB = 0.055;
%}
%param.err = 0.4394084;
param.err = [-2.1267 10.^-0.9929];


%%
if ~exist(feature_result_dir, 'dir'), mkdir(feature_result_dir); end

fileData = getFileData2(data_base_file);
[group_names, group_indexes, sample_indexes]=unique(fileData.name);
tot_groups = numel(group_names);

%[strain, props]=name2PosNAP(group_names);

%%
postFixStrS = {'PhC'};%{'PhCa', 'FM464a', 'PhCb', 'FM464b'};
strExtra = {'geoM', 'mean','ensembleAv', 'geoMW'};
strFields = {'MSD','MME2','M4D','MME4', 'MLSD','MSDc', 'errMat', 'MSDw','errMatw'};

%Initialize
NFi = numel(strFields);

for nf = 1:NFi
    for jj = 1:numel(strExtra)
        datAv.(strExtra{jj}).(strFields{nf}) = zeros(param.maxLag,tot_groups);
    end
end
nParticles = zeros(1,tot_groups);
%%

for fp = 1:tot_groups
    param.progressTextStr = sprintf('Set %i of %i',fp, tot_groups);
    
    %% build file names
    curr_group = group_names{fp};
    MSD_file = sprintf('%sData_MME_%s.mat',feature_result_dir,curr_group);
    cellShape_file = sprintf('%scellShapeInfo_%s_%s',feature_result_dir,curr_group, 'PhC');
    MSD_PC_file = sprintf('%sData_MSD_Ang_%s.mat',feature_result_dir,curr_group);
    MSD_cellShape_file = sprintf('%sData_MSD_Shape_%s.mat',feature_result_dir,curr_group);
    intensity_file = sprintf('%sProperties_Int_%s',feature_result_dir,curr_group);
    %%
    rows_in_group = find(sample_indexes==fp);
    
    param.del_time = fileData.delta_time(rows_in_group(1));
    param.isEMgain = true;
    [timeAv, trackID, allMSD_mov] = extract_MSD_MEE_EE(track_results_dir, rows_in_group, param);
    if isempty(timeAv), continue, end
    
    if iscell(track_results_dir)
        progressTextStr = sprintf('Extracting intensity data %i of %i',fp, tot_groups);
        IntProps = extract_IntProps(trackID, track_results_dir, progressTextStr, param);
        save(intensity_file,'IntProps');
    end
    
    
    progressText(0 , sprintf('Alpha Set %i of %i',fp, tot_groups));
    
    [alphaTimeAv.MSD.coeff, alphaTimeAv.MSD.R2] = ...
        alpha_Moving3(timeAv.MSD, timeAv.Npoints, [], param);
    progressText(0.4)
    
    [alpha10.coeff, alpha10.MSD.R2, alpha10.gamma] = alpha_Fit(timeAv.MSD, [], param);
    
    
    EE = timeAv.MSD-timeAv.errMat;
    EE(EE<0) = nan;
    [alpha10_err.coeff, alpha10_err.MSD.R2, alpha10_err.gamma] = ...
        alpha_Fit(EE, [], param);
    
    NN = size(EE,2);
    alphaErrD = zeros(2,NN);
    alphaErrD10 = zeros(2,NN);
    tt = ((1:param.maxLag)*param.del_time)';
    vv = 1:find(tt<=10, 1,'last');
    for nn = 1:NN
        alphaErrD(:,nn) = getAlphaDynErr(EE(:,nn), tt, param.exp_time);
        alphaErrD10(:,nn) = getAlphaDynErr(EE(vv,nn), tt(vv), param.exp_time);
    end
    
    progressText(0.6)
    
    [alphaTimeAv.MSDc.coeff, alphaTimeAv.MSDc.R2] = ...
        alpha_Moving3(timeAv.MSDc, timeAv.Npoints, timeAv.errMat, param);
    
    
    save(MSD_file,'timeAv','alphaTimeAv', ...
        'trackID', 'param', 'allMSD_mov', 'alpha10', 'alpha10_err', 'alphaErrD', 'alphaErrD10')
    
    progressText(1)
    
    
    
   %Calculate data averages
    
    datAv = calculate_datAv(datAv,timeAv, fp, param.maxLag,strFields);
    
    ensembleAv = calculate_ensemble_MSD_EE(timeAv.Xmat, timeAv.Ymat, timeAv.Emat, param.maxLag);
    strSS = fieldnames(ensembleAv);
    for nf = 1:numel(strSS)
        datAv.ensembleAv.(strSS{nf})(:,fp) = ensembleAv.(strSS{nf});
    end
    nParticles(fp) = size(trackID,2);
    %}
    
    load(MSD_file,'trackID','param')
    %%
    postFixStr = 'PhC';
    
    
    progressTextStr = sprintf('Analysing %s %i of %i...', postFixStr, fp, tot_groups);
    datadir.segmentation = track_results_dir;
    datadir.track = track_results_dir;
    
    findOrder = 'first';
    [shapeAll, shapeIndCell] = ...
        getShapeAll(trackID, datadir, param.del_pix, postFixStr, findOrder, '');
    save(cellShape_file,'shapeAll', 'shapeIndCell')
    
    
    load(MSD_file, 'trackID', 'param')
    load(cellShape_file,'shapeAll', 'shapeIndCell')
    if ~isempty(shapeAll)
        MSD_Shape = calculate_AngMSDShape(trackID, shapeAll,track_results_dir,param);
        save(MSD_cellShape_file,'MSD_Shape')
    end
    
    %
    %Track shape
    
    if ~exist(MSD_file, 'file'), continue; end
    load(MSD_file,'timeAv','alphaTimeAv', ...
        'trackID', 'param', 'allMSD_mov', 'alpha10', 'alpha10_err', 'alphaErrD', 'alphaErrD10')
    progressText(0 , sprintf('Track Shape Set %i of %i',fp, tot_groups));
    
    [trackAngDat, MSD_PC] =  calculate_AngMSD_PC(trackID,track_results_dir,param);
    
    
    save(MSD_PC_file, 'MSD_PC', 'trackAngDat')
    
    %{
    MSD_ang_diffini_file = sprintf('%sData_MSD_Ang_diffIni_%i.mat',feature_result_dir,fp);
    MSD_ang_diff_TL_file = sprintf('%sData_MSD_Ang_DiffTL_%i.mat',feature_result_dir,fp);
    
    %Track shape different lengths
    trackLengthS = 50:50:param.maxTrackLength;
    trackAngDat_diff = cell(size(trackLengthS));
    param_new = param;
    for ii = 1:numel(trackLengthS)
        progressText(ii/numel(trackLengthS))
        param_new.maxTrackLength = trackLengthS(ii);
        param_new.minTrackLength = trackLengthS(ii);
    
        trackAngDat_diff{ii} =  calculate_AngMSD_PC(trackID,track_results_dir{1},param_new);        
    end
    
    save(MSD_ang_diff_TL_file, 'trackLengthS', 'trackAngDat_diff')
    
    progressText(0 , sprintf('Track Shape Set %i of %i',fp, tot_groups));
    
    trackAngDat_ini = cell(size(trackLengthS));
    param_new = param;
    param_new.minTrackLength = 50;
    param_new.maxTrackLength = 50;
    
    trackIniS = 1:50:param.maxTrackLength;
    for ii = 1:numel(trackIniS)
        progressText(ii/numel(trackIniS))
        param_new.iniFrame = trackIniS(ii);
        trackAngDat_ini{ii} =  calculate_AngMSD_PC(trackID,track_results_dir,param_new);        
    end
    save(MSD_ang_diffini_file, 'trackIniS', 'trackAngDat_ini')
    %}
end
%
progressText(0,'Calculating Alpha...')
for nf = 1:NFi
    progressText(nf/NFi)
    for jj = 1:numel(strExtra)
        data = datAv.(strExtra{jj}).(strFields{nf});
        [alphaMoving.(strExtra{jj}).(strFields{nf}) ...
            alphaR2.(strExtra{jj}).(strFields{nf})] = ...
            alpha_Moving3(data,[],[],param);
    end
end
%%
save(sprintf('%sAll_Data',feature_result_dir),'datAv','alphaMoving','alphaR2', 'nParticles','group_names','param')%, 'props', 'strain')
