function datasetFile = cfs_process_interface(properties, reject_subjects, app)
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
general_params                  = properties.general_params;
anatomy_params                  = properties.anatomy_params;
ProtocolName                    = general_params.bst_config.protocol_name;
anatomy_type                    = anatomy_params.anatomy_type;
mq_control                      = general_params.bst_config.after_MaQC.run;
CiftiStorm                      = struct();
TempUUID                        = java.util.UUID.randomUUID;
CiftiStorm.UUID                 = char(TempUUID.toString);
CiftiStorm.Name                 = general_params.dataset.Name;
CiftiStorm.Description          = general_params.dataset.Description;
CiftiStorm.ProtocolName         = ProtocolName;
CiftiStorm.Location             = fullfile(general_params.output_path,'ciftistorm');
CiftiStorm.Properties           = properties;
CiftiStorm.Participants         = [];

switch mq_control
    case true
        iProtocol               = bst_get('Protocol', ProtocolName);
        if(isempty(iProtocol))
            fprintf(2,strcat('\nBC-V-->> Error: The protocol name defined in cfs_properties/general_params.json is wrong \n'));
            disp(strcat("Name: ",ProtocolName));
            disp(strcat("Please check the Protocol name or the BST db_path in cfs_properties/general_params.json file"));
            disp('-->> Process stopped!!!');
            return;
        end
        gui_brainstorm('SetCurrentProtocol', iProtocol);
        subjects                = bst_get('ProtocolSubjects');
        subjects                = subjects.Subject;
    case false
        if(isequal(lower(anatomy_type.id),'default'))
            CiftiStorm.Location = fullfile(general_params.output_path,strcat('ciftistorm-',anatomy_type.template_name));
            subjects.name       = anatomy_type.template_name;
            sTemplates          = bst_get('AnatomyDefaults');
            sTemplate           = sTemplates(find(strcmpi(subjects.name, {sTemplates.Name}),1));
            if(isempty(sTemplate))
                fprintf(2,strcat('\nBC-V-->> Error: The selected template name in process_import_anat.json is wrong \n'));
                disp(strcat("Name: ",subjects.name));
                disp(strcat("Please check the aviable anatomy templates in bst_template/bst_default_anatomy.json file"));
                disp('-->> Process stopped!!!');
                return;
            end 
        elseif(isequal(lower(anatomy_type.id),'template'))
            CiftiStorm.Location = fullfile(general_params.output_path,strcat('ciftistorm-',anatomy_type.template_name)); 
            subjects.name       = anatomy_type.template_name;
        else
            base_path           = anatomy_type.base_path;
            subjects            = dir(base_path);
            subjects(ismember({subjects.name},{'.','..'}))           = [];  %remove . and ..
            if(~isempty(reject_subjects))
                subjects(ismember({subjects.name},{reject_subjects.SubID}))  = [];
            end
            if(isequal(lower(anatomy_type.id),'template'))
                subjects(find(~ismember({subjects.name}, {anatomy_type.template_name}),1))  = [];
            end
            disp(strcat('-->> Data Source:  ', anatomy_type.base_path ));
        end
end

