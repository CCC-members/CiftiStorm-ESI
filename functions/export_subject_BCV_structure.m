function [] = export_subject_BCV_structure(selected_data_set,subID,varargin)

%%
%% Get Protocol information
%%
% try
for i=1:2:length(varargin)
    eval([varargin{i} '=  varargin{(i+1)};'])
end
% Get subject directory
if(exist('iTemplate','var'))
    sSubject = bst_get('Subject', iTemplate);
else
    sSubject = bst_get('Subject', subID);
end    
ProtocolInfo = bst_get('ProtocolInfo');

% Get the current Study
[sStudies, iStudies] = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
if(length(sStudies)>1)
    conditions = [sStudies.Condition];
    sStudy = sStudies(find(contains(conditions,strcat('@raw')),1));
else
    sStudy = sStudies;
end

if(isempty(sSubject) || isempty(sSubject.iAnatomy) || isempty(sSubject.iCortex) || isempty(sSubject.iInnerSkull) || isempty(sSubject.iOuterSkull) || isempty(sSubject.iScalp))
    return;
end
bcv_path = selected_data_set.bcv_config.export_path;
if(~isfolder(bcv_path))
    mkdir(bcv_path);
end

%% Uploding Subject file into BrainStorm Protocol
disp('BST-P ->> Uploading Subject file into BrainStorm Protocol.');

% process_waitbar = waitbar(0,strcat('Importing data subject: ' , subject_name ));
%%
%% Genering leadfield file
%%

disp ("-->> Genering leadfield file");
[HeadModels,iHeadModel,modality] = get_headmodels(ProtocolInfo.STUDIES,sStudy);

%%
%% Genering surf file
%%
% Loadding subject surfaces
if(~exist('non_interp','var'))
    non_interp = false;
end
CortexFile8K            = sSubject.Surface(sSubject.iCortex).FileName;
BSTCortexFile8K         = bst_fullfile(ProtocolInfo.SUBJECTS, CortexFile8K);
Sc8k                    = load(BSTCortexFile8K);
if(~non_interp)
    disp ("-->> Getting FSAve surface corregistration");
    % Loadding FSAve templates
    FSAve_64k               = load('templates/FSAve_cortex_64K.mat');
    fsave_inds_template     = load('templates/FSAve_64K_8K_coregister_indms.mat');
%     fsave_inds_template     = load('templates/FSAve_64k_coregister_indms.mat');
       
    CortexFile64K           = sSubject.Surface(1).FileName;
    BSTCortexFile64K        = bst_fullfile(ProtocolInfo.SUBJECTS, CortexFile64K);
    Sc64k                   = load(BSTCortexFile64K);
    
    % Finding near FSAve vertices on subject surface
    if(exist('iter','var'))
        if(isequal(iter,1))
            sub_to_FSAve = find_interpolation_vertices(Sc64k,Sc8k, fsave_inds_template);
            if(~isfolder(fullfile(pwd,'tmp')))
                mkdir(fullfile(pwd,'tmp'));
            end
            addpath(fullfile(pwd,'tmp'));
            save(fullfile(pwd,'tmp','sub_to_FSAve.mat'),'sub_to_FSAve');
        end
        load(fullfile(pwd,'tmp','sub_to_FSAve.mat'));
    else
        sub_to_FSAve = find_interpolation_vertices(Sc64k,Sc8k, fsave_inds_template);
    end
else
    sub_to_FSAve = [];
end

% Loadding subject surfaces
disp ("-->> Genering surf file");
[Sc,iCortex] = get_surfaces(ProtocolInfo.SUBJECTS,sSubject);

%%
%% Genering Channels file
%%
disp ("-->> Genering channels file");
if(isempty(sStudy.iChannel))
    sStudy.iChannel = 1;
end
BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,sStudy.Channel(sStudy.iChannel).FileName);
Cdata = load(BSTChannelsFile);

%%
%% Genering scalp file
%%
disp ("-->> Genering scalp file");
ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;
BSTScalpFile = bst_fullfile(ProtocolInfo.SUBJECTS, ScalpFile);
Sh = load(BSTScalpFile);

%%
%% Genering inner skull file
%%
disp ("-->> Genering inner skull file");
InnerSkullFile = sSubject.Surface(sSubject.iInnerSkull).FileName;
BSTInnerSkullFile = bst_fullfile(ProtocolInfo.SUBJECTS, InnerSkullFile);
Sinn = load(BSTInnerSkullFile);

