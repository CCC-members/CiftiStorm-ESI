function [process_error] = headmodel_process_interface(properties, reject_subjects)
% HeadModel Process Interface
%   
%
%
% Author:
% - Ariosky Areces Gonzalez
% - Deirel Paz Linares
%%

%%
%% Preparing protocol specifications
%%
process_error                   = [];
subjects_process_error          = [];
subjects_processed              = [];
general_params                  = properties.general_params;
anatomy_params                  = properties.anatomy_params;
ProtocolName                    = general_params.bst_config.protocol_name;
output_path                     = general_params.output_path;
anatomy_type                    = anatomy_params.anatomy_type.type;
anatomy_config                  = anatomy_params.anatomy_type.type_list{anatomy_type};
mq_control                      = general_params.bst_config.after_MaQC.run;

switch mq_control
    case true
        iProtocol               = bst_get('Protocol', ProtocolName);
        if(isempty(iProtocol))
            fprintf(2,strcat('\nBC-V-->> Error: The protocol name defined in config_properties/general_params.json is wrong \n'));
            disp(strcat("Name: ",ProtocolName));
            disp(strcat("Please check the Protocol name or the BST db_path in config_properties/general_params.json file"));
            disp('-->> Process stopped!!!');
            return;
        end
        gui_brainstorm('SetCurrentProtocol', iProtocol);
        subjects                = bst_get('ProtocolSubjects');
        subjects                = subjects.Subject;
    case false
        if(isequal(anatomy_type,1))
            subjects.name       = anatomy_config.template_name;
            sTemplates          = bst_get('AnatomyDefaults');
            sTemplate           = sTemplates(find(strcmpi(subjects.name, {sTemplates.Name}),1));
            if(isempty(sTemplate))
                fprintf(2,strcat('\nBC-V-->> Error: The selected template name in process_import_anat.json is wrong \n'));
                disp(strcat("Name: ",subjects.name));
                disp(strcat("Please check the available anatomy templates in bst_template/bst_default_anatomy.json file"));
                disp('-->> Process stopped!!!');
                return;
            end
        elseif(isequal(anatomy_type,2))
            subjects.name       = anatomy_config.template_name;
            subjects.folder     = anatomy_config.base_path;
        else
            base_path           = anatomy_config.base_path;
            subjects            = dir(base_path);
            subjects(ismember({subjects.name},{'.','..'}))           = [];  %remove . and ..
            if(~isempty(reject_subjects))
                subjects(ismember({subjects.name},reject_subjects))  = [];
            end
            disp(strcat('-->> Data Source:  ', anatomy_config.base_path ));
        end
end
% for j=18:18
for j=1:length(subjects)
    if(mq_control)
        subID        = subjects(j).Name;
    else
        subID        = subjects(j).name;
    end     
    disp('==========================================================================');
    disp(strcat('-->> Processing subject: ', subID));
    disp('==========================================================================');    
    
    %%
    %%  Process: Create BST Protocol and add subject
    %%
    if(~mq_control)
        errMessage          = process_create_subject(properties, subID);
    end
    
    %%
    %% Start a New Report
    %%
    bst_report('Start',['Protocol for subject:' , subID]);
    bst_report('Info','',[],['Protocol for subject:' , subID]);
    
    %%
    %% Process Import Anatomy
    %%
    disp("--------------------------------------------------------------------------");
    disp("-->> Process Import Anatomy");
    disp("--------------------------------------------------------------------------");
    [anat_error, CSurfaces, properties] = process_import_anat(properties,subID);
    if(~isempty(fieldnames(anat_error)))
        continue;
    end
       
    %%
    %% Process: Generate BEM surfaces
    %%
    disp("--------------------------------------------------------------------------");
    disp("-->> Process Generate BEM surfaces");
    disp("--------------------------------------------------------------------------");    
    [errMessage, CSurfaces] = process_gen_bem_surfaces(properties, subID, CSurfaces);   
    
    %%
    %% Process: Transform surfaces
    %%
    disp("--------------------------------------------------------------------------");
    disp("-->> Transform surfaces");
    disp("--------------------------------------------------------------------------");    
    [errMessage, CSurfaces, sub_to_FSAve] = process_compute_surfaces(properties, subID, CSurfaces);
    
    %%
    %% Process: Import Atlas
    %%
    disp("--------------------------------------------------------------------------");
    disp("-->> Process Import Atlas");
    disp("--------------------------------------------------------------------------");
    atlas_error     = process_import_atlas(properties, subID, CSurfaces);
    
    %%
    %% Process: Generate SPM canonical surfaces
    %%
    disp("--------------------------------------------------------------------------");
    disp("-->> Process Generate SPM canonical surfaces");
    disp("--------------------------------------------------------------------------");
    errMessage      = process_canonical_surfaces(properties, subID);
    
    %%
    %% Process Import Channel
    %%
    disp("--------------------------------------------------------------------------");
    disp("-->> Process Import Channel");
    disp("--------------------------------------------------------------------------");
    channel_error   = process_import_chann(properties, subID, CSurfaces);
    if(~isempty(channel_error))
        continue;
    end
        
    %%
    %% Process: Compute Headmodel
    %%
    disp("--------------------------------------------------------------------------");
    disp("-->> Process Compute HeadModel");
    disp("--------------------------------------------------------------------------");
    errMessage      = process_comp_headmodel(properties, subID, CSurfaces);
    
    %%
    %% Export subject from protocol
    %%
    disp("--------------------------------------------------------------------------");
    disp("-->> Export Subject from BST Protocol");
    disp("--------------------------------------------------------------------------");
    if(~isfolder(fullfile(output_path,'BST','Subjects',ProtocolName)))
        mkdir(fullfile(output_path,'BST','Subjects',ProtocolName));
    end
    iProtocol       = bst_get('iProtocol');
    [~, iSubject]   = bst_get('Subject', subID);
    export_protocol(iProtocol, iSubject, fullfile(output_path,'BST','Subjects',ProtocolName,strcat(subID,'.zip')));
    
    %%
    %% Save and display report
    %%
    disp("--------------------------------------------------------------------------");
    disp("-->> Export BST Report");
    disp("--------------------------------------------------------------------------");
    report_path     = get_report_path(properties, subID);
    ReportFile      = bst_report('Save', []);
    bst_report('Export',  ReportFile, fullfile(report_path,[subID,'.html']));
    disp(strcat("-->> Process finished for subject: ",subID));
        
    %%
    %% Export Subject to BC-VARETA
    %%
    disp("--------------------------------------------------------------------------");
    disp("-->> Export to BC-VARETA Structure");
    disp("--------------------------------------------------------------------------");
    if(isempty(errMessage))
        disp(strcat('BC-V -->> Export subject:' , subID, ' to BC-VARETA structure'));
        export_error = export_subject_BCV_structure(properties, subID, CSurfaces, sub_to_FSAve);        
    end
    disp(strcat('-->> Subject:' , subID, '. Processing finished.'));
    disp('==========================================================================');    
end
disp(strcat('-->> Process finished....'));
disp('==============================================================================');
disp('==============================================================================');
save report.mat subjects_processed subjects_process_error;
end