for sub=1:length(subjects)
    if(mq_control)
        subID        = subjects(sub).Name;
    else
        subID        = subjects(sub).name;
    end     
    disp('==========================================================================');
    disp(strcat('CFS -->> Processing subject: ', subID));
    disp('==========================================================================');    
    
    %%
    %%  Process: Create BST Protocol and add subject
    %%
    CiftiStorm          = process_create_subject(CiftiStorm, properties, subID, app);
    if(isequal(CiftiStorm.Participants(end).Status,'Rejected'));continue;end
    
    %%
    %% Start a New Report
    %%
    bst_report('Start',['Protocol for subject:' , subID]);
    bst_report('Info','',[],['Protocol for subject:' , subID]);
    
    %%
    %% Process Import Anatomy
    %%
    disp("--------------------------------------------------------------------------");
    disp("CFS -->> Process Import Anatomy");
    disp("--------------------------------------------------------------------------");
    [CiftiStorm, CSurfaces] = process_import_anat(CiftiStorm, properties,subID, app);
    if(isequal(CiftiStorm.Participants(end).Status,'Rejected'));continue;end
       
    %%
    %% Process: Generate BEM surfaces
    %%
    disp("--------------------------------------------------------------------------");
    disp("CFS -->> Process Generate BEM surfaces");
    disp("--------------------------------------------------------------------------");    
    [CiftiStorm, CSurfaces] = process_gen_bem_surfaces(CiftiStorm, properties, subID, CSurfaces, app);   
    if(isequal(CiftiStorm.Participants(end).Status,'Rejected'));continue;end
    
    %%
    %% Process: Compute surfaces
    %%
    disp("--------------------------------------------------------------------------");
    disp("CFS -->> Transform surfaces");
    disp("--------------------------------------------------------------------------");    
    [CiftiStorm, CSurfaces, sub_to_FSAve] = process_compute_surfaces(CiftiStorm, properties, subID, CSurfaces, app);
    if(isequal(CiftiStorm.Participants(end).Status,'Rejected'));continue;end

    %%
    %% Process: Import Atlas
    %%
    disp("--------------------------------------------------------------------------");
    disp("CFS -->> Process Import Atlas");
    disp("--------------------------------------------------------------------------");
    CiftiStorm     = process_import_atlas(CiftiStorm, properties, subID, CSurfaces, app);
    if(isequal(CiftiStorm.Participants(end).Status,'Rejected'));continue;end

    %%
    %% Process: Generate SPM canonical surfaces
    %%
    disp("--------------------------------------------------------------------------");
    disp("CFS -->> Process Generate SPM canonical surfaces");
    disp("--------------------------------------------------------------------------");
    CiftiStorm      = process_canonical_surfaces(CiftiStorm, properties, subID, app);
    if(isequal(CiftiStorm.Participants(end).Status,'Rejected'));continue;end
    
    %%
    %% Process Import Channel
    %%
    disp("--------------------------------------------------------------------------");
    disp("CFS -->> Process Import Channel");
    disp("--------------------------------------------------------------------------");
    CiftiStorm   = process_import_chann(CiftiStorm, properties, subID, CSurfaces, app);
    if(isequal(CiftiStorm.Participants(end).Status,'Rejected'));continue;end
        
    %%
    %% Process: Compute Headmodel
    %%
    disp("--------------------------------------------------------------------------");
    disp("CFS -->> Process Compute HeadModel");
    disp("--------------------------------------------------------------------------");
    [CiftiStorm, OPTIONS]     = process_comp_headmodel(CiftiStorm, properties, subID, CSurfaces, app);
    if(isequal(CiftiStorm.Participants(end).Status,'Rejected'));continue;end    
    
    %%
    %% Process: Functional integration
    %%
    disp("--------------------------------------------------------------------------");
    disp("CFS -->> Process Export subject");
    disp("--------------------------------------------------------------------------");
    CiftiStorm      = process_integration(CiftiStorm, properties, subID, CSurfaces, sub_to_FSAve, app);   
    
    disp(strcat('CFS -->> Subject:' , subID, '. Processing finished.'));
    disp('==========================================================================');    
end
disp(strcat('CFS -->> Saving Dataset.'));
disp('==============================================================================');
datasetFile = fullfile(CiftiStorm.Location,'CiftiStorm.json');
saveJSON(CiftiStorm,datasetFile);
h = matlab.desktop.editor.openDocument(datasetFile);
h.smartIndentContents
h.save
h.close

%% Delete Protocol after analysis
% db_delete_protocol(0, 1)
% gui_brainstorm('DeleteProtocol', ProtocolName);

disp(strcat('CFS -->> Dataset processed....'));
disp('==============================================================================');
disp('==============================================================================');
end