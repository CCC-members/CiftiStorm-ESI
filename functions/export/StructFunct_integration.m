function [MEEGs, HeadModels, Cdata] = StructFunct_integration(EEG_path, modality, HeadModels, Cdata)

MEEGs = struct;
EEG_file                = dir(EEG_path);
EEG_file([EEG_file.isdir]==1) = [];
if(~isempty(EEG_file))
    count = 1;
    for i=1:length(EEG_file)
        [~,filename,ext]      = fileparts(EEG_file(i).name);
        if(isequal(ext,'.set'))
            MEEGs(count).EEG        = load(fullfile(EEG_file(i).folder,EEG_file(i).name),'-mat');
            while(isfield( MEEGs(count).EEG,'EEG'))
                 MEEGs(count).EEG = MEEGs(count).EEG.EEG;
            end
            if(ischar(MEEGs(count).EEG.data))
                fid = fopen(fullfile(EEG_file(i).folder,strrep(EEG_file(i).name,'set','fdt')), 'r', 'ieee-le');
                for trialIdx = 1:MEEGs(count).EEG.trials % In case the saved data are epoched, loop the process for each epoch. Thanks Ramesh Srinivasan!
                    currentTrialData = fread(fid, [MEEGs(count).EEG.nbchan MEEGs(count).EEG.pnts], 'float32');
                    data(:,:,trialIdx) = currentTrialData; % Data dimentions are: electrodes, time points, and trials (the last one is for epoched data)
                end
                fclose(fid);
                MEEGs(count).EEG.data = data;
            end
            if(~contains(filename,'task'))
                filename_parts = split(filename,'_');
                filename = strcat(filename_parts{1},'_task-resting');
               for p=2:length(filename_parts)
                    filename = strcat(filename,'_',filename_parts{p});
               end
            end
            MEEGs(count).filename   = filename;
            count = count + 1;
        end
    end
    MEEG                    = MEEGs(1).EEG;

    %%
    %% Filter Channels and LeadField by Preprocessed MEEG
    %%
    if(isequal(modality,'EEG'))
        labels              = {MEEGs(1).EEG.chanlocs(:).labels};
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

