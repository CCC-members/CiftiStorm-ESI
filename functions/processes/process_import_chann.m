function [ChannelFile, channel_error] = process_import_chann(properties, type, subID,varargin)
%%
%% ===== IMPORT CHANNEL =====
%%
channel_error                   = [];
sSubject                        = bst_get('Subject', subID);
[sStudies, iStudy]              = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
channel_params                  = properties.channel_params.chann_config;
switch type
    case 'default'
        % ===== GET DEFAULT =====
        % Get registered Brainstorm EEG defaults
        bstDefaults             = bst_get('EegDefaults');
        nameGroup               = channel_params.group_layout_name;
        nameLayout              = channel_params.channel_layout_name;
        iGroup                  = find(strcmpi(nameGroup, {bstDefaults.name}));
        iLayout                 = strcmpi(nameLayout, {bstDefaults(iGroup).contents.name});
        if(isempty(find(iLayout,1)))
            copyfile("templates/channel_GSN_129.mat",fullfile(bst_get('BrainstormHomeDir'),"defaults","eeg",nameGroup));
            copyfile("templates/channel_GSN_HydroCel_129_E001.mat",fullfile(bst_get('BrainstormHomeDir'),"defaults","eeg",nameGroup));
            bstDefaults             = bst_get('EegDefaults');
            iLayout                 = strcmpi(nameLayout, {bstDefaults(iGroup).contents.name});
        end
        
        ChannelFile             = bstDefaults(iGroup).contents(iLayout).fullpath;
        FileFormat              = 'BST';
        [ChannelFile,  ChannelMat, ChannelReplace, ChannelAlign, Modality] = db_set_channel( iStudy, ChannelFile, 1, 2 );
        %             [~, ChannelFile, ~]     = import_channel(iStudy, ChannelFile, FileFormat, 2, 2, 1, 1, 1);
    case 'individual'
        format = channel_params.data_format;
        if(isequal(lower(format),'mff'))
            bst_format = 'EEG-EGI-MFF';
        end
        if(isequal(lower(format),'fif'))
            bst_format = 'FIF';
        end
        base_path = strrep(channel_params.base_path,'SubID',subID);
        raw_ref = strrep(channel_params.file_location,'SubID',subID);
        raw_file = fullfile(base_path,raw_ref);
        
        sFiles = bst_process('CallProcess', 'process_import_data_raw', [], [], ...
            'subjectname',    subID, ...
            'datafile',       {raw_file, bst_format}, ...
            'channelreplace', 0, ...
            'channelalign',   1);
        
        ChannelFile = sFiles.ChannelFile;
    case 'template'
        if(isequal(properties.general_params.modality,'EEG'))
        else
            % Process: Create link to raw file
            channel_type        = properties.channel_params.channel_type.type_list{3};
            temp_sub_ID         = channel_type.template_name;
            % MRI File
            base_path           = strrep(channel_type.base_path, 'SubID', '');
            base_path           = strrep(base_path, channel_type.template_name, '');
            filepath            = strrep(channel_type.file_location, 'SubID', temp_sub_ID);
            raw_file           = fullfile(base_path, temp_sub_ID, filepath);
            format = channel_params.data_format;
            sFiles = bst_process('CallProcess', 'process_import_data_raw', [], [], ...
                'subjectname',    subID, ...
                'datafile',       {raw_file, format}, ...
                'channelreplace', 0, ...
                'channelalign',   1);
            ChannelFile = sFiles.ChannelFile;
        end
end


%%
%% Process: Set BEM Surfaces
%%
if(~isempty(varargin))
    iSurfaces = varargin{1};
    [sSubject, iSubject] = bst_get('Subject', subID);
    db_surface_default(iSubject, 'Scalp', iSurfaces{1});
    db_surface_default(iSubject, 'OuterSkull', iSurfaces{2});
    db_surface_default(iSubject, 'InnerSkull', iSurfaces{3});
    db_surface_default(iSubject, 'Cortex', iSurfaces{4});
end

