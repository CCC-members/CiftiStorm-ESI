function [subject_info, HeadModels, Cdata] = load_preprocessed_data(subject_info, selected_data_set, output_subject_dir, data_file, HeadModels, Cdata)
if(isequal(subject_info.modality,'EEG'))
    MEEG = import_eeg_format(subject_info, selected_data_set, data_file);
    [Cdata, HeadModels] = filter_structural_result_by_preproc_data(MEEG.labels, Cdata, HeadModels);
else
    MEEG = import_meg_format(subject_info, selected_data_set, data_file);
    [Cdata, HeadModels] = filter_structural_result_by_preproc_data(MEEG.labels, Cdata, HeadModels);
end
dirref = replace(fullfile('meeg','meeg.mat'),'\','/');
subject_info.meeg_dir = dirref;
disp ("-->> Saving MEEG file");
save(fullfile(output_subject_dir,'meeg','meeg.mat'),'MEEG');
end

