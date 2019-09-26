classdef protocol_guide < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        ProtocolUIFigure            matlab.ui.Figure
        CancelButton                matlab.ui.control.Button
        OkButton                    matlab.ui.control.Button
        ProtocolnameEditFieldLabel  matlab.ui.control.Label
        ProtocolnameEditField       matlab.ui.control.EditField
    end

    
    properties (Access = private)
        Property % Description
    end
    
    properties (Access = public)
        canceled
        frequency_resolution % Resolution frequency
        sampling_frequency % Samplin frequency
        max_frequency % Max frequency
        
    end
    

    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
        end

        % Button pushed function: CancelButton
        function CancelButtonPushed(app, event)
            app.canceled = false;
            properties_file = strcat('properties',filesep,'bs_properties.xml');
            root_tab =  'properties'; 
            parameters = ["protocol_name"];
            values = [app.ProtocolnameEditField.Value ];            
            change_xml_parameter(properties_file,root_tab,parameters,values);            
            uiresume(app.ProtocolUIFigure);
            
        end

        % Button pushed function: OkButton
        function OkButtonPushed(app, event)
            app.canceled = false;
            properties_file = strcat('properties',filesep,'properties.xml');
            root_tab =  'properties';
            
            app.frequency_resolution = app.ProtocolnameSpinner.Value;
            app.sampling_frequency = app.SamplingfrequencySpinner.Value;
            app.max_frequency = app.MaximumfrequencySpinner.Value;
            
            parameters = ["freq_resol","samp_freq","max_freq"];
            values = [app.frequency_resolution,app.sampling_frequency,app.max_frequency];
            
            change_xml_parameter(properties_file,root_tab,parameters,values);
            
            uiresume(app.ProtocolUIFigure);
            
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create ProtocolUIFigure
            app.ProtocolUIFigure = uifigure;
            app.ProtocolUIFigure.Position = [100 100 316 137];
            app.ProtocolUIFigure.Name = 'Protocol';

            % Create CancelButton
            app.CancelButton = uibutton(app.ProtocolUIFigure, 'push');
            app.CancelButton.ButtonPushedFcn = createCallbackFcn(app, @CancelButtonPushed, true);
            app.CancelButton.Position = [211 24 79 22];
            app.CancelButton.Text = 'Cancel';

            % Create OkButton
            app.OkButton = uibutton(app.ProtocolUIFigure, 'push');
            app.OkButton.ButtonPushedFcn = createCallbackFcn(app, @OkButtonPushed, true);
            app.OkButton.Position = [109 24 85 22];
            app.OkButton.Text = 'Ok';

            % Create ProtocolnameEditFieldLabel
            app.ProtocolnameEditFieldLabel = uilabel(app.ProtocolUIFigure);
            app.ProtocolnameEditFieldLabel.HorizontalAlignment = 'right';
            app.ProtocolnameEditFieldLabel.Position = [24 84 86 22];
            app.ProtocolnameEditFieldLabel.Text = 'Protocol name:';

            % Create ProtocolnameEditField
            app.ProtocolnameEditField = uieditfield(app.ProtocolUIFigure, 'text');
            app.ProtocolnameEditField.Position = [125 84 165 22];
        end
    end

    methods (Access = public)

        % Construct app
        function app = protocol_guide

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.ProtocolUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.ProtocolUIFigure)
        end
    end
end