if(isequal(properties.general_params.modality,'EEG'))
    %%
    %% Project electrodes on the scalp surface.
    %%
    % Get Protocol information
    ProtocolInfo        = bst_get('ProtocolInfo');
    % Get subject directory
    [sSubject]          = bst_get('Subject', subID);
    [sStudies, iStudies] = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
    if(length(sStudies)>1)
        conditions = [sStudies.Condition];
        sStudy = sStudies(find(contains(conditions,strcat('@raw')),1));
    else
        sStudy = sStudies;
    end
    ScalpFile           = sSubject.Surface(sSubject.iScalp).FileName;
    BSTScalpFile        = bst_fullfile(ProtocolInfo.SUBJECTS, ScalpFile);
    head                = load(BSTScalpFile);
    
    BSTChannelsFile     = bst_fullfile(ProtocolInfo.STUDIES,sStudy.Channel.FileName);
    BSTChannels         = load(BSTChannelsFile);
    channels            = [BSTChannels.Channel.Loc];
    channels            = channels';
    channels            = channel_project_scalp(head.Vertices, channels);
    
    % Report projections in original structure
    for iChan = 1:length(channels)
        BSTChannels.Channel(iChan).Loc = channels(iChan,:)';
    end
    % Save modifications in channel file
    bst_save(file_fullpath(BSTChannelsFile), BSTChannels, 'v7');
end

%%
%% Getting report path
%%
[subject_report_path] = get_report_path(properties, subID);
%%
%% Quality control
%%
% View sources on MRI (3D orthogonal slices)
[sSubject, iSubject] = bst_get('Subject', subID);
ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;
MriFile        = sSubject.Anatomy(sSubject.iAnatomy).FileName;

if(isequal(properties.general_params.modality,'EEG'))
    hFigMri16      = script_view_mri_3d(MriFile, [], [], [], 'front');
    hFigMri16      = view_channels(ChannelFile, 'EEG', 1, 0, hFigMri16, 1);
    bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration front view', [200,200,750,475]);
    savefig( hFigMri16,fullfile(subject_report_path,'Sensor-MRI registration front view.fig'));
    %Left
    view(1,180)
    bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration left view', [200,200,750,475]);
    % Right
    view(0,360)
    bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration right view', [200,200,750,475]);
    % Back
    view(90,360)
    bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration back view', [200,200,750,475]);
    % Close figures
    close(hFigMri16);
    
    % View sources on Scalp
    hFigMri20      = script_view_surface(ScalpFile, [], [], [],'front');
    hFigMri20      = view_channels(ChannelFile, 'EEG', 1, 0, hFigMri20, 1);
    bst_report('Snapshot',hFigMri20,[],'Sensor-Scalp registration front view', [200,200,750,475]);
    savefig( hFigMri20,fullfile(subject_report_path,'Sensor-Scalp registration front view.fig'));
    %Left
    view(1,180)
    bst_report('Snapshot',hFigMri20,[],'Sensor-Scalp registration left view', [200,200,750,475]);
    % Right
    view(0,360)
    bst_report('Snapshot',hFigMri20,[],'Sensor-Scalp registration right view', [200,200,750,475]);
    % Back
    view(90,360)
    bst_report('Snapshot',hFigMri20,[],'Sensor-Scalp registration back view', [200,200,750,475]);
    % Close figures
    close(hFigMri20);
else
    hFigMri16      = script_view_mri_3d(MriFile, [], [], [], 'front');
    [hFigMri16, iDS, iFig] = view_helmet(ChannelFile, hFigMri16);
    bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration front view', [200,200,750,475]);
    savefig( hFigMri16,fullfile(subject_report_path,'Sensor-MRI registration front view.fig'));
    %Left
    view(1,180)
    bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration left view', [200,200,750,475]);
    % Right
    view(0,360)
    bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration right view', [200,200,750,475]);
    % Back
    view(90,360)
    bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration back view', [200,200,750,475]);
    % Close figures
    close(hFigMri16);
    
    hFigScalp20      = script_view_surface(ScalpFile, [], [], [], 'front');
    [hFigScalp20, iDS, iFig] = view_helmet(ChannelFile, hFigScalp20);
    bst_report('Snapshot',hFigScalp20,[],'Sensor-Helmet registration front view', [200,200,750,475]);
    saveas( hFigScalp20,fullfile(subject_report_path,'Sensor-Helmet registration front view.fig'));
    %Left
    view(1,180)
    bst_report('Snapshot',hFigScalp20,[],'Sensor-Helmet registration left view', [200,200,750,475]);
    % Right
    view(0,360)
    bst_report('Snapshot',hFigScalp20,[],'Sensor-Helmet registration right view', [200,200,750,475]);
    % Back
    view(90,360)
    bst_report('Snapshot',hFigScalp20,[],'Sensor-Helmet registration back view', [200,200,750,475]);
    % Close figures
    close(hFigScalp20);
end

end

