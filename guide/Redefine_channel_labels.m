classdef Redefine_channel_labels < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        CancelButton         matlab.ui.control.Button
        SetlabelsButton      matlab.ui.control.Button
        Layout_UITable       matlab.ui.control.Table
        DeletechannelButton  matlab.ui.control.Button
    end

    
    methods (Access = public)
        
        function load_channel_labels(app,BSTpath,labels,group_name,layout_name)
            layout = load(fullfile(BSTpath,'defaults','eeg',group_name,['channel_',layout_name,'.mat']));
               
        end
        
    end
    
    methods (Access = private)
             
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
             app.UIFigure.Name = 'Redefine channel labels';
        end

        % Button pushed function: CancelButton
        function CancelButtonPushed(app, event)
             delete(app);
        end

        % Button pushed function: DeletechannelButton
        function DeletechannelButtonPushed(app, event)
            D=get(app.Layout_UITable,'Data');
            Index=get(app.Layout_UITable,'UserData');
            D(Index(1))=[];
            set(app.Layout_UITable,'Data',D);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create CancelButton
            app.CancelButton = uibutton(app.UIFigure, 'push');
            app.CancelButton.ButtonPushedFcn = createCallbackFcn(app, @CancelButtonPushed, true);
            app.CancelButton.Position = [449 20 80 22];
            app.CancelButton.Text = 'Cancel';

            % Create SetlabelsButton
            app.SetlabelsButton = uibutton(app.UIFigure, 'push');
            app.SetlabelsButton.Position = [538 20 79 22];
            app.SetlabelsButton.Text = 'Set labels';

            % Create Layout_UITable
            app.Layout_UITable = uitable(app.UIFigure);
            app.Layout_UITable.ColumnName = {'No.'; 'Name'; 'Type'; 'Location'; 'Comment'};
            app.Layout_UITable.ColumnWidth = {35, 'auto', 'auto', 'auto', 'auto'};
            app.Layout_UITable.RowName = {};
            app.Layout_UITable.Position = [25 51 592 371];

            % Create DeletechannelButton
            app.DeletechannelButton = uibutton(app.UIFigure, 'push');
            app.DeletechannelButton.ButtonPushedFcn = createCallbackFcn(app, @DeletechannelButtonPushed, true);
            app.DeletechannelButton.Position = [528 431 89 22];
            app.DeletechannelButton.Text = 'Delete channel';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Redefine_channel_labels

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