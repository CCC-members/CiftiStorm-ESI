function  CiftiStorm = process_integration(CiftiStorm, properties, subID, CSurfaces, sub_to_FSAve)

% Get subject directory
ProtocolInfo    = bst_get('ProtocolInfo');
sSubject        = bst_get('Subject', subID);
general_params  = properties.general_params;

if(isequal(properties.anatomy_params.anatomy_type.id,'individual'))
    base_path     = fullfile(general_params.output_path,'ciftistorm');
else
    template_name = properties.anatomy_params.anatomy_type.template_name;
    base_path = fullfile(general_params.output_path,strcat('ciftistorm-',template_name));
end

% Get the current Study
[sStudies, ~]   = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
if(length(sStudies)>1)
    conditions  = [sStudies.Condition];
    sStudy      = sStudies(find(contains(conditions,strcat('@raw')),1));else
    sStudy      = sStudies;
end
if(isempty(sSubject) || isempty(sSubject.iAnatomy) || isempty(sSubject.iCortex) || isempty(sSubject.iInnerSkull) || isempty(sSubject.iOuterSkull) || isempty(sSubject.iScalp))
    return;
end

%%
%% Genering leadfield file
%%
disp ("-->> Genering leadfield file");
[rawHeadModels,modality] = get_headmodels(ProtocolInfo.STUDIES,sStudy);

%%
%% Genering Channels file
%%
disp ("-->> Genering channels file");
if(isempty(sStudy.iChannel))
    sStudy.iChannel = 1;
end
BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,sStudy.Channel(sStudy.iChannel).FileName);
rawCdata        = load(BSTChannelsFile);

%%
%% Getting surfaces
%%
[Shead, Sout, Sinn, Scortex] = get_surfaces(ProtocolInfo, sSubject, CSurfaces, sub_to_FSAve);

%%
%% Strctural and fuctional integration
%%
eeglab_path             = fullfile(properties.integration_params.preproc_data.base_path);
if(isequal(properties.anatomy_params.anatomy_type.id,'individual'))
    Cdata                       = rawCdata;
    HeadModels                  = rawHeadModels;
    EEG_path                    = fullfile(eeglab_path,subID);
    [MEEGs, HeadModels, Cdata]  = StructFunct_integration(EEG_path, modality, HeadModels, Cdata);
    AQCI                        = AutomaticQCI(HeadModels.HeadModel.Gain, Cdata, Scortex.Sc);
    if(isempty(fields(MEEGs)))
        action = 'anat';  
        CiftiStorm.Participants(end).Status             = "Structural";
    else
        action = 'all';
        CiftiStorm.Participants(end).Status             = "Completed";
    end
    save_output_files(base_path, modality, subID, MEEGs, HeadModels, Cdata, Shead, Sout, Sinn, Scortex, AQCI, action);    
    CiftiStorm.Participants(end).FileInfo               = strcat(subID,".json");
    CiftiStorm.Participants(end).Process(end+1).Name    = "Integration";
    CiftiStorm.Participants(end).Process(end).Status    = "Completed";
    CiftiStorm.Participants(end).Process(end).Error     = [];
else
    CiftiStorm.Template = CiftiStorm.Participants;
    disp(strcat("-->> Saving anatomy template: ",template_name));
    disp("--------------------------------------------------------------------------");
    CiftiStorm.Template.SubID       = template_name;
    CiftiStorm.Template.Status      = "Anatomy";
    CiftiStorm.Template.FileInfo    = strcat(template_name,'.json');
    subID                           = template_name;
    HeadModels                      = rawHeadModels;
    Cdata                           = rawCdata;
    AQCI                            = AutomaticQCI(HeadModels.HeadModel.Gain, Cdata, Scortex.Sc);
    action                          = 'anat';
    save_output_files(base_path, modality, subID, HeadModels, Cdata, Shead, Sout, Sinn, Scortex, AQCI, action);
    
    subjects                    = dir(eeglab_path);
    subjects(ismember({subjects.name},{'.','..'})) = [];
    for e=1:length(subjects)
        subject                 = subjects(e);        
        subID                   = subject.name;
        disp(strcat("-->> Saving subject: ",subID));
        disp("--------------------------------------------------------------------------");
        EEG_path                = fullfile(eeglab_path,subID);
        HeadModels              = rawHeadModels;
        Cdata                   = rawCdata;
        [MEEGs,HeadModels,Cdata] = StructFunct_integration(EEG_path, modality, HeadModels, Cdata);
        AQCI                    = AutomaticQCI(HeadModels.HeadModel.Gain, Cdata, Scortex.Sc);
        save_output_files(base_path, modality, subID, MEEGs, HeadModels, Cdata, Shead, Sout, Sinn, Scortex, AQCI);

        participant                         = CiftiStorm.Template;
        participant.SubID                   = subID;
        participant.Status                  = "Completed";
        participant.FileInfo                = strcat(subID,".json");
        participant.Process(end+1).Name     = "Integration";
        participant.Process(end).Status     = "Completed";
        participant.Process(end).Error      = [];
        CiftiStorm.Participants(e)          = participant;

    end
end

end

