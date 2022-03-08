function [process_error] = headmodel_process_interface(properties)
process_error = [];

if(properties.general_params.bst_config.after_MaQC.run)
    process_error = headmodel_after_MaQC(properties);
else
    anat_modality = properties.anatomy_params.anatomy_type.type;
    switch anat_modality
        case 1
            process_error =  headmodel_default_anat(properties);
        case 2
            process_error = headmodel_template_anat(properties);
        case 3
            process_error = headmodel_indiv_anat(properties);
    end
end

end