%%
%% Genering outer skull file
%%
disp ("-->> Genering outer skull file");
OuterSkullFile = sSubject.Surface(sSubject.iOuterSkull).FileName;
BSTOuterSkullFile = bst_fullfile(ProtocolInfo.SUBJECTS, OuterSkullFile);
Sout = load(BSTOuterSkullFile);

%%
%% Genering eeg file
%%
if(isfield(selected_data_set, 'preprocessed_data'))
    if(~isequal(selected_data_set.preprocessed_data.base_path,'none'))
        filepath = strrep(selected_data_set.preprocessed_data.file_location,'SubID',subID);
        base_path =  strrep(selected_data_set.preprocessed_data.base_path,'SubID',subID);
        data_file = fullfile(base_path,filepath);
        if(isfile(data_file))
            disp ("-->> Genering MEG/EEG file");
            [HeadModels,Cdata, MEEGs] = load_preprocessed_data(modality,subID,selected_data_set,data_file,HeadModels,Cdata);
        end
    end
end

%%
%% Creating structure for each selected event
%%
if(~exist('MEEGs','var'))
    MEEGs = struct;
    MEEGs.subID = subID;
end
for m=1:length(MEEGs)
    MEEG = MEEGs(m);
    % Creating subject folder structure
    disp(strcat("-->> Creating subject output structure"));
    [output_subject_dir] = create_data_structure(selected_data_set.bcv_config.export_path,MEEG.subID);
    
    subject_info = struct;
    if(isfolder(output_subject_dir))
        leadfield_dir = struct;
        for h=1:length(HeadModels)
            HeadModel = HeadModels(h);
            dirref = replace(fullfile('leadfield',strcat(HeadModel.Comment,'_',num2str(posixtime(datetime(HeadModel.History{1}))),'.mat')),'\','/');
            leadfield_dir(h).path = dirref;
        end
        subject_info.name = MEEG.subID;
        subject_info.modality = modality;
        subject_info.leadfield_dir = leadfield_dir;
        dirref = replace(fullfile('surf','surf.mat'),'\','/');
        subject_info.surf_dir = dirref;
        dirref = replace(fullfile('scalp','scalp.mat'),'\','/');
        subject_info.scalp_dir = dirref;
        dirref = replace(fullfile('scalp','innerskull.mat'),'\','/');
        subject_info.innerskull_dir = dirref;
        dirref = replace(fullfile('scalp','outerskull.mat'),'\','/');
        subject_info.outerskull_dir = dirref;
    end
    if(isfield(MEEG,'data'))
        dirref = replace(fullfile('meeg','meeg.mat'),'\','/');
        subject_info.meeg_dir = dirref;
        disp ("-->> Saving MEEG file");
        save(fullfile(output_subject_dir,'meeg','meeg.mat'),'MEEG');
    end
    for h=1:length(HeadModels)
        HeadModel   = HeadModels(h);
        Comment     = HeadModel.Comment;
        Method      = HeadModel.Method;
        Ke          = HeadModel.Ke;
        GridOrient  = HeadModel.GridOrient;
        GridAtlas   = HeadModel.GridAtlas;
        History     = HeadModel.History;
        disp ("-->> Saving leadfield file");
        save(fullfile(output_subject_dir,'leadfield',strcat(HeadModel.Comment,'_',num2str(posixtime(datetime(History{1}))),'.mat')),...
            'Comment','Method','Ke','GridOrient','GridAtlas','iHeadModel','History');
    end
    disp ("-->> Saving surf file");
    save(fullfile(output_subject_dir,'surf','surf.mat'),'Sc','sub_to_FSAve','iCortex');
    disp ("-->> Saving scalp file");
    save(fullfile(output_subject_dir,'scalp','scalp.mat'),'Cdata','Sh');
    disp ("-->> Saving inner skull file");
    save(fullfile(output_subject_dir,'scalp','innerskull.mat'),'Sinn');
    disp ("-->> Saving outer skull file");
    save(fullfile(output_subject_dir,'scalp','outerskull.mat'),'Sout');
    disp ("-->> Saving subject file");
    save(fullfile(output_subject_dir,'subject.mat'),'subject_info');
    
    % waitbar(0.25,process_waitbar,strcat('Genering eeg file for: ' , subject_name ));
    % waitbar(0.5,process_waitbar,strcat('Genering leadfield file for: ' , subject_name ));
    %  -------- Genering scalp file -------------------------------
    %delete(process_waitbar);
    % catch exception
    %     brainstorm stop;
    %     fprintf(2,strcat("\n -->> Protocol stoped \n"));
    %     msgText = getReport(exception);
    %     fprintf(2,strcat("\n -->> ", string(msgText), "\n"));
    % end
    
end
end

