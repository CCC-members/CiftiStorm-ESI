function CiftiStorm = process_import_chann(CiftiStorm, properties, subID, CSurfaces)

%%
%% Getting params
%%
errMessage      = [];
channel_params  = properties.channel_params.channel_type;
mq_control      = properties.general_params.bst_config.after_MaQC.run;
sSubject        = bst_get('Subject', subID);
type            = properties.channel_params.channel_type.id;

if(~mq_control)    
    %%
    %% ===== IMPORT CHANNEL =====
    %%    
    switch lower(type)
        case 'default'
            % ===== GET DEFAULT =====
            % Get registered Brainstorm EEG defaults
            bstDefaults             = bst_get('EegDefaults');
            nameGroup               = channel_params.group_layout_name;
            nameLayout              = channel_params.channel_layout_name;
            iGroup                  = find(strcmpi(nameGroup, {bstDefaults.name}));
            iLayout                 = strcmpi(nameLayout, {bstDefaults(iGroup).contents.name});
            ChannelFile             = bstDefaults(iGroup).contents(iLayout).fullpath;
            [~, iStudy]             = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
            db_set_channel( iStudy, ChannelFile, 1, 2 );
        case 'individual'
            format = channel_params.data_format;
            if(isequal(lower(format),'mff'))
                bst_format          = 'EEG-EGI-MFF';
            end
            if(isequal(lower(format),'fif'))
                bst_format          = 'FIF';
            end
            if(isequal(lower(format),'4d'))
                bst_format          = '4D';
            end
            base_path               = strrep(channel_params.base_path,'SubID',subID);
            raw_ref                 = strrep(channel_params.file_location,'SubID',subID);
            raw_file                = fullfile(base_path,raw_ref);
            bst_process('CallProcess', 'process_import_data_raw', [], [], ...
                'subjectname',    subID, ...
                'datafile',       {raw_file, bst_format}, ...
                'channelreplace', 0, ...
                'channelalign',   1);
        case 'template'
            if(isequal(properties.general_params.modality,'EEG'))
            else
                % Process: Create link to raw file
                type        = properties.channel_params.channel_type.type_list{3};
                temp_sub_ID         = type.template_name;
                % MRI File
                base_path           = strrep(type.base_path, 'SubID', '');
                base_path           = strrep(base_path, type.template_name, '');
                filepath            = strrep(type.file_location, 'SubID', temp_sub_ID);
                raw_file            = fullfile(base_path, temp_sub_ID, filepath);
                format = channel_params.data_format;
                bst_process('CallProcess', 'process_import_data_raw', [], [], ...
                    'subjectname',    subID, ...
                    'datafile',       {raw_file, format}, ...
                    'channelreplace', 0, ...
                    'channelalign',   1);
            end
    end
    
    %%
    %% Process: Set BEM Surfaces
    %%
    [~, iSubject] = bst_get('Subject', subID);
    db_surface_default(iSubject, 'Scalp', CSurfaces(10).iSurface);
    db_surface_default(iSubject, 'OuterSkull', CSurfaces(9).iSurface);
    db_surface_default(iSubject, 'InnerSkull', CSurfaces(8).iSurface);
    for i=1:length(CSurfaces)
        if(~isempty(CSurfaces(i).iCSurface) && CSurfaces(i).iCSurface && isequal(CSurfaces(i).type,'cortex'))
            db_surface_default(iSubject, 'Cortex', CSurfaces(i).iSurface);
            break;
        end
    end
    
    %%
    %% Project electrodes on the scalp surface.
    %%
    if(isequal(properties.general_params.modality,'EEG'))
        % Get Protocol information
        ProtocolInfo        = bst_get('ProtocolInfo');
        % Get subject directory
        [sSubject]          = bst_get('Subject', subID);
        [sStudies, ~]       = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
        if(length(sStudies)>1)
            conditions      = [sStudies.Condition];
            sStudy          = sStudies(find(contains(conditions,strcat('@raw')),1));
        else
            sStudy          = sStudies;
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
        if(~isempty(properties.channel_params.channel_label_file))
            user_channel = jsondecode(fileread(properties.channel_params.channel_label_file));
            [sStudies, ~]       = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
            BSTChannels         = load(BSTChannelsFile);
            Channels = BSTChannels.Channel;
            for i=1:length(user_channel)
                label = user_channel(i);
                idx  = find(ismember({Channels.Name},label),1);
                New_Channels(i) = Channels(idx);
            end
            BSTChannels.Channel = New_Channels;
            % Save modifications in channel file
            bst_save(file_fullpath(BSTChannelsFile), BSTChannels, 'v7');
        end
    end
end

%%
%% Quality control
%%
% View sources on MRI (3D orthogonal slices)

if(isequal( type, 'individual'))
     [~, iStudy]  = bst_get('StudyWithSubject', sSubject.FileName);
else    
    [~, iStudy]  = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
