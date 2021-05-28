function [] = export_subject_BCV_structure(properties,subID,varargin)

%%
%% Get Protocol information
%%
% try
for i=1:2:length(varargin)
    eval([varargin{i} '=  varargin{(i+1)};'])
end

% Get subject directory
ProtocolInfo        = bst_get('ProtocolInfo');
bcv_path = properties.general_params.bcv_config.export_path;
if(~isfolder(bcv_path))
    mkdir(bcv_path);
end
if(exist('iTemplate','var'))
    sSubject = bst_get('Subject', iTemplate);
else
    sSubject = bst_get('Subject', subID);
end

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

%% Uploding Subject file into BrainStorm Protocol
disp('BST-P ->> Uploading Subject file into BrainStorm Protocol.');

%%
%% Genering leadfield file
%%
disp ("-->> Genering leadfield file");
[HeadModels,iHeadModel,modality] = get_headmodels(ProtocolInfo.STUDIES,sStudy);

%%
%% Genering Channels file
%%
disp ("-->> Genering channels file");
if(isempty(sStudy.iChannel))
    sStudy.iChannel = 1;
end
BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,sStudy.Channel(sStudy.iChannel).FileName);
Cdata           = load(BSTChannelsFile);

%%
%% Getting surfaces
%%
if(~exist('FSAve_interp','var'))
    FSAve_interp = true;
end
if(~exist('iter','var'))
    iter = 1;
end
[scalp, outerS, innerS, surf] = get_surfaces(ProtocolInfo,sSubject,FSAve_interp,iter);

%%
%% Genering MEG/EEG file
%%
if(isequal(properties.prep_data_params.process_type.type,1))
    data_file = fullfile(ProtocolInfo.STUDIES,sStudy.Data.FileName);
    preprocessed_data.format = 'mat';
elseif(isequal(properties.prep_data_params.process_type.type,2))
    preprocessed_data = properties.prep_data_params.process_type.type_list{2};
    if(~isequal(preprocessed_data.base_path,'none'))
        filepath = strrep(preprocessed_data.file_location,'SubID',subID);
        base_path =  strrep(preprocessed_data.base_path,'SubID',subID);
        data_file = fullfile(base_path,filepath);
    end
end
if(exist('data_file','var') && isfile(data_file))
    disp ("-->> Genering MEG/EEG file");
    preprocessed_data.clean_data = properties.prep_data_params.clean_data;
    preprocessed_data.channel_label_file = properties.channel_params.channel_label_file;
    [HeadModels,Cdata, MEEGs] = load_preprocessed_data(modality,subID,preprocessed_data,data_file,HeadModels,Cdata);
end

scalp.Cdata     = Cdata;

%%
%% Creating structure for the subject and save the output files
%%
if(exist('MEEGs','var') && ~isempty(MEEGs))
    save_output_files(properties,modality,MEEGs,HeadModels,iHeadModel,scalp,outerS,innerS,surf);
end
end

