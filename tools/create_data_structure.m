function [output_subject] = create_data_structure(bcv_path,subject_name, modality)
%CREATE_DATA_STRUCTURE Summary of this function goes here
%   Detailed explanation goes here

subject_info = struct;
if(nargin == 1)
    guiHandle = total_subjects_guide;
    
    disp('------Waitintg for frequency_bands------');
    uiwait(guiHandle.UIFigure);
    
    if(guiHandle.canceled)
        delete(guiHandle);
        output_subject = null;
        return;
    else
        if(~isfolder(strcat(bcv_path,filesep,'Data')))
            mkdir(bcv_path,'Data');            
        end
        for i = 1:guiHandle.total_subjects
            subject_path = fullfile(bcv_path,subject_name);
            mkdir(subject_path);
            eeg_path = fullfile(subject_path,'eeg');
            mkdir(eeg_path);
            leadfield_path = fullfile(subject_path,'leadfield');
            mkdir(leadfield_path);
            scalp_path = fullfile(subject_path,'scalp');
            mkdir(scalp_path);
            surf_path = fullfile(subject_path,'surf');
            mkdir(surf_path);
        end
        delete(guiHandle);
    end
elseif(nargin == 2)  
    output_subject  = strcat(bcv_path,filesep,subject_name);
    if(~isfolder(output_subject))
        subject_path = fullfile(bcv_path,subject_name);
        mkdir(subject_path);
        eeg_path = fullfile(subject_path,'eeg');
        mkdir(eeg_path);
        leadfield_path = fullfile(subject_path,'leadfield');
        mkdir(leadfield_path);
        scalp_path = fullfile(subject_path,'scalp');
        mkdir(scalp_path);
        surf_path = fullfile(subject_path,'surf');
        mkdir(surf_path);        
     end
else
   output_subject  = strcat(bcv_path,filesep,subject_name);
    if(~isfolder(output_subject))
        subject_path = fullfile(bcv_path,subject_name);
        mkdir(subject_path);
        if(isequal(modality,'EEG'))
            eeg_path = fullfile(subject_path,'eeg');
            mkdir(eeg_path);
        else
            meg_path = fullfile(subject_path,'meg');
            mkdir(meg_path);
        end
        leadfield_path = fullfile(subject_path,'leadfield');
        mkdir(leadfield_path);
        scalp_path = fullfile(subject_path,'scalp');
        mkdir(scalp_path);
        surf_path = fullfile(subject_path,'surf');
        mkdir(surf_path);
    end
end