end
[sStudy, ~]     = bst_get('Study', iStudy);
ChannelFile     = sStudy.Channel.FileName;
ScalpFile       = sSubject.Surface(sSubject.iScalp).FileName;
MriFile         = sSubject.Anatomy(sSubject.iAnatomy).FileName;

%%
%% 
%%
if(getGlobalVerbose())
    report_path     = get_report_path(CiftiStorm, subID);
    if(isequal(properties.general_params.modality,'EEG'))
        hFigMri16   = script_view_mri_3d(MriFile, [], [], [], 'front');
        hFigMri16   = view_channels(ChannelFile, 'EEG', 1, 0, hFigMri16, 1);
        figures     = {hFigMri16, hFigMri16, hFigMri16, hFigMri16};
        fig_out     = merge_figures("Sensor-MRI registration", "Sensor-MRI registration", figures,...
            'rows', 2, 'cols', 2,'axis_on',{'off','off','off','off'},...
            'colorbars',{'off','off','off','off'},...
            'view_orient',{[0,90],[90,360],[1,180],[0,360]});
        bst_report('Snapshot',fig_out,[],strcat('Sensor-MRI registration'), [200,200,900,700]);
        try
            savefig( hFigMri16,fullfile(report_path,strcat('Sensor-MRI registration.fig')));
        catch
        end
        % Closing figure
        close(fig_out,hFigMri16);

        % View sources on Scalp
        hFigMri20   = script_view_surface(ScalpFile, [], [], [],'front');
        hFigMri20   = view_channels(ChannelFile, 'EEG', 1, 0, hFigMri20, 1);

        figures     = {hFigMri20, hFigMri20, hFigMri20, hFigMri20};
        fig_out     = merge_figures("Sensor-MRI registration", "Sensor-MRI registration", figures,...
            'rows', 2, 'cols', 2,'axis_on',{'off','off','off','off'},...
            'colorbars',{'off','off','off','off'},...
            'view_orient',{[0,90],[90,360],[1,180],[0,360]});
        bst_report('Snapshot',fig_out,[],strcat('Sensor-MRI registration'), [200,200,900,700]);
        try
            savefig( hFigMri20,fullfile(report_path,strcat('Sensor-MRI registration.fig')));
        catch
        end
        % Closing figure
        close(fig_out,hFigMri20);
    else
        hFigMri16   = script_view_mri_3d(MriFile, [], [], [], 'front');
        hFigMri16   = view_helmet(ChannelFile, hFigMri16);

        figures     = {hFigMri16, hFigMri16, hFigMri16, hFigMri16};
        fig_out     = merge_figures("Sensor-MRI registration", "Sensor-MRI registration", figures,...
            'rows', 2, 'cols', 2,'axis_on',{'off','off','off','off'},...
            'colorbars',{'off','off','off','off'},...
            'view_orient',{[0,90],[90,360],[1,180],[0,360]});
        bst_report('Snapshot',fig_out,[],strcat('Sensor-MRI registration'), [200,200,900,700]);
        try
            savefig( hFigMri16,fullfile(report_path,strcat('Sensor-MRI registration.fig')));
        catch
        end
        % Closing figure
        close(fig_out,hFigMri16);

        hFigScalp20 = script_view_surface(ScalpFile, [], [], [], 'front');
        hFigScalp20 = view_helmet(ChannelFile, hFigScalp20);

        figures     = {hFigScalp20, hFigScalp20, hFigScalp20, hFigScalp20};
        fig_out     = merge_figures("Sensor-MRI registration", "Sensor-MRI registration", figures,...
            'rows', 2, 'cols', 2,'axis_on',{'off','off','off','off'},...
            'colorbars',{'off','off','off','off'},...
            'view_orient',{[0,90],[90,360],[1,180],[0,360]});
        bst_report('Snapshot',fig_out,[],strcat('Sensor-MRI registration'), [200,200,900,700]);
        try
            savefig(hFigScalp20,fullfile(report_path,strcat('Sensor-MRI registration.fig')));
        catch
        end
        % Closing figure
        close(fig_out,hFigScalp20);
    end
end

%%
%% Registering process
%%
if(isempty(errMessage))
    CiftiStorm.Participants(end).Status             = "Processing";
    CiftiStorm.Participants(end).FileInfo           = "";
    CiftiStorm.Participants(end).Process(end+1).Name    = "Import_chann";
    CiftiStorm.Participants(end).Process(end).Status  = "Completed";
    CiftiStorm.Participants(end).Process(end).Error   = errMessage;
else    
    CiftiStorm.Participants(end).Status             = "Rejected";
    CiftiStorm.Participants(end).FileInfo           = "";
    CiftiStorm.Participants(end).Process(end+1).Name    = "Import_chann";
    CiftiStorm.Participants(end).Process(end).Status  = "Rejected";
    CiftiStorm.Participants(end).Process(end).Error   = errMessage;     
end
end