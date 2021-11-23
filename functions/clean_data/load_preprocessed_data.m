function [HeadModels, Cdatas, MEEGs] = load_preprocessed_data(modality,subID,properties,data_file,HeadModel,Cdata)
if(isequal(modality,'EEG'))
    MEEGs = import_eeg_format(subID, properties, data_file);
    if(isempty(MEEGs))
        HeadModels = HeadModel;
        Cdatas = Cdata;
        return;
    end
    for i=1:length(MEEGs)
        [Cdatas(i), HeadModels(i)] = filter_structural_result_by_preproc_data(MEEGs(i).labels, Cdata, HeadModel);
    end
else
    MEEGs = import_meg_format(subID, properties, data_file);
    [Cdata, HeadModels] = filter_structural_result_by_preproc_data(MEEGs(1).labels, Cdata, HeadModels);
end

end

