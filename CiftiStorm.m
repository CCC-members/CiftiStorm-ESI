classdef CiftiStorm < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        FileMenu             matlab.ui.container.Menu
        ConfigureparamsMenu  matlab.ui.container.Menu
        ExitMenu             matlab.ui.container.Menu
        ToolsMenu            matlab.ui.container.Menu
        ViewMenu             matlab.ui.container.Menu
        HelpMenu             matlab.ui.container.Menu
        UpdateMenu           matlab.ui.container.Menu
        UsermanualMenu       matlab.ui.container.Menu
        AboutMenu            matlab.ui.container.Menu
        TabGroup             matlab.ui.container.TabGroup
        InputTab             matlab.ui.container.Tab
        Tab2                 matlab.ui.container.Tab
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Menu selected function: ExitMenu
        function ExitMenuSelected(app, event)
            delete(app);
        end

        % Menu selected function: ConfigureparamsMenu
        function ConfigureparamsMenuSelected(app, event)
            obj_configure = Params_configuration();
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 803 776];
            app.UIFigure.Name = 'MATLAB App';

            % Create FileMenu
            app.FileMenu = uimenu(app.UIFigure);
            app.FileMenu.Text = 'File';

            % Create ConfigureparamsMenu
            app.ConfigureparamsMenu = uimenu(app.FileMenu);
            app.ConfigureparamsMenu.MenuSelectedFcn = createCallbackFcn(app, @ConfigureparamsMenuSelected, true);
            app.ConfigureparamsMenu.Text = 'Configure params';

            % Create ExitMenu
            app.ExitMenu = uimenu(app.FileMenu);
            app.ExitMenu.MenuSelectedFcn = createCallbackFcn(app, @ExitMenuSelected, true);
            app.ExitMenu.Text = 'Exit';

            % Create ToolsMenu
            app.ToolsMenu = uimenu(app.UIFigure);
            app.ToolsMenu.Text = 'Tools';

            % Create ViewMenu
            app.ViewMenu = uimenu(app.UIFigure);
            app.ViewMenu.Text = 'View';

            % Create HelpMenu
            app.HelpMenu = uimenu(app.UIFigure);
            app.HelpMenu.Text = 'Help';

            % Create UpdateMenu
            app.UpdateMenu = uimenu(app.HelpMenu);
            app.UpdateMenu.Text = 'Update';

            % Create UsermanualMenu
            app.UsermanualMenu = uimenu(app.HelpMenu);
            app.UsermanualMenu.Text = 'User manual';

            % Create AboutMenu
            app.AboutMenu = uimenu(app.HelpMenu);
            app.AboutMenu.Text = 'About';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [24 23 260 719];

            % Create InputTab
            app.InputTab = uitab(app.TabGroup);
            app.InputTab.Title = 'Input';

            % Create Tab2
            app.Tab2 = uitab(app.TabGroup);
            app.Tab2.Title = 'Tab2';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = CiftiStorm

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

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