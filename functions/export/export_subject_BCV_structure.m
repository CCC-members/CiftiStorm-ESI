function export_error = export_subject_BCV_structure(properties,subID,varargin)

%%
%% Get Protocol information
%%
% try
export_error = [];
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
disp('==========================================================================');

%%
%% Genering leadfield file
%%
disp ("-->> Genering leadfield file");
[HeadModel,iHeadModel,modality] = get_headmodels(ProtocolInfo.STUDIES,sStudy);

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
[Shead, Sout, Sinn, Scortex] = get_surfaces(ProtocolInfo,sSubject,FSAve_interp,iter);

%%
%% Saving files in BC-VARETA Structure
%%
base_path = fullfile(properties.general_params.bcv_config.export_path,ProtocolInfo.Comment);
if(~isfolder(base_path))
    mkdir(base_path);
end

structures  = dir(fullfile(base_path,'**',strcat(subID,'*')));
if(~isempty(structures))
    for i=1:length(structures)
        structure = structures(i);
        if(structure.isdir)
            export_path     = fullfile(base_path,structure.name);
            subject_file = fullfile(structure.folder,structure.name,'subject.mat');
            if(isfile(subject_file))
                subject_info = load(subject_file);
                if(isfield(subject_info,'meeg_dir'))
                    MEEG = load(fullfile(export_path,subject_info.meeg_dir));
                    [Cdata, HeadModel]  = filter_structural_result_by_preproc_data(MEEG.labels, Cdata, HeadModel);
                    action = 'update';
                    save_output_files(action, base_path, modality, subject_info, subID, MEEG, HeadModel, Cdata, Shead, Sout, Sinn, Scortex);
                else
                    action = 'new';
                    save_output_files(action, base_path, modality, subID, HeadModel, Cdata, Cdata, Shead, Sout, Sinn, Scortex);
                end
            else
                action = 'new';
                save_output_files(action, base_path, modality, subID, HeadModel, Cdata, Cdata, Shead, Sout, Sinn, Scortex);
            end
        end
    end
else
    action = 'new';
    save_output_files(action, base_path, modality, subID, HeadModel, Cdata, Shead, Sout, Sinn, Scortex);
end

end

