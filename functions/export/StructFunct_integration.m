function [MEEGs, HeadModels, Cdata] = StructFunct_integration(EEG_path, modality, HeadModels, Cdata)

MEEGs = struct;
EEG_file                = dir(EEG_path);
EEG_file([EEG_file.isdir]==1) = [];
if(~isempty(EEG_file))
    for i=1:length(EEG_file)
        MEEGs(i).EEG        = load(fullfile(EEG_file(i).folder,EEG_file(i).name),'-mat');
        [~,filename,~]      = fileparts(EEG_file(i).name);
        MEEGs(i).filename   = filename;
    end
    MEEG                    = MEEGs(1).EEG;

    %%
    %% Filter Channels and LeadField by Preprocessed MEEG
    %%
    if(isequal(modality,'EEG'))
        labels              = {MEEGs(i).EEG.chanlocs(:).labels};
    elseif(isequal(modality,'MEG'))
        labels              = MEEG.labels;
    else
        labels              = MEEG.dnames;
    end
    for h=1:length(HeadModels.HeadModel)
        HeadModel = HeadModels.HeadModel(h);
        disp ("-->> Removing Channels  by preprocessed EEG");
        [Cdata_r, Gain] = remove_channels_by_preproc_data(labels, Cdata, HeadModel.Gain);
        disp ("-->> Sorting Channels and LeadField by preprocessed EEG");
        [Cdata_s, Gain] = sort_channels_by_preproc_data(labels, Cdata_r, Gain);
        HeadModels.HeadModel(h).Gain = Gain; 
    end
    Cdata = Cdata_s;
end
end

