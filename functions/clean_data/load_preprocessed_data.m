function [HeadModels, Cdata, MEEGs] = load_preprocessed_data(modality,subID,properties,data_file,HeadModels,Cdata)
if(isequal(modality,'EEG'))
    MEEGs = import_eeg_format(subID, properties, data_file);
    if(isempty(MEEGs))
        return;
    end
    [Cdata, HeadModels] = filter_structural_result_by_preproc_data(MEEGs(1).labels, Cdata, HeadModels);    
else
    MEEGs = import_meg_format(subID, properties, data_file);
    [Cdata, HeadModels] = filter_structural_result_by_preproc_data(MEEGs(1).labels, Cdata, HeadModels);
end

end

