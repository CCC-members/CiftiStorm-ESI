function [HeadModel,iHeadModel,modality] = get_headmodels(protocol_data_path,sStudy)
iHeadModel = sStudy.iHeadModel;
if(iscell(sStudy.Channel.DisplayableSensorTypes))
    modality = char(sStudy.Channel.DisplayableSensorTypes{1});
else
    modality = char(sStudy.Channel.DisplayableSensorTypes);
end
HeadModelFile               = fullfile(protocol_data_path,sStudy.HeadModel(iHeadModel).FileName);
BSTHeadModel                = load(HeadModelFile);
HeadModel                   = struct;
HeadModel.Comment           = BSTHeadModel.Comment;
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

end

