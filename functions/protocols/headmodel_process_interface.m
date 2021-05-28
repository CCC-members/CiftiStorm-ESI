function [process_error] = headmodel_process_interface(properties)
process_error = [];

anat_modality = properties.anatomy_params.anatomy_type.type;
channel_modality = properties.channel_params.channel_type.type;
switch anat_modality
    case 1
        subj_error =  headmodel_default_anat(properties);
    case 2
        if(isequal(channel_modality,1))
            subj_error = headmodel_template_anat_raw_data(properties);
        else
            subj_error = headmodel_template_anat(properties);
        end
    case 3
        subj_error = headmodel_indiv_anat(properties);
end

channel_error = process_import_channel(properties);
prep_data = process_import_prep_data(properties);
qc_error = process_qc(properties);


end

