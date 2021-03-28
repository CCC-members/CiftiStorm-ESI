function [HeadModels,iHeadModel,modality] = get_headmodels(protocol_data_path,sStudy)
iHeadModel = sStudy.iHeadModel;
if(iscell(sStudy.Channel.DisplayableSensorTypes))
    modality = char(sStudy.Channel.DisplayableSensorTypes{1});
else
    modality = char(sStudy.Channel.DisplayableSensorTypes);
end
HeadModels = struct;
count = 1;
for h=1: length(sStudy.HeadModel)
    HeadModelFile               = fullfile(protocol_data_path,sStudy.HeadModel(h).FileName);
    HeadModel                   = load(HeadModelFile);
    if(isequal(modality,'EEG') && isempty(HeadModel.EEGMethod))
        continue;
    end
    if(isequal(modality,'MEG') && isempty(HeadModel.MEGMethod))
        continue;
    end
    if(~isequal(sStudy.Channel.nbChannels,size(HeadModel.Gain,1)))
        continue;
    end
    HeadModels(count).Comment       = HeadModel.Comment;
    HeadModels(count).Ke            = HeadModel.Gain;
    HeadModels(count).HeadModelType = HeadModel.HeadModelType;
    HeadModels(count).GridOrient    = HeadModel.GridOrient;
    HeadModels(count).GridAtlas     = HeadModel.GridAtlas;
    HeadModels(count).History       = HeadModel.History;
    
    if(~isempty(sStudy.HeadModel(count).EEGMethod))
        HeadModels(count).Method    = sStudy.HeadModel(count).EEGMethod;
    elseif(~isempty(sStudy.HeadModel(count).MEGMethod))
        HeadModels(count).Method    = sStudy.HeadModel(count).MEGMethod;
    else
        HeadModels(count).Method    = sStudy.HeadModel(count).ECOGMethod;
    end
    count = count + 1;
end
end

