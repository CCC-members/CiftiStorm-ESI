function [HeadModels,modality] = get_headmodels(protocol_data_path,sStudy)
if(iscell(sStudy.Channel.DisplayableSensorTypes))
    modality = char(sStudy.Channel.DisplayableSensorTypes{1});
else
    modality = char(sStudy.Channel.DisplayableSensorTypes);
end
for i=1:length(sStudy.HeadModel)
    HeadModelFile               = fullfile(protocol_data_path,sStudy.HeadModel(i).FileName);
    BSTHeadModel                = load(HeadModelFile);
    if(~isempty(BSTHeadModel.EEGMethod))
        BSTHeadModel.Method     = BSTHeadModel.EEGMethod;
    elseif(~isempty(BSTHeadModel.MEGMethod))
        BSTHeadModel.Method     = BSTHeadModel.MEGMethod;
    else
        BSTHeadModel.Method     = BSTHeadModel.ECOGMethod;
    end
    HeadModels.HeadModel(i)     = BSTHeadModel;
end
HeadModels.iHeadModel           = sStudy.iHeadModel;
end

