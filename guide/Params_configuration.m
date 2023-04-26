classdef Params_configuration < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        ParamsconfigurationPanel        matlab.ui.container.Panel
        TabGroup                        matlab.ui.container.TabGroup
        GeneralsTab                     matlab.ui.container.Tab
        GeneralsparamsPanel             matlab.ui.container.Panel
        WorkspacepathEditField          matlab.ui.control.EditField
        WorkspacepathEditFieldLabel     matlab.ui.control.Label
        BSTpathEditField                matlab.ui.control.EditField
        BraninstormpathLabel            matlab.ui.control.Label
        BSTdbpathEditField              matlab.ui.control.EditField
        BrainstormdbpathLabel           matlab.ui.control.Label
        SelectWorkspaceButton           matlab.ui.control.Button
        SelectBST_dbButton              matlab.ui.control.Button
        SelectBSTButton                 matlab.ui.control.Button
        AfterMaQCSwitch                 matlab.ui.control.Switch
        AfterMaQCSwitchLabel            matlab.ui.control.Label
        ResetprotocolSwitch             matlab.ui.control.Switch
        ResetprotocolSwitchLabel        matlab.ui.control.Label
        ProtocolnameEditField           matlab.ui.control.EditField
        ProtocolnameLabel               matlab.ui.control.Label
        ModalityDropDown                matlab.ui.control.DropDown
        ModalityLabel                   matlab.ui.control.Label
        ImportAnatomyTab                matlab.ui.container.Tab
        CommonparamsIAPanel             matlab.ui.container.Panel
        MRITransFileEditField           matlab.ui.control.EditField
        filenameLabel                   matlab.ui.control.Label
        MRItransformationLabel          matlab.ui.control.Label
        CommonLayerDiscrpDropDown       matlab.ui.control.DropDown
        LayerdescriptorLabel            matlab.ui.control.Label
        CortexEditField                 matlab.ui.control.NumericEditField
        CortexEditFieldLabel            matlab.ui.control.Label
        SkullEditField                  matlab.ui.control.NumericEditField
        SkullEditFieldLabel             matlab.ui.control.Label
        HeadEditField                   matlab.ui.control.NumericEditField
        HeadEditFieldLabel              matlab.ui.control.Label
        NonBrainPathEditField           matlab.ui.control.EditField
        NonbrainsurfacesLabel           matlab.ui.control.Label
        MRITransPathEditField           matlab.ui.control.EditField
        pathLabel                       matlab.ui.control.Label
        NoverticesLabel                 matlab.ui.control.Label
        SelectHCPNonBrainPathButton     matlab.ui.control.Button
        SelectMRITransPathButton        matlab.ui.control.Button
        SelectAnatomyoptionButtonGroup  matlab.ui.container.ButtonGroup
        HCPIndividualPanel              matlab.ui.container.Panel
        HCPIndivAtlasEditField          matlab.ui.control.EditField
        AtlasfilenameLabel              matlab.ui.control.Label
        HCPIndivT1wEditField            matlab.ui.control.EditField
        Tw1filenameLabel                matlab.ui.control.Label
        HCPIndividPathEditField         matlab.ui.control.EditField
        AnatomypathLabel_2              matlab.ui.control.Label
        SelectHCPIndividPathButton      matlab.ui.control.Button
        HCPTemplatePanel                matlab.ui.container.Panel
        HCPTemplateAtlasEditField       matlab.ui.control.EditField
        AtlasfilenameLabel_2            matlab.ui.control.Label
        HCPTemplateT1wEditField         matlab.ui.control.EditField
        Tw1filenameLabel_2              matlab.ui.control.Label
        HCPTemplatenameEditField        matlab.ui.control.EditField
        TemplatenameEditFieldLabel      matlab.ui.control.Label
        HCPTemplPathEditField           matlab.ui.control.EditField
        AnatomypathLabel                matlab.ui.control.Label
        SelectHCPTemplPathButton        matlab.ui.control.Button
        BSTDefaultAnatomyPanel          matlab.ui.container.Panel
        AnatomyTemplateAtlasDropDown    matlab.ui.control.DropDown
        AtlasLabel                      matlab.ui.control.Label
        AnatomyTemplateDropDown         matlab.ui.control.DropDown
        TemplatenameDropDownLabel       matlab.ui.control.Label
        Button_HCP_Individual           matlab.ui.control.RadioButton
        Button_HCP_Template             matlab.ui.control.RadioButton
        Button_BST_Default              matlab.ui.control.RadioButton
        ImportChannelTab                matlab.ui.container.Tab
        SelectChanneloptionButtonGroup  matlab.ui.container.ButtonGroup
        RawdataPanel                    matlab.ui.container.Panel
        RawDataIsFileSwitch             matlab.ui.control.Switch
        IsFileSwitchLabel               matlab.ui.control.Label
        RawDataFormatDropDown           matlab.ui.control.DropDown
        FormatDropDownLabel             matlab.ui.control.Label
        RawDataFileEditField            matlab.ui.control.EditField
        NameLabel                       matlab.ui.control.Label
        RawDataBPathEditField           matlab.ui.control.EditField
        BasepathLabel                   matlab.ui.control.Label
        SelectRawDataBPathButton        matlab.ui.control.Button
        UseChanneltemplatePanel         matlab.ui.container.Panel
        Channel_UITable                 matlab.ui.control.Table
        ChannTemplateNameDropDown       matlab.ui.control.DropDown
        TemplatenameDropDownLabel_2     matlab.ui.control.Label
        ChannTemplateGroupDropDown      matlab.ui.control.DropDown
        GroupDropDownLabel              matlab.ui.control.Label
        Button_Channel_raw_data         matlab.ui.control.RadioButton
        Button_Channel_template         matlab.ui.control.RadioButton
        ComputeHeadmodelTab             matlab.ui.container.Tab
        UsedefaultparametersSwitch      matlab.ui.control.Switch
        UsedefaultparametersSwitchLabel  matlab.ui.control.Label
        CommonparamsHMPanel             matlab.ui.container.Panel
        BemSelectEditField              matlab.ui.control.EditField
        BemSelectEditFieldLabel         matlab.ui.control.Label
        BemCondEditField                matlab.ui.control.EditField
        BemCondEditFieldLabel           matlab.ui.control.Label
        BemNamesEditField               matlab.ui.control.EditField
        BemNamesEditFieldLabel          matlab.ui.control.Label
        ConductivityEditField           matlab.ui.control.EditField
        ConductivityEditFieldLabel      matlab.ui.control.Label
        RadiiEditField                  matlab.ui.control.EditField
        RadiiEditFieldLabel             matlab.ui.control.Label
        MethodsButtonGroup              matlab.ui.container.ButtonGroup
        DUNEuroFEMPanel                 matlab.ui.container.Panel
        DownsampleSpinner               matlab.ui.control.Spinner
        DownsampleSpinnerLabel          matlab.ui.control.Label
        NodeShiftSpinner                matlab.ui.control.Spinner
        NodeShiftSpinnerLabel           matlab.ui.control.Label
        NbVerticesSpinner               matlab.ui.control.Spinner
        NbVerticesSpinnerLabel          matlab.ui.control.Label
        VertexDensitySpinner            matlab.ui.control.Spinner
        VertexDensitySpinnerLabel       matlab.ui.control.Label
        MergeMethodDropDown             matlab.ui.control.DropDown
        MergeMethodDropDownLabel        matlab.ui.control.Label
        KeepRatioSpinner                matlab.ui.control.Spinner
        KeepRatioSpinnerLabel           matlab.ui.control.Label
        MaxVolSpinner                   matlab.ui.control.Spinner
        MaxVolSpinnerLabel              matlab.ui.control.Label
        MeshTypeDropDown                matlab.ui.control.DropDown
        MeshTypeDropDownLabel           matlab.ui.control.Label
        MethodDropDown                  matlab.ui.control.DropDown
        MethodLabel                     matlab.ui.control.Label
        UseTensorSwitch                 matlab.ui.control.Switch
        UseTensorSwitchLabel            matlab.ui.control.Label
        IsotropicSwitch                 matlab.ui.control.Switch
        IsotropicSwitchLabel            matlab.ui.control.Label
        FemSelectEditField              matlab.ui.control.EditField
        FemSelectEditFieldLabel         matlab.ui.control.Label
        FemCondEditField                matlab.ui.control.EditField
        FemCondEditFieldLabel           matlab.ui.control.Label
        OpenMEEGBEMPanel                matlab.ui.container.Panel
        SplitLengthSpinner              matlab.ui.control.Spinner
        SplitLengthSpinnerLabel         matlab.ui.control.Label
        isSplitSwitch                   matlab.ui.control.Switch
        isSplitSwitchLabel              matlab.ui.control.Label
        isAdaptativeSwitch              matlab.ui.control.Switch
        isAdaptativeSwitchLabel         matlab.ui.control.Label
        isAdjointSwitch                 matlab.ui.control.Switch
        isAdjointSwitchLabel            matlab.ui.control.Label
        OverlappingSpheresPanel         matlab.ui.container.Panel
        Button_DUNEuroFEM               matlab.ui.control.RadioButton
        Button_OpenMEEGBEM              matlab.ui.control.RadioButton
        Button_OwerlappingSpheres       matlab.ui.control.RadioButton
        SetpropertiesButton             matlab.ui.control.Button
        CancelButton                    matlab.ui.control.Button
    end

    
    methods (Access = private)
        
        function checked = check_visual_params(app)
            checked = true;
            if(isempty(app.BSTpathEditField.Value))
                msgbox({'The BrainStorm toolbox path can not be empty.',...
                    ' Please select a correct Brainstorm path.'},'Info');
                checked = false;
            end
            if(isempty(app.BSTdbpathEditField.Value))
                msgbox({'The BrainStorm db path can not be empty.',...
                    ' Please select a correct DB path.'},'Info');
                app.BSTdbpathEditField.Value = 'local';
                checked = false;
            end
            if(isempty(app.SPM12pathEditField.Value))
                msgbox({'The SPM12 path can not be empty.',...
                    ' Please select a correct SPM12 path.'},'Info');
                checked = false;
            end
            if(isempty(app.WorkspacepathEditField.Value))
                msgbox({'The Workspace path can not be empty.',...
                    ' Please select a correct Workspace path.'},'Info');
                checked = false;
            end
            if(isempty(app.BSToutputpathEditField.Value))
                msgbox({'The Reports path can not be empty.',...
                    ' Please select a correct Reports path.'},'Info');
                checked = false;
            end
            if(isempty(app.ProtocolnameEditField.Value))
                msgbox({'The Protocol name field can not be empty.',...
                    ' Please type a correct Protocol name.'},'Info');
                checked = false;
            end
        end
        
        function load_default_params(app)
            app.BSTDefaultAnatomyPanel.Enable = 'on';
            app.HCPTemplatePanel.Enable = 'off';
            app.HCPIndividualPanel.Enable = 'off';
            get_bst_default_anatomy(app);
            
            app.UseChanneltemplatePanel.Enable = 'on';
            app.RawdataPanel.Enable = 'off';
            get_bst_default_channel(app);
            
            % Preprocessed data tab
            
        end
        
        function get_bst_default_anatomy(app)
            % loading anatomical templates
            defaults = jsondecode(fileread(fullfile('bst_templates','bst_default_anatomy.json')));
            app.AnatomyTemplateDropDown.Items = {defaults.name};
            app.AnatomyTemplateDropDown.Items{end+1} = '--Select a template--';
            app.AnatomyTemplateDropDown.Value = '--Select a template--';
        end
        
        function get_bst_default_channel(app)
            defaults = jsondecode(fileread(fullfile('bst_templates','bst_layout_default.json')));
            app.ChannTemplateGroupDropDown.Items = {defaults.name};
            app.ChannTemplateGroupDropDown.Items{end+1} = '--Select--';
            app.ChannTemplateGroupDropDown.Value = '--Select--';
            app.ChannTemplateNameDropDown.Items = {'--Select a template--'};
            app.ChannTemplateNameDropDown.Value = '--Select a template--';
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.UIFigure.Name = 'Dataset Configuration';
            addpath('app');
            addpath('bst_templates');
            addpath('external');
            addpath(genpath('functions'));
            addpath('external');
            load_default_params(app);
        end

        % Button pushed function: SelectBSTButton
        function SelectBSTButtonPushed(app, event)
            try
                folder = uigetdir("Select the Brinstorm path");
                if(isfile(fullfile(folder,'brainstorm.m')))
                    app.BSTpathEditField.Value = folder;
                else
                    msgbox({'The selected folder do not contain the BrainStorm toolbox.',...
                        folder,...
                        ' Please select a correct Brainstorm path.'},'Info');
                    app.BSTpathEditField.Value = '';
                end
            catch
            end
        end

        % Callback function
        function SelectSPMButtonPushed(app, event)
            try
                folder = uigetdir("Select the SPM12 path");
                if(isfile(fullfile(folder,'spm.m')))
                    app.SPM12pathEditField.Value = folder;
                else
                    msgbox({'The selected folder do not contain the SPM12 toolbox.',...
                        folser,...
                        ' Please select a correct SPM12 path.'},'Info');
                    app.SPM12pathEditField.Value = '';
                end
            catch
            end
        end

        % Button pushed function: SelectBST_dbButton
        function SelectBST_dbButtonPushed(app, event)
            try
                folder = uigetdir("Select the BST db folder");
                [~,values] = fileattrib(folder);
                if(values.UserWrite)
                    app.BSTdbpathEditField.Value = folder;
                else
                    app.BSTdbpathEditField.Value = 'local';
                    msgbox({'The current user do not have write permissions on the selected forder.',...
                        ' Please check the folder permission or select another output folder.'},'Info');
                end
            catch
            end
        end

        % Button pushed function: SelectWorkspaceButton
        function SelectWorkspaceButtonPushed(app, event)
            try
                folder = uigetdir("Select the Output folder");
                [~,values] = fileattrib(folder);
                if(values.UserWrite)
                    app.WorkspacepathEditField.Value = folder;
                else
                    msgbox({'The current user do not have write permissions on the selected forder.',...
                        ' Please check the folder permission or select another output folder.'},'Info');
                end
            catch
            end
        end

        % Callback function
        function SelectReportsButtonPushed(app, event)
            try
                folder = uigetdir("Select the Reports output folder");
                [~,values] = fileattrib(folder);
                if(values.UserWrite)
                    app.BSToutputpathEditField.Value = folder;
                else
                    msgbox({'The current user do not have write permissions on the selected forder.',...
                        folder,...
                        ' Please check the folder permission or select another output folder.'},'Info');
                end
            catch
            end
        end

        % Selection changed function: SelectAnatomyoptionButtonGroup
        function SelectAnatomyoptionButtonGroupSelectionChanged(app, event)
            if(app.Button_BST_Default.Value)
                app.BSTDefaultAnatomyPanel.Enable = 'on';
                app.HCPTemplatePanel.Enable = 'off';
                app.HCPIndividualPanel.Enable = 'off';
            end
            if(app.Button_HCP_Template.Value)
                app.BSTDefaultAnatomyPanel.Enable = 'off';
                app.HCPTemplatePanel.Enable = 'on';
                app.HCPIndividualPanel.Enable = 'off';
            end
            if(app.Button_HCP_Individual.Value)
                app.BSTDefaultAnatomyPanel.Enable = 'off';
                app.HCPTemplatePanel.Enable = 'off';
                app.HCPIndividualPanel.Enable = 'on';
            end
        end

        % Value changed function: ChannTemplateGroupDropDown
        function ChannTemplateGroupDropDownValueChanged(app, event)
            group_name = app.ChannTemplateGroupDropDown.Value;
            if(isequal(app.ModalityDropDown.Value,'--Select--'))
                msgbox('Please select the modality first in Generals Tab.','Info');
                app.ChannTemplateGroupDropDown.Value = '--Select--';
                return;
            end
            if(isempty(app.BSTpathEditField.Value))
                msgbox('Please select the Brainstorm path in Generals Tab.','Info');
                app.ChannTemplateGroupDropDown.Value = '--Select--';
                return;
            end
            if(~isequal(group_name,'--Select--'))
                defaults = jsondecode(fileread(fullfile('bst_templates','bst_layout_default.json')));
                layouts_name = defaults(find(ismember({defaults.name},group_name),1)).contents;
                app.ChannTemplateNameDropDown.Items = {layouts_name.name};
                app.ChannTemplateNameDropDown.Items{end+1} = '--Select a template--';
                app.ChannTemplateNameDropDown.Value = '--Select a template--';
                msgbox({'Be sure to select the mode and direction of the BrainStorm in <<Generals Tab>>, before selecting the Channel Layout.'},'Info');
            else
                app.ChannTemplateNameDropDown.Items = {'--Select a template--'};
                app.ChannTemplateNameDropDown.Value = '--Select a template--';
                set(app.Channel_UITable, 'Data', []);
            end
        end

        % Selection changed function: SelectChanneloptionButtonGroup
        function SelectChanneloptionButtonGroupSelectionChanged(app, event)
            if(app.Button_Channel_template.Value)
                app.UseChanneltemplatePanel.Enable = 'on';
                app.RawdataPanel.Enable = 'off';
            end
            if(app.Button_Channel_raw_data.Value)
                app.UseChanneltemplatePanel.Enable = 'off';
                app.RawdataPanel.Enable = 'on';
            end
        end

        % Value changed function: ChannTemplateNameDropDown
        function ChannTemplateNameDropDownValueChanged(app, event)
            template_name = app.ChannTemplateNameDropDown.Value;
            if(~isequal(template_name,'--Select a template--'))
                template_name = strrep(template_name,' ','_');
                if(isequal(app.ModalityDropDown.Value,'--Select--'))
                    msgbox('Please select the modality in Generals Tab.','Info');
                    app.ChannTemplateNameDropDown.Value = '--Select a template--';
                    return;
                end
                if(isempty(app.BSTpathEditField.Value))
                    msgbox('Please select the Brainstorm path in Generals Tab.','Info');
                    app.ChannTemplateNameDropDown.Value = '--Select a template--';
                    return;
                end
                if(isequal(app.ModalityDropDown.Value,'EEG'))
                    layout = load(fullfile(app.BSTpathEditField.Value,'defaults','eeg',app.ChannTemplateGroupDropDown.Value,['channel_',template_name,'.mat']));
                end
                if(isequal(app.ModalityDropDown.Value,'MEG'))
                    layout = load(fullfile(app.BSTpathEditField.Value,'defaults','meg',[template_name,'.mat']));
                end
                for i=1:length(layout.Channel)
                    loc = layout.Channel(i).Loc;
                    Weight = layout.Channel(i).Weight;
                    fields(i).Locs = strcat(num2str(loc(1)),',',num2str(loc(2)),',',num2str(loc(3)));
                end
                order_layout.No         = cellstr(string(1:length(layout.Channel)))';
                order_layout.Name       = {layout.Channel.Name}';
                order_layout.Type       = {layout.Channel.Type}';
                order_layout.Position   = {fields.Locs}';
                order_layout.Comment    = {layout.Channel.Comment}';
                T                       = struct2table(order_layout);
                set(app.Channel_UITable, 'Data', T);
            else
                set(app.Channel_UITable, 'Data', []);
            end
            
        end

        % Value changed function: ModalityDropDown
        function ModalityDropDownValueChanged(app, event)
            modality = app.ModalityDropDown.Value;
            if(isequal(modality,'EEG'))
                app.Button_Channel_template.Value = true;
                app.UseChanneltemplatePanel.Enable = 'on';
                app.RawdataPanel.Enable = 'off';
            else
                app.Button_Channel_raw_data.Value = true;
                app.UseChanneltemplatePanel.Enable = 'off';
                app.RawdataPanel.Enable = 'on';
            end
        end

        % Button pushed function: SelectRawDataBPathButton
        function SelectRawDataBPathButtonPushed(app, event)
            try
                folder = uigetdir("Select the Raw data base path");
                folder = strrep(folder,'\','/');
                app.RawDataBPathEditField.Value = folder;
            catch
            end
        end

        % Button pushed function: SelectHCPTemplPathButton
        function SelectHCPTemplPathButtonPushed(app, event)
            try
                if(isempty(app.HCPTemplatenameEditField.Value))
                    msgbox({'The HCP template name can not be empty.',...
                        'Please type a HCP Template name.'},'Info');
                    return;
                end
                template_name = app.HCPTemplatenameEditField.Value;
                folder = uigetdir("Select the Template basepath");
                if(~isfolder(fullfile(folder,template_name)))
                    msgbox({strcat("There is no folder with ",template_name," in the selected HCP Template folder."),...
                        'Please selcct a correct HCP Template folder or check the Template name filed.'},'Info');
                    app.HCPTemplPathEditField.Value = '';
                    return;
                end
                if(~isfile(fullfile(folder,template_name,'T1w','T1w.nii.gz')))
                    msgbox({'The template folder is not a HCP structure.',...
                        'Please check the HCP Template folder.'},'Info');
                    app.HCPTemplPathEditField.Value = '';
                    return;
                end
                app.HCPTemplPathEditField.Value = folder;
            catch
            end
        end

        % Callback function
        function SelectCHPTemplNBPathButtonPushed(app, event)
            try
                if(isempty(app.HCPTemplatenameEditField.Value))
                    msgbox({'The HCP template name can not be empty.',...
                        'Please type a HCP Template name.'},'Info');
                    return;
                end
                template_name = app.HCPTemplatenameEditField.Value;
                folder = uigetdir("Select the Template basepath");
                if(~isfolder(fullfile(folder,template_name)))
                    msgbox({strcat("There is no folder with ",template_name," in the selected Non-brain folder."),...
                        'Please selcct a correct Non-brain folder or check the Template name filed.'},'Info');
                    app.HCPTemplNBPathEditField.Value = '';
                    return;
                end
                if(~isfile(fullfile(folder,template_name,[template_name,'_outskin_mesh.nii.gz']))...
                        || ~isfile(fullfile(folder,template_name,[template_name,'_outskull_mesh.nii.gz']))...
                        || ~isfile(fullfile(folder,template_name,[template_name,'_inskull_mesh.nii.gz'])))
                msgbox({'One or more forders are not a FSL Bet output command.',...
                    'Please check the Non-brain Template folder.'},'Info');
                app.HCPTemplNBPathEditField.Value = '';
                return;
                end
                app.HCPTemplNBPathEditField.Value = folder;
            catch
            end
        end

        % Button pushed function: SelectHCPIndividPathButton
        function SelectHCPIndividPathButtonPushed(app, event)
            try
                folder = uigetdir("Select the Template basepath");
                structures = dir(folder);
                structures(ismember( {structures.name}, {'.', '..'})) = [];  %remove . and ..
                for i=1:length(structures)
                    structure = structures(i);
                    if(~isfile(fullfile(structure.folder,structure.name,'T1w','T1w.nii.gz')))
                        msgbox({'One or more forders are not a HCP structure.',...
                            'Please check the HCP Template folder.'},'Info');
                        break;
                    end
                end
                app.HCPIndividPathEditField.Value = folder;
            catch
            end
        end

        % Button pushed function: CancelButton
        function CancelButtonPushed(app, event)
            delete(app);
        end

        % Selection changed function: MethodsButtonGroup
        function MethodsButtonGroupSelectionChanged(app, event)
            if(app.Button_OwerlappingSpheres.Value)
                app.OverlappingSpheresPanel.Enable = 'on';
                app.OpenMEEGBEMPanel.Enable = 'off';
                app.DUNEuroFEMPanel.Enable = 'off';
            end
            if(app.Button_OpenMEEGBEM.Value)
                app.OverlappingSpheresPanel.Enable = 'off';
                app.OpenMEEGBEMPanel.Enable = 'on';
                app.DUNEuroFEMPanel.Enable = 'off';
            end
            if(app.Button_DUNEuroFEM.Value)
                app.OverlappingSpheresPanel.Enable = 'off';
                app.OpenMEEGBEMPanel.Enable = 'off';
                app.DUNEuroFEMPanel.Enable = 'on';
            end
        end

        % Callback function
        function SelectRawDataFPathButtonPushed(app, event)
            try
                if(isempty(app.RawDataBPathEditField.Value))
                    msgbox('Select first the base path of the raw data.','Info');
                    return;
                end
                [file_name,file_path] = uigetfile({'*.mat';'*.mff';'*.edf';'*.*'},'Select a reference file to import');
                file_path = strrep(file_path,'\','/');
                base_path = app.RawDataBPathEditField.Value;
                file_parts = split(file_path,base_path);
                if(isequal(length(file_parts),1))
                    msgbox({'The base path and file path do not match in the first part.', ...
                        'Please check the configuration.'},'Info');                    
                    return;
                end
                SubID_parts = split(file_parts{2},'/');
                SubID = SubID_parts{2};
                ref_path = split(file_path,SubID);
                ref_path = strcat(ref_path{2},file_name);
                ref_path = strrep(ref_path,SubID,'SubID');
                app.RawDataFileEditField.Value = ref_path;
            catch
                
            end
        end

        % Button pushed function: SelectHCPNonBrainPathButton
        function SelectHCPNonBrainPathButtonPushed(app, event)
            try
                folder = uigetdir("Select the Template basepath");
                structures = dir(folder);
                structures(ismember( {structures.name}, {'.', '..'})) = [];  %remove . and ..
                for i=1:length(structures)
                    structure = structures(i);
                    if(~isfile(fullfile(structure.folder,structure.name,[structure.name,'_outskin_mesh.nii.gz']))...
                            || ~isfile(fullfile(structure.folder,structure.name,[structure.name,'_outskull_mesh.nii.gz']))...
                            || ~isfile(fullfile(structure.folder,structure.name,[structure.name,'_inskull_mesh.nii.gz'])))
                    msgbox({'One or more forders are not a FSL Bet output command.',...
                        'Please check the Non-brain Template folder.'},'Info');
                    break;
                    end
                end
                app.NonBrainPathEditField.Value = folder;
            catch
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.794571068124603 0.794571068124603 0.794571068124603];
            app.UIFigure.Position = [100 100 713 561];
            app.UIFigure.Name = 'MATLAB App';

            % Create CancelButton
            app.CancelButton = uibutton(app.UIFigure, 'push');
            app.CancelButton.ButtonPushedFcn = createCallbackFcn(app, @CancelButtonPushed, true);
            app.CancelButton.FontWeight = 'bold';
            app.CancelButton.Position = [477 20 100 22];
            app.CancelButton.Text = 'Cancel';

            % Create SetpropertiesButton
            app.SetpropertiesButton = uibutton(app.UIFigure, 'push');
            app.SetpropertiesButton.FontWeight = 'bold';
            app.SetpropertiesButton.Position = [589 20 100 22];
            app.SetpropertiesButton.Text = 'Set properties';

            % Create ParamsconfigurationPanel
            app.ParamsconfigurationPanel = uipanel(app.UIFigure);
            app.ParamsconfigurationPanel.Title = 'Params configuration';
            app.ParamsconfigurationPanel.FontWeight = 'bold';
            app.ParamsconfigurationPanel.FontSize = 14;
            app.ParamsconfigurationPanel.Position = [24 58 665 480];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.ParamsconfigurationPanel);
            app.TabGroup.Position = [5 5 655 450];

            % Create GeneralsTab
            app.GeneralsTab = uitab(app.TabGroup);
            app.GeneralsTab.Title = 'Generals';

            % Create GeneralsparamsPanel
            app.GeneralsparamsPanel = uipanel(app.GeneralsTab);
            app.GeneralsparamsPanel.Title = 'Generals params (*)';
            app.GeneralsparamsPanel.FontWeight = 'bold';
            app.GeneralsparamsPanel.Position = [7 9 639 404];

            % Create ModalityLabel
            app.ModalityLabel = uilabel(app.GeneralsparamsPanel);
            app.ModalityLabel.HorizontalAlignment = 'right';
            app.ModalityLabel.FontWeight = 'bold';
            app.ModalityLabel.Position = [66 340 58 22];
            app.ModalityLabel.Text = 'Modality:';

            % Create ModalityDropDown
            app.ModalityDropDown = uidropdown(app.GeneralsparamsPanel);
            app.ModalityDropDown.Items = {'--Select--', 'EEG', 'MEG'};
            app.ModalityDropDown.ValueChangedFcn = createCallbackFcn(app, @ModalityDropDownValueChanged, true);
            app.ModalityDropDown.Position = [135 340 131 22];
            app.ModalityDropDown.Value = '--Select--';

            % Create ProtocolnameLabel
            app.ProtocolnameLabel = uilabel(app.GeneralsparamsPanel);
            app.ProtocolnameLabel.HorizontalAlignment = 'right';
            app.ProtocolnameLabel.FontWeight = 'bold';
            app.ProtocolnameLabel.Position = [30 295 93 22];
            app.ProtocolnameLabel.Text = 'Protocol name:';

            % Create ProtocolnameEditField
            app.ProtocolnameEditField = uieditfield(app.GeneralsparamsPanel, 'text');
            app.ProtocolnameEditField.Position = [135 295 487 22];

            % Create ResetprotocolSwitchLabel
            app.ResetprotocolSwitchLabel = uilabel(app.GeneralsparamsPanel);
            app.ResetprotocolSwitchLabel.HorizontalAlignment = 'center';
            app.ResetprotocolSwitchLabel.FontWeight = 'bold';
            app.ResetprotocolSwitchLabel.Position = [36 250 94 22];
            app.ResetprotocolSwitchLabel.Text = 'Reset protocol:';

            % Create ResetprotocolSwitch
            app.ResetprotocolSwitch = uiswitch(app.GeneralsparamsPanel, 'slider');
            app.ResetprotocolSwitch.Items = {'No', 'Yes'};
            app.ResetprotocolSwitch.Position = [157 251 45 20];
            app.ResetprotocolSwitch.Value = 'No';

            % Create AfterMaQCSwitchLabel
            app.AfterMaQCSwitchLabel = uilabel(app.GeneralsparamsPanel);
            app.AfterMaQCSwitchLabel.HorizontalAlignment = 'center';
            app.AfterMaQCSwitchLabel.FontWeight = 'bold';
            app.AfterMaQCSwitchLabel.Position = [50 199 76 22];
            app.AfterMaQCSwitchLabel.Text = 'After MaQC:';

            % Create AfterMaQCSwitch
            app.AfterMaQCSwitch = uiswitch(app.GeneralsparamsPanel, 'slider');
            app.AfterMaQCSwitch.Items = {'No', 'Yes'};
            app.AfterMaQCSwitch.Position = [158 200 45 20];
            app.AfterMaQCSwitch.Value = 'No';

            % Create SelectBSTButton
            app.SelectBSTButton = uibutton(app.GeneralsparamsPanel, 'push');
            app.SelectBSTButton.ButtonPushedFcn = createCallbackFcn(app, @SelectBSTButtonPushed, true);
            app.SelectBSTButton.FontWeight = 'bold';
            app.SelectBSTButton.Position = [547 142 76 22];
            app.SelectBSTButton.Text = 'Select';

            % Create SelectBST_dbButton
            app.SelectBST_dbButton = uibutton(app.GeneralsparamsPanel, 'push');
            app.SelectBST_dbButton.ButtonPushedFcn = createCallbackFcn(app, @SelectBST_dbButtonPushed, true);
            app.SelectBST_dbButton.FontWeight = 'bold';
            app.SelectBST_dbButton.Position = [547 90 76 22];
            app.SelectBST_dbButton.Text = 'Select';

            % Create SelectWorkspaceButton
            app.SelectWorkspaceButton = uibutton(app.GeneralsparamsPanel, 'push');
            app.SelectWorkspaceButton.ButtonPushedFcn = createCallbackFcn(app, @SelectWorkspaceButtonPushed, true);
            app.SelectWorkspaceButton.FontWeight = 'bold';
            app.SelectWorkspaceButton.Position = [547 39 76 22];
            app.SelectWorkspaceButton.Text = 'Select';

            % Create BrainstormdbpathLabel
            app.BrainstormdbpathLabel = uilabel(app.GeneralsparamsPanel);
            app.BrainstormdbpathLabel.HorizontalAlignment = 'right';
            app.BrainstormdbpathLabel.FontWeight = 'bold';
            app.BrainstormdbpathLabel.Position = [2 90 120 22];
            app.BrainstormdbpathLabel.Text = 'Brainstorm db path:';

            % Create BSTdbpathEditField
            app.BSTdbpathEditField = uieditfield(app.GeneralsparamsPanel, 'text');
            app.BSTdbpathEditField.Position = [137 90 400 22];
            app.BSTdbpathEditField.Value = 'local';

            % Create BraninstormpathLabel
            app.BraninstormpathLabel = uilabel(app.GeneralsparamsPanel);
            app.BraninstormpathLabel.HorizontalAlignment = 'right';
            app.BraninstormpathLabel.FontWeight = 'bold';
            app.BraninstormpathLabel.Position = [12 142 110 22];
            app.BraninstormpathLabel.Text = 'Braninstorm path:';

            % Create BSTpathEditField
            app.BSTpathEditField = uieditfield(app.GeneralsparamsPanel, 'text');
            app.BSTpathEditField.Position = [137 142 401 22];

            % Create WorkspacepathEditFieldLabel
            app.WorkspacepathEditFieldLabel = uilabel(app.GeneralsparamsPanel);
            app.WorkspacepathEditFieldLabel.HorizontalAlignment = 'right';
            app.WorkspacepathEditFieldLabel.FontWeight = 'bold';
            app.WorkspacepathEditFieldLabel.Position = [20 38 102 22];
            app.WorkspacepathEditFieldLabel.Text = 'Workspace path:';

            % Create WorkspacepathEditField
            app.WorkspacepathEditField = uieditfield(app.GeneralsparamsPanel, 'text');
            app.WorkspacepathEditField.Position = [137 38 400 22];

            % Create ImportAnatomyTab
            app.ImportAnatomyTab = uitab(app.TabGroup);
            app.ImportAnatomyTab.Title = 'Import Anatomy';

            % Create SelectAnatomyoptionButtonGroup
            app.SelectAnatomyoptionButtonGroup = uibuttongroup(app.ImportAnatomyTab);
            app.SelectAnatomyoptionButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @SelectAnatomyoptionButtonGroupSelectionChanged, true);
            app.SelectAnatomyoptionButtonGroup.Title = 'Select Anatomy option';
            app.SelectAnatomyoptionButtonGroup.FontWeight = 'bold';
            app.SelectAnatomyoptionButtonGroup.Position = [5 162 645 260];

            % Create Button_BST_Default
            app.Button_BST_Default = uiradiobutton(app.SelectAnatomyoptionButtonGroup);
            app.Button_BST_Default.Text = '';
            app.Button_BST_Default.Position = [5 218 25 22];
            app.Button_BST_Default.Value = true;

            % Create Button_HCP_Template
            app.Button_HCP_Template = uiradiobutton(app.SelectAnatomyoptionButtonGroup);
            app.Button_HCP_Template.Text = '';
            app.Button_HCP_Template.Position = [5 168 25 22];

            % Create Button_HCP_Individual
            app.Button_HCP_Individual = uiradiobutton(app.SelectAnatomyoptionButtonGroup);
            app.Button_HCP_Individual.Text = '';
            app.Button_HCP_Individual.Position = [4 59 25 22];

            % Create BSTDefaultAnatomyPanel
            app.BSTDefaultAnatomyPanel = uipanel(app.SelectAnatomyoptionButtonGroup);
            app.BSTDefaultAnatomyPanel.Title = 'BST Default Anatomy';
            app.BSTDefaultAnatomyPanel.FontWeight = 'bold';
            app.BSTDefaultAnatomyPanel.Position = [23 191 616 48];

            % Create TemplatenameDropDownLabel
            app.TemplatenameDropDownLabel = uilabel(app.BSTDefaultAnatomyPanel);
            app.TemplatenameDropDownLabel.HorizontalAlignment = 'right';
            app.TemplatenameDropDownLabel.FontWeight = 'bold';
            app.TemplatenameDropDownLabel.Position = [21 4 96 22];
            app.TemplatenameDropDownLabel.Text = 'Template name:';

            % Create AnatomyTemplateDropDown
            app.AnatomyTemplateDropDown = uidropdown(app.BSTDefaultAnatomyPanel);
            app.AnatomyTemplateDropDown.Position = [124 4 207 22];

            % Create AtlasLabel
            app.AtlasLabel = uilabel(app.BSTDefaultAnatomyPanel);
            app.AtlasLabel.HorizontalAlignment = 'right';
            app.AtlasLabel.FontWeight = 'bold';
            app.AtlasLabel.Position = [350 3 39 22];
            app.AtlasLabel.Text = 'Atlas:';

            % Create AnatomyTemplateAtlasDropDown
            app.AnatomyTemplateAtlasDropDown = uidropdown(app.BSTDefaultAnatomyPanel);
            app.AnatomyTemplateAtlasDropDown.Position = [396 3 158 22];

            % Create HCPTemplatePanel
            app.HCPTemplatePanel = uipanel(app.SelectAnatomyoptionButtonGroup);
            app.HCPTemplatePanel.Enable = 'off';
            app.HCPTemplatePanel.Title = 'HCP Template';
            app.HCPTemplatePanel.FontWeight = 'bold';
            app.HCPTemplatePanel.Position = [23 82 616 106];

            % Create SelectHCPTemplPathButton
            app.SelectHCPTemplPathButton = uibutton(app.HCPTemplatePanel, 'push');
            app.SelectHCPTemplPathButton.ButtonPushedFcn = createCallbackFcn(app, @SelectHCPTemplPathButtonPushed, true);
            app.SelectHCPTemplPathButton.FontWeight = 'bold';
            app.SelectHCPTemplPathButton.Position = [544 35 60 22];
            app.SelectHCPTemplPathButton.Text = 'Select';

            % Create AnatomypathLabel
            app.AnatomypathLabel = uilabel(app.HCPTemplatePanel);
            app.AnatomypathLabel.HorizontalAlignment = 'right';
            app.AnatomypathLabel.FontWeight = 'bold';
            app.AnatomypathLabel.Position = [6 35 89 22];
            app.AnatomypathLabel.Text = 'Anatomy path:';

            % Create HCPTemplPathEditField
            app.HCPTemplPathEditField = uieditfield(app.HCPTemplatePanel, 'text');
            app.HCPTemplPathEditField.Position = [104 35 434 22];

            % Create TemplatenameEditFieldLabel
            app.TemplatenameEditFieldLabel = uilabel(app.HCPTemplatePanel);
            app.TemplatenameEditFieldLabel.HorizontalAlignment = 'right';
            app.TemplatenameEditFieldLabel.FontWeight = 'bold';
            app.TemplatenameEditFieldLabel.Position = [-1 61 96 22];
            app.TemplatenameEditFieldLabel.Text = 'Template name:';

            % Create HCPTemplatenameEditField
            app.HCPTemplatenameEditField = uieditfield(app.HCPTemplatePanel, 'text');
            app.HCPTemplatenameEditField.Position = [104 61 196 22];

            % Create Tw1filenameLabel_2
            app.Tw1filenameLabel_2 = uilabel(app.HCPTemplatePanel);
            app.Tw1filenameLabel_2.HorizontalAlignment = 'right';
            app.Tw1filenameLabel_2.FontWeight = 'bold';
            app.Tw1filenameLabel_2.Position = [8 8 87 22];
            app.Tw1filenameLabel_2.Text = 'Tw1 file name:';

            % Create HCPTemplateT1wEditField
            app.HCPTemplateT1wEditField = uieditfield(app.HCPTemplatePanel, 'text');
            app.HCPTemplateT1wEditField.Position = [104 8 199 22];

            % Create AtlasfilenameLabel_2
            app.AtlasfilenameLabel_2 = uilabel(app.HCPTemplatePanel);
            app.AtlasfilenameLabel_2.HorizontalAlignment = 'right';
            app.AtlasfilenameLabel_2.FontWeight = 'bold';
            app.AtlasfilenameLabel_2.Position = [315 8 94 22];
            app.AtlasfilenameLabel_2.Text = 'Atlas file name:';

            % Create HCPTemplateAtlasEditField
            app.HCPTemplateAtlasEditField = uieditfield(app.HCPTemplatePanel, 'text');
            app.HCPTemplateAtlasEditField.Position = [414 8 189 22];

            % Create HCPIndividualPanel
            app.HCPIndividualPanel = uipanel(app.SelectAnatomyoptionButtonGroup);
            app.HCPIndividualPanel.Enable = 'off';
            app.HCPIndividualPanel.Title = 'HCP Individual';
            app.HCPIndividualPanel.FontWeight = 'bold';
            app.HCPIndividualPanel.Position = [23 3 616 77];

            % Create SelectHCPIndividPathButton
            app.SelectHCPIndividPathButton = uibutton(app.HCPIndividualPanel, 'push');
            app.SelectHCPIndividPathButton.ButtonPushedFcn = createCallbackFcn(app, @SelectHCPIndividPathButtonPushed, true);
            app.SelectHCPIndividPathButton.FontWeight = 'bold';
            app.SelectHCPIndividPathButton.Position = [543 32 60 22];
            app.SelectHCPIndividPathButton.Text = 'Select';

            % Create AnatomypathLabel_2
            app.AnatomypathLabel_2 = uilabel(app.HCPIndividualPanel);
            app.AnatomypathLabel_2.HorizontalAlignment = 'right';
            app.AnatomypathLabel_2.FontWeight = 'bold';
            app.AnatomypathLabel_2.Position = [2 32 89 22];
            app.AnatomypathLabel_2.Text = 'Anatomy path:';

            % Create HCPIndividPathEditField
            app.HCPIndividPathEditField = uieditfield(app.HCPIndividualPanel, 'text');
            app.HCPIndividPathEditField.Position = [100 32 435 22];

            % Create Tw1filenameLabel
            app.Tw1filenameLabel = uilabel(app.HCPIndividualPanel);
            app.Tw1filenameLabel.HorizontalAlignment = 'right';
            app.Tw1filenameLabel.FontWeight = 'bold';
            app.Tw1filenameLabel.Position = [4 5 87 22];
            app.Tw1filenameLabel.Text = 'Tw1 file name:';

            % Create HCPIndivT1wEditField
            app.HCPIndivT1wEditField = uieditfield(app.HCPIndividualPanel, 'text');
            app.HCPIndivT1wEditField.Position = [100 5 202 22];

            % Create AtlasfilenameLabel
            app.AtlasfilenameLabel = uilabel(app.HCPIndividualPanel);
            app.AtlasfilenameLabel.HorizontalAlignment = 'right';
            app.AtlasfilenameLabel.FontWeight = 'bold';
            app.AtlasfilenameLabel.Position = [315 5 94 22];
            app.AtlasfilenameLabel.Text = 'Atlas file name:';

            % Create HCPIndivAtlasEditField
            app.HCPIndivAtlasEditField = uieditfield(app.HCPIndividualPanel, 'text');
            app.HCPIndivAtlasEditField.Position = [415 5 188 22];

            % Create CommonparamsIAPanel
            app.CommonparamsIAPanel = uipanel(app.ImportAnatomyTab);
            app.CommonparamsIAPanel.Title = 'Common params';
            app.CommonparamsIAPanel.FontWeight = 'bold';
            app.CommonparamsIAPanel.Position = [5 5 646 153];

            % Create SelectMRITransPathButton
            app.SelectMRITransPathButton = uibutton(app.CommonparamsIAPanel, 'push');
            app.SelectMRITransPathButton.FontWeight = 'bold';
            app.SelectMRITransPathButton.Position = [390 74 60 22];
            app.SelectMRITransPathButton.Text = 'Select';

            % Create SelectHCPNonBrainPathButton
            app.SelectHCPNonBrainPathButton = uibutton(app.CommonparamsIAPanel, 'push');
            app.SelectHCPNonBrainPathButton.ButtonPushedFcn = createCallbackFcn(app, @SelectHCPNonBrainPathButtonPushed, true);
            app.SelectHCPNonBrainPathButton.FontWeight = 'bold';
            app.SelectHCPNonBrainPathButton.Position = [572 40 60 22];
            app.SelectHCPNonBrainPathButton.Text = 'Select';

            % Create NoverticesLabel
            app.NoverticesLabel = uilabel(app.CommonparamsIAPanel);
            app.NoverticesLabel.FontWeight = 'bold';
            app.NoverticesLabel.Position = [48 8 78 22];
            app.NoverticesLabel.Text = 'No. vertices:';

            % Create pathLabel
            app.pathLabel = uilabel(app.CommonparamsIAPanel);
            app.pathLabel.HorizontalAlignment = 'right';
            app.pathLabel.Position = [121 74 32 22];
            app.pathLabel.Text = 'path:';

            % Create MRITransPathEditField
            app.MRITransPathEditField = uieditfield(app.CommonparamsIAPanel, 'text');
            app.MRITransPathEditField.Position = [156 74 232 22];

            % Create NonbrainsurfacesLabel
            app.NonbrainsurfacesLabel = uilabel(app.CommonparamsIAPanel);
            app.NonbrainsurfacesLabel.HorizontalAlignment = 'right';
            app.NonbrainsurfacesLabel.FontWeight = 'bold';
            app.NonbrainsurfacesLabel.Position = [0 40 119 22];
            app.NonbrainsurfacesLabel.Text = 'Non-brain surfaces:';

            % Create NonBrainPathEditField
            app.NonBrainPathEditField = uieditfield(app.CommonparamsIAPanel, 'text');
            app.NonBrainPathEditField.Position = [127 40 441 22];

            % Create HeadEditFieldLabel
            app.HeadEditFieldLabel = uilabel(app.CommonparamsIAPanel);
            app.HeadEditFieldLabel.HorizontalAlignment = 'right';
            app.HeadEditFieldLabel.Position = [138 8 38 22];
            app.HeadEditFieldLabel.Text = 'Head:';

            % Create HeadEditField
            app.HeadEditField = uieditfield(app.CommonparamsIAPanel, 'numeric');
            app.HeadEditField.Limits = [5000 15000];
            app.HeadEditField.Position = [183 8 63 22];
            app.HeadEditField.Value = 8000;

            % Create SkullEditFieldLabel
            app.SkullEditFieldLabel = uilabel(app.CommonparamsIAPanel);
            app.SkullEditFieldLabel.HorizontalAlignment = 'right';
            app.SkullEditFieldLabel.Position = [301 8 35 22];
            app.SkullEditFieldLabel.Text = 'Skull:';

            % Create SkullEditField
            app.SkullEditField = uieditfield(app.CommonparamsIAPanel, 'numeric');
            app.SkullEditField.Limits = [5000 15000];
            app.SkullEditField.Position = [345 8 67 22];
            app.SkullEditField.Value = 8000;

            % Create CortexEditFieldLabel
            app.CortexEditFieldLabel = uilabel(app.CommonparamsIAPanel);
            app.CortexEditFieldLabel.HorizontalAlignment = 'right';
            app.CortexEditFieldLabel.Position = [452 8 44 22];
            app.CortexEditFieldLabel.Text = 'Cortex:';

            % Create CortexEditField
            app.CortexEditField = uieditfield(app.CommonparamsIAPanel, 'numeric');
            app.CortexEditField.Limits = [5000 15000];
            app.CortexEditField.Position = [503 8 61 22];
            app.CortexEditField.Value = 8000;

            % Create LayerdescriptorLabel
            app.LayerdescriptorLabel = uilabel(app.CommonparamsIAPanel);
            app.LayerdescriptorLabel.HorizontalAlignment = 'right';
            app.LayerdescriptorLabel.FontWeight = 'bold';
            app.LayerdescriptorLabel.Position = [16 105 104 22];
            app.LayerdescriptorLabel.Text = 'Layer descriptor:';

            % Create CommonLayerDiscrpDropDown
            app.CommonLayerDiscrpDropDown = uidropdown(app.CommonparamsIAPanel);
            app.CommonLayerDiscrpDropDown.Items = {'--Select--', 'Pial', 'Midthickness', 'White', 'FS_LR', 'Bigbrain'};
            app.CommonLayerDiscrpDropDown.Position = [127 105 207 22];
            app.CommonLayerDiscrpDropDown.Value = '--Select--';

            % Create MRItransformationLabel
            app.MRItransformationLabel = uilabel(app.CommonparamsIAPanel);
            app.MRItransformationLabel.FontWeight = 'bold';
            app.MRItransformationLabel.Position = [5 74 119 22];
            app.MRItransformationLabel.Text = 'MRI transformation:';

            % Create filenameLabel
            app.filenameLabel = uilabel(app.CommonparamsIAPanel);
            app.filenameLabel.HorizontalAlignment = 'right';
            app.filenameLabel.Position = [452 75 58 22];
            app.filenameLabel.Text = 'file name:';

            % Create MRITransFileEditField
            app.MRITransFileEditField = uieditfield(app.CommonparamsIAPanel, 'text');
            app.MRITransFileEditField.Position = [512 75 120 22];

            % Create ImportChannelTab
            app.ImportChannelTab = uitab(app.TabGroup);
            app.ImportChannelTab.Title = 'Import Channel';

            % Create SelectChanneloptionButtonGroup
            app.SelectChanneloptionButtonGroup = uibuttongroup(app.ImportChannelTab);
            app.SelectChanneloptionButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @SelectChanneloptionButtonGroupSelectionChanged, true);
            app.SelectChanneloptionButtonGroup.Title = 'Select Channel option';
            app.SelectChanneloptionButtonGroup.FontWeight = 'bold';
            app.SelectChanneloptionButtonGroup.Position = [5 7 644 413];

            % Create Button_Channel_template
            app.Button_Channel_template = uiradiobutton(app.SelectChanneloptionButtonGroup);
            app.Button_Channel_template.Text = '';
            app.Button_Channel_template.Position = [5 368 18 22];
            app.Button_Channel_template.Value = true;

            % Create Button_Channel_raw_data
            app.Button_Channel_raw_data = uiradiobutton(app.SelectChanneloptionButtonGroup);
            app.Button_Channel_raw_data.Text = '';
            app.Button_Channel_raw_data.Position = [4 98 18 22];

            % Create UseChanneltemplatePanel
            app.UseChanneltemplatePanel = uipanel(app.SelectChanneloptionButtonGroup);
            app.UseChanneltemplatePanel.Title = 'Use Channel template';
            app.UseChanneltemplatePanel.FontWeight = 'bold';
            app.UseChanneltemplatePanel.Position = [21 123 617 266];

            % Create GroupDropDownLabel
            app.GroupDropDownLabel = uilabel(app.UseChanneltemplatePanel);
            app.GroupDropDownLabel.HorizontalAlignment = 'right';
            app.GroupDropDownLabel.Position = [12 217 42 22];
            app.GroupDropDownLabel.Text = 'Group:';

            % Create ChannTemplateGroupDropDown
            app.ChannTemplateGroupDropDown = uidropdown(app.UseChanneltemplatePanel);
            app.ChannTemplateGroupDropDown.ValueChangedFcn = createCallbackFcn(app, @ChannTemplateGroupDropDownValueChanged, true);
            app.ChannTemplateGroupDropDown.Position = [57 217 116 22];

            % Create TemplatenameDropDownLabel_2
            app.TemplatenameDropDownLabel_2 = uilabel(app.UseChanneltemplatePanel);
            app.TemplatenameDropDownLabel_2.HorizontalAlignment = 'right';
            app.TemplatenameDropDownLabel_2.Position = [188 217 91 22];
            app.TemplatenameDropDownLabel_2.Text = 'Template name:';

            % Create ChannTemplateNameDropDown
            app.ChannTemplateNameDropDown = uidropdown(app.UseChanneltemplatePanel);
            app.ChannTemplateNameDropDown.ValueChangedFcn = createCallbackFcn(app, @ChannTemplateNameDropDownValueChanged, true);
            app.ChannTemplateNameDropDown.Position = [281 217 180 22];

            % Create Channel_UITable
            app.Channel_UITable = uitable(app.UseChanneltemplatePanel);
            app.Channel_UITable.ColumnName = {'No.'; 'Name'; 'Type'; 'Location'; 'Comment'};
            app.Channel_UITable.ColumnWidth = {35, 'auto', 'auto', 'auto', 'auto'};
            app.Channel_UITable.RowName = {};
            app.Channel_UITable.Position = [4 6 609 205];

            % Create RawdataPanel
            app.RawdataPanel = uipanel(app.SelectChanneloptionButtonGroup);
            app.RawdataPanel.Enable = 'off';
            app.RawdataPanel.Title = 'Use Raw data';
            app.RawdataPanel.FontWeight = 'bold';
            app.RawdataPanel.Position = [21 7 617 112];

            % Create SelectRawDataBPathButton
            app.SelectRawDataBPathButton = uibutton(app.RawdataPanel, 'push');
            app.SelectRawDataBPathButton.ButtonPushedFcn = createCallbackFcn(app, @SelectRawDataBPathButtonPushed, true);
            app.SelectRawDataBPathButton.FontWeight = 'bold';
            app.SelectRawDataBPathButton.Position = [545 62 60 22];
            app.SelectRawDataBPathButton.Text = 'Select';

            % Create BasepathLabel
            app.BasepathLabel = uilabel(app.RawdataPanel);
            app.BasepathLabel.HorizontalAlignment = 'right';
            app.BasepathLabel.FontWeight = 'bold';
            app.BasepathLabel.Position = [24 62 67 22];
            app.BasepathLabel.Text = 'Base path:';

            % Create RawDataBPathEditField
            app.RawDataBPathEditField = uieditfield(app.RawdataPanel, 'text');
            app.RawDataBPathEditField.Position = [100 62 439 22];

            % Create NameLabel
            app.NameLabel = uilabel(app.RawdataPanel);
            app.NameLabel.HorizontalAlignment = 'right';
            app.NameLabel.FontWeight = 'bold';
            app.NameLabel.Position = [49 33 42 22];
            app.NameLabel.Text = 'Name:';

            % Create RawDataFileEditField
            app.RawDataFileEditField = uieditfield(app.RawdataPanel, 'text');
            app.RawDataFileEditField.Position = [100 33 279 22];

            % Create FormatDropDownLabel
            app.FormatDropDownLabel = uilabel(app.RawdataPanel);
            app.FormatDropDownLabel.HorizontalAlignment = 'right';
            app.FormatDropDownLabel.FontWeight = 'bold';
            app.FormatDropDownLabel.Position = [41 6 50 22];
            app.FormatDropDownLabel.Text = 'Format:';

            % Create RawDataFormatDropDown
            app.RawDataFormatDropDown = uidropdown(app.RawdataPanel);
            app.RawDataFormatDropDown.Items = {'-Select-', 'mat', 'mff', 'edf', '4D'};
            app.RawDataFormatDropDown.Position = [100 6 193 22];
            app.RawDataFormatDropDown.Value = '-Select-';

            % Create IsFileSwitchLabel
            app.IsFileSwitchLabel = uilabel(app.RawdataPanel);
            app.IsFileSwitchLabel.HorizontalAlignment = 'center';
            app.IsFileSwitchLabel.FontWeight = 'bold';
            app.IsFileSwitchLabel.Position = [394 32 44 22];
            app.IsFileSwitchLabel.Text = 'Is File:';

            % Create RawDataIsFileSwitch
            app.RawDataIsFileSwitch = uiswitch(app.RawdataPanel, 'slider');
            app.RawDataIsFileSwitch.Items = {'No', 'Yes'};
            app.RawDataIsFileSwitch.Position = [464 32 45 20];
            app.RawDataIsFileSwitch.Value = 'Yes';

            % Create ComputeHeadmodelTab
            app.ComputeHeadmodelTab = uitab(app.TabGroup);
            app.ComputeHeadmodelTab.Title = 'Compute Headmodel';

            % Create MethodsButtonGroup
            app.MethodsButtonGroup = uibuttongroup(app.ComputeHeadmodelTab);
            app.MethodsButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @MethodsButtonGroupSelectionChanged, true);
            app.MethodsButtonGroup.Title = 'Methods';
            app.MethodsButtonGroup.FontWeight = 'bold';
            app.MethodsButtonGroup.Position = [6 5 644 288];

            % Create Button_OwerlappingSpheres
            app.Button_OwerlappingSpheres = uiradiobutton(app.MethodsButtonGroup);
            app.Button_OwerlappingSpheres.Text = '';
            app.Button_OwerlappingSpheres.Position = [5 245 25 22];
            app.Button_OwerlappingSpheres.Value = true;

            % Create Button_OpenMEEGBEM
            app.Button_OpenMEEGBEM = uiradiobutton(app.MethodsButtonGroup);
            app.Button_OpenMEEGBEM.Text = '';
            app.Button_OpenMEEGBEM.Position = [5 214 25 22];

            % Create Button_DUNEuroFEM
            app.Button_DUNEuroFEM = uiradiobutton(app.MethodsButtonGroup);
            app.Button_DUNEuroFEM.Text = '';
            app.Button_DUNEuroFEM.Position = [4 148 25 22];

            % Create OverlappingSpheresPanel
            app.OverlappingSpheresPanel = uipanel(app.MethodsButtonGroup);
            app.OverlappingSpheresPanel.Title = 'Overlapping Spheres';
            app.OverlappingSpheresPanel.FontWeight = 'bold';
            app.OverlappingSpheresPanel.Position = [19 237 621 30];

            % Create OpenMEEGBEMPanel
            app.OpenMEEGBEMPanel = uipanel(app.MethodsButtonGroup);
            app.OpenMEEGBEMPanel.Enable = 'off';
            app.OpenMEEGBEMPanel.Title = 'OpenMEEG BEM';
            app.OpenMEEGBEMPanel.FontWeight = 'bold';
            app.OpenMEEGBEMPanel.Position = [20 170 620 65];

            % Create isAdjointSwitchLabel
            app.isAdjointSwitchLabel = uilabel(app.OpenMEEGBEMPanel);
            app.isAdjointSwitchLabel.HorizontalAlignment = 'center';
            app.isAdjointSwitchLabel.FontWeight = 'bold';
            app.isAdjointSwitchLabel.Position = [6 13 61 22];
            app.isAdjointSwitchLabel.Text = 'isAdjoint:';

            % Create isAdjointSwitch
            app.isAdjointSwitch = uiswitch(app.OpenMEEGBEMPanel, 'slider');
            app.isAdjointSwitch.Items = {'No', 'Yes'};
            app.isAdjointSwitch.Position = [89 16 39 17];
            app.isAdjointSwitch.Value = 'No';

            % Create isAdaptativeSwitchLabel
            app.isAdaptativeSwitchLabel = uilabel(app.OpenMEEGBEMPanel);
            app.isAdaptativeSwitchLabel.HorizontalAlignment = 'center';
            app.isAdaptativeSwitchLabel.FontWeight = 'bold';
            app.isAdaptativeSwitchLabel.Position = [164 13 81 22];
            app.isAdaptativeSwitchLabel.Text = 'isAdaptative:';

            % Create isAdaptativeSwitch
            app.isAdaptativeSwitch = uiswitch(app.OpenMEEGBEMPanel, 'slider');
            app.isAdaptativeSwitch.Items = {'No', 'Yes'};
            app.isAdaptativeSwitch.Position = [264 16 39 17];
            app.isAdaptativeSwitch.Value = 'Yes';

            % Create isSplitSwitchLabel
            app.isSplitSwitchLabel = uilabel(app.OpenMEEGBEMPanel);
            app.isSplitSwitchLabel.HorizontalAlignment = 'center';
            app.isSplitSwitchLabel.FontWeight = 'bold';
            app.isSplitSwitchLabel.Position = [340 13 46 22];
            app.isSplitSwitchLabel.Text = 'isSplit:';

            % Create isSplitSwitch
            app.isSplitSwitch = uiswitch(app.OpenMEEGBEMPanel, 'slider');
            app.isSplitSwitch.Items = {'No', 'Yes'};
            app.isSplitSwitch.Position = [405 16 39 17];
            app.isSplitSwitch.Value = 'No';

            % Create SplitLengthSpinnerLabel
            app.SplitLengthSpinnerLabel = uilabel(app.OpenMEEGBEMPanel);
            app.SplitLengthSpinnerLabel.HorizontalAlignment = 'right';
            app.SplitLengthSpinnerLabel.FontWeight = 'bold';
            app.SplitLengthSpinnerLabel.Position = [479 13 75 22];
            app.SplitLengthSpinnerLabel.Text = 'SplitLength:';

            % Create SplitLengthSpinner
            app.SplitLengthSpinner = uispinner(app.OpenMEEGBEMPanel);
            app.SplitLengthSpinner.Position = [555 13 60 22];
            app.SplitLengthSpinner.Value = 4000;

            % Create DUNEuroFEMPanel
            app.DUNEuroFEMPanel = uipanel(app.MethodsButtonGroup);
            app.DUNEuroFEMPanel.Enable = 'off';
            app.DUNEuroFEMPanel.Title = 'DUNEuro FEM';
            app.DUNEuroFEMPanel.FontWeight = 'bold';
            app.DUNEuroFEMPanel.Position = [20 4 619 164];

            % Create FemCondEditFieldLabel
            app.FemCondEditFieldLabel = uilabel(app.DUNEuroFEMPanel);
            app.FemCondEditFieldLabel.HorizontalAlignment = 'right';
            app.FemCondEditFieldLabel.FontWeight = 'bold';
            app.FemCondEditFieldLabel.Position = [205 116 65 22];
            app.FemCondEditFieldLabel.Text = 'FemCond:';

            % Create FemCondEditField
            app.FemCondEditField = uieditfield(app.DUNEuroFEMPanel, 'text');
            app.FemCondEditField.HorizontalAlignment = 'right';
            app.FemCondEditField.Position = [276 116 112 22];
            app.FemCondEditField.Value = '[1.79,0.0080,0.43]';

            % Create FemSelectEditFieldLabel
            app.FemSelectEditFieldLabel = uilabel(app.DUNEuroFEMPanel);
            app.FemSelectEditFieldLabel.HorizontalAlignment = 'right';
            app.FemSelectEditFieldLabel.FontWeight = 'bold';
            app.FemSelectEditFieldLabel.Position = [14 116 70 22];
            app.FemSelectEditFieldLabel.Text = 'FemSelect:';

            % Create FemSelectEditField
            app.FemSelectEditField = uieditfield(app.DUNEuroFEMPanel, 'text');
            app.FemSelectEditField.HorizontalAlignment = 'right';
            app.FemSelectEditField.Position = [90 116 52 22];
            app.FemSelectEditField.Value = '[1,1,1]';

            % Create IsotropicSwitchLabel
            app.IsotropicSwitchLabel = uilabel(app.DUNEuroFEMPanel);
            app.IsotropicSwitchLabel.HorizontalAlignment = 'center';
            app.IsotropicSwitchLabel.FontWeight = 'bold';
            app.IsotropicSwitchLabel.Position = [443 116 60 22];
            app.IsotropicSwitchLabel.Text = 'Isotropic:';

            % Create IsotropicSwitch
            app.IsotropicSwitch = uiswitch(app.DUNEuroFEMPanel, 'slider');
            app.IsotropicSwitch.Items = {'No', 'Yes'};
            app.IsotropicSwitch.Position = [525 119 39 17];
            app.IsotropicSwitch.Value = 'Yes';

            % Create UseTensorSwitchLabel
            app.UseTensorSwitchLabel = uilabel(app.DUNEuroFEMPanel);
            app.UseTensorSwitchLabel.HorizontalAlignment = 'center';
            app.UseTensorSwitchLabel.FontWeight = 'bold';
            app.UseTensorSwitchLabel.Position = [431 47 71 22];
            app.UseTensorSwitchLabel.Text = 'UseTensor:';

            % Create UseTensorSwitch
            app.UseTensorSwitch = uiswitch(app.DUNEuroFEMPanel, 'slider');
            app.UseTensorSwitch.Items = {'No', 'Yes'};
            app.UseTensorSwitch.Position = [524 50 39 17];
            app.UseTensorSwitch.Value = 'No';

            % Create MethodLabel
            app.MethodLabel = uilabel(app.DUNEuroFEMPanel);
            app.MethodLabel.HorizontalAlignment = 'right';
            app.MethodLabel.FontWeight = 'bold';
            app.MethodLabel.Position = [16 82 52 22];
            app.MethodLabel.Text = 'Method:';

            % Create MethodDropDown
            app.MethodDropDown = uidropdown(app.DUNEuroFEMPanel);
            app.MethodDropDown.Items = {'iso2mesh', 'brain2mesh', 'simnibs', 'roast', 'fieldtrip'};
            app.MethodDropDown.Position = [74 82 83 22];
            app.MethodDropDown.Value = 'iso2mesh';

            % Create MeshTypeDropDownLabel
            app.MeshTypeDropDownLabel = uilabel(app.DUNEuroFEMPanel);
            app.MeshTypeDropDownLabel.HorizontalAlignment = 'right';
            app.MeshTypeDropDownLabel.FontWeight = 'bold';
            app.MeshTypeDropDownLabel.Position = [209 82 67 22];
            app.MeshTypeDropDownLabel.Text = 'MeshType:';

            % Create MeshTypeDropDown
            app.MeshTypeDropDown = uidropdown(app.DUNEuroFEMPanel);
            app.MeshTypeDropDown.Items = {'tetrahedral', 'hexahedral'};
            app.MeshTypeDropDown.Position = [282 82 100 22];
            app.MeshTypeDropDown.Value = 'tetrahedral';

            % Create MaxVolSpinnerLabel
            app.MaxVolSpinnerLabel = uilabel(app.DUNEuroFEMPanel);
            app.MaxVolSpinnerLabel.HorizontalAlignment = 'right';
            app.MaxVolSpinnerLabel.FontWeight = 'bold';
            app.MaxVolSpinnerLabel.Position = [17 9 51 22];
            app.MaxVolSpinnerLabel.Text = 'MaxVol:';

            % Create MaxVolSpinner
            app.MaxVolSpinner = uispinner(app.DUNEuroFEMPanel);
            app.MaxVolSpinner.Step = 0.01;
            app.MaxVolSpinner.Limits = [0 1];
            app.MaxVolSpinner.Position = [71 9 60 22];
            app.MaxVolSpinner.Value = 0.1;

            % Create KeepRatioSpinnerLabel
            app.KeepRatioSpinnerLabel = uilabel(app.DUNEuroFEMPanel);
            app.KeepRatioSpinnerLabel.HorizontalAlignment = 'right';
            app.KeepRatioSpinnerLabel.FontWeight = 'bold';
            app.KeepRatioSpinnerLabel.Position = [148 7 69 22];
            app.KeepRatioSpinnerLabel.Text = 'KeepRatio:';

            % Create KeepRatioSpinner
            app.KeepRatioSpinner = uispinner(app.DUNEuroFEMPanel);
            app.KeepRatioSpinner.Limits = [1 100];
            app.KeepRatioSpinner.Position = [220 7 59 22];
            app.KeepRatioSpinner.Value = 100;

            % Create MergeMethodDropDownLabel
            app.MergeMethodDropDownLabel = uilabel(app.DUNEuroFEMPanel);
            app.MergeMethodDropDownLabel.HorizontalAlignment = 'right';
            app.MergeMethodDropDownLabel.FontWeight = 'bold';
            app.MergeMethodDropDownLabel.Position = [406 82 87 22];
            app.MergeMethodDropDownLabel.Text = 'MergeMethod:';

            % Create MergeMethodDropDown
            app.MergeMethodDropDown = uidropdown(app.DUNEuroFEMPanel);
            app.MergeMethodDropDown.Items = {'mergesurf', 'mergemesh'};
            app.MergeMethodDropDown.Position = [499 82 92 22];
            app.MergeMethodDropDown.Value = 'mergesurf';

            % Create VertexDensitySpinnerLabel
            app.VertexDensitySpinnerLabel = uilabel(app.DUNEuroFEMPanel);
            app.VertexDensitySpinnerLabel.HorizontalAlignment = 'right';
            app.VertexDensitySpinnerLabel.FontWeight = 'bold';
            app.VertexDensitySpinnerLabel.Position = [16 47 89 22];
            app.VertexDensitySpinnerLabel.Text = 'VertexDensity:';

            % Create VertexDensitySpinner
            app.VertexDensitySpinner = uispinner(app.DUNEuroFEMPanel);
            app.VertexDensitySpinner.Step = 0.01;
            app.VertexDensitySpinner.Limits = [0 1];
            app.VertexDensitySpinner.Position = [108 47 60 22];
            app.VertexDensitySpinner.Value = 0.5;

            % Create NbVerticesSpinnerLabel
            app.NbVerticesSpinnerLabel = uilabel(app.DUNEuroFEMPanel);
            app.NbVerticesSpinnerLabel.HorizontalAlignment = 'right';
            app.NbVerticesSpinnerLabel.FontWeight = 'bold';
            app.NbVerticesSpinnerLabel.Position = [295 7 72 22];
            app.NbVerticesSpinnerLabel.Text = 'NbVertices:';

            % Create NbVerticesSpinner
            app.NbVerticesSpinner = uispinner(app.DUNEuroFEMPanel);
            app.NbVerticesSpinner.Limits = [8000 20000];
            app.NbVerticesSpinner.ValueDisplayFormat = '%.0f';
            app.NbVerticesSpinner.Position = [370 7 71 22];
            app.NbVerticesSpinner.Value = 15000;

            % Create NodeShiftSpinnerLabel
            app.NodeShiftSpinnerLabel = uilabel(app.DUNEuroFEMPanel);
            app.NodeShiftSpinnerLabel.HorizontalAlignment = 'right';
            app.NodeShiftSpinnerLabel.FontWeight = 'bold';
            app.NodeShiftSpinnerLabel.Position = [461 7 66 22];
            app.NodeShiftSpinnerLabel.Text = 'NodeShift:';

            % Create NodeShiftSpinner
            app.NodeShiftSpinner = uispinner(app.DUNEuroFEMPanel);
            app.NodeShiftSpinner.Step = 0.01;
            app.NodeShiftSpinner.Limits = [0 0.49];
            app.NodeShiftSpinner.Position = [530 7 60 22];
            app.NodeShiftSpinner.Value = 0.3;

            % Create DownsampleSpinnerLabel
            app.DownsampleSpinnerLabel = uilabel(app.DUNEuroFEMPanel);
            app.DownsampleSpinnerLabel.HorizontalAlignment = 'right';
            app.DownsampleSpinnerLabel.FontWeight = 'bold';
            app.DownsampleSpinnerLabel.Position = [224 47 84 22];
            app.DownsampleSpinnerLabel.Text = 'Downsample:';

            % Create DownsampleSpinner
            app.DownsampleSpinner = uispinner(app.DUNEuroFEMPanel);
            app.DownsampleSpinner.Limits = [1 5];
            app.DownsampleSpinner.Position = [312 47 49 22];
            app.DownsampleSpinner.Value = 3;

            % Create CommonparamsHMPanel
            app.CommonparamsHMPanel = uipanel(app.ComputeHeadmodelTab);
            app.CommonparamsHMPanel.Title = 'Common params';
            app.CommonparamsHMPanel.FontWeight = 'bold';
            app.CommonparamsHMPanel.Position = [6 297 643 89];

            % Create RadiiEditFieldLabel
            app.RadiiEditFieldLabel = uilabel(app.CommonparamsHMPanel);
            app.RadiiEditFieldLabel.HorizontalAlignment = 'right';
            app.RadiiEditFieldLabel.FontWeight = 'bold';
            app.RadiiEditFieldLabel.Position = [467 6 39 22];
            app.RadiiEditFieldLabel.Text = 'Radii:';

            % Create RadiiEditField
            app.RadiiEditField = uieditfield(app.CommonparamsHMPanel, 'text');
            app.RadiiEditField.HorizontalAlignment = 'right';
            app.RadiiEditField.Position = [512 6 93 22];
            app.RadiiEditField.Value = '[0.88,0.93,1]';

            % Create ConductivityEditFieldLabel
            app.ConductivityEditFieldLabel = uilabel(app.CommonparamsHMPanel);
            app.ConductivityEditFieldLabel.HorizontalAlignment = 'right';
            app.ConductivityEditFieldLabel.FontWeight = 'bold';
            app.ConductivityEditFieldLabel.Position = [10 7 82 22];
            app.ConductivityEditFieldLabel.Text = 'Conductivity:';

            % Create ConductivityEditField
            app.ConductivityEditField = uieditfield(app.CommonparamsHMPanel, 'text');
            app.ConductivityEditField.HorizontalAlignment = 'right';
            app.ConductivityEditField.Position = [98 7 112 22];
            app.ConductivityEditField.Value = '[0.33,0.0042,0.33]';

            % Create BemNamesEditFieldLabel
            app.BemNamesEditFieldLabel = uilabel(app.CommonparamsHMPanel);
            app.BemNamesEditFieldLabel.HorizontalAlignment = 'right';
            app.BemNamesEditFieldLabel.FontWeight = 'bold';
            app.BemNamesEditFieldLabel.Position = [17 38 75 22];
            app.BemNamesEditFieldLabel.Text = 'BemNames:';

            % Create BemNamesEditField
            app.BemNamesEditField = uieditfield(app.CommonparamsHMPanel, 'text');
            app.BemNamesEditField.HorizontalAlignment = 'right';
            app.BemNamesEditField.Position = [98 38 132 22];
            app.BemNamesEditField.Value = '["Scalp","Skull","Brain"]';

            % Create BemCondEditFieldLabel
            app.BemCondEditFieldLabel = uilabel(app.CommonparamsHMPanel);
            app.BemCondEditFieldLabel.HorizontalAlignment = 'right';
            app.BemCondEditFieldLabel.FontWeight = 'bold';
            app.BemCondEditFieldLabel.Position = [268 6 66 22];
            app.BemCondEditFieldLabel.Text = 'BemCond:';

            % Create BemCondEditField
            app.BemCondEditField = uieditfield(app.CommonparamsHMPanel, 'text');
            app.BemCondEditField.HorizontalAlignment = 'right';
            app.BemCondEditField.Position = [340 6 87 22];
            app.BemCondEditField.Value = '[1,0.0125,1]';

            % Create BemSelectEditFieldLabel
            app.BemSelectEditFieldLabel = uilabel(app.CommonparamsHMPanel);
            app.BemSelectEditFieldLabel.HorizontalAlignment = 'right';
            app.BemSelectEditFieldLabel.FontWeight = 'bold';
            app.BemSelectEditFieldLabel.Position = [262 37 71 22];
            app.BemSelectEditFieldLabel.Text = 'BemSelect:';

            % Create BemSelectEditField
            app.BemSelectEditField = uieditfield(app.CommonparamsHMPanel, 'text');
            app.BemSelectEditField.HorizontalAlignment = 'right';
            app.BemSelectEditField.Position = [339 37 105 22];
            app.BemSelectEditField.Value = '[true,true,true]';

            % Create UsedefaultparametersSwitchLabel
            app.UsedefaultparametersSwitchLabel = uilabel(app.ComputeHeadmodelTab);
            app.UsedefaultparametersSwitchLabel.HorizontalAlignment = 'center';
            app.UsedefaultparametersSwitchLabel.FontWeight = 'bold';
            app.UsedefaultparametersSwitchLabel.Position = [7 394 142 22];
            app.UsedefaultparametersSwitchLabel.Text = 'Use default parameters:';

            % Create UsedefaultparametersSwitch
            app.UsedefaultparametersSwitch = uiswitch(app.ComputeHeadmodelTab, 'slider');
            app.UsedefaultparametersSwitch.Items = {'No', 'Yes'};
            app.UsedefaultparametersSwitch.FontWeight = 'bold';
            app.UsedefaultparametersSwitch.Position = [185 395 45 20];
            app.UsedefaultparametersSwitch.Value = 'Yes';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Params_configuration

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end