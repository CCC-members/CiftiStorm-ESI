function [HeadModels,modality] = get_headmodels(protocol_data_path,sStudy)
if(iscell(sStudy.Channel.DisplayableSensorTypes))
    modality = char(sStudy.Channel.DisplayableSensorTypes{1});
else
    modality = char(sStudy.Channel.DisplayableSensorTypes);
end
for i=1:length(sStudy.HeadModel)
    HeadModelFile               = fullfile(protocol_data_path,sStudy.HeadModel(i).FileName);
    BSTHeadModel                = load(HeadModelFile);
    HeadModel                   = struct;
    HeadModel.Comment           = strrep(BSTHeadModel.Comment,' ','');
    HeadModel.Ke                = BSTHeadModel.Gain;
    HeadModel.HeadModelType     = BSTHeadModel.HeadModelType;
    HeadModel.GridOrient        = BSTHeadModel.GridOrient;
    HeadModel.GridAtlas         = BSTHeadModel.GridAtlas;
    HeadModel.History           = BSTHeadModel.History;    
    if(~isempty(BSTHeadModel.EEGMethod))
        HeadModel.Method        = BSTHeadModel.EEGMethod;
    elseif(~isempty(BSTHeadModel.MEGMethod))
        HeadModel.Method        = BSTHeadModel.MEGMethod;
    else
        HeadModel.Method        = BSTHeadModel.ECOGMethod;
    end       
    HeadModels.HeadModel(i) = HeadModel;
end
HeadModels.iHeadModel = sStudy.iHeadModel;
end

