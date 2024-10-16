function [updated, errors] = update_version(app)
updated = true;
errors = [];
%  App check version
%
%
% Authors:
%   -   Ariosky Areces Gonzalez
%   -   Deirel Paz Linares
%   -   Pedro Valdes Sosa

% - Date: November 15, 2019
try    
    %% Download latest version
    if(getGlobalGuimode())
        d = uiprogressdlg(app.CiftiStormUIFigure,'Title','Downloading CiftiStorm latest version');
    end
    filename = strcat('CiftiStorm_latest.zip');
    disp(strcat("-->> Downloading laster version......."));
    % loading local data
    local = jsondecode(fileread(strcat('app/properties.json')));
    url = local.generals.base_url;
    matlab.net.http.HTTPOptions.VerifyServerName = false;
    options = weboptions('Timeout',Inf,'RequestMethod','auto');
    downladed_file = websave(filename,url,options);
    pause(1);
    if(getGlobalGuimode())
        delete(d);
    end

    %% Unzip lasted version
    if(getGlobalGuimode())
        d = uiprogressdlg(app.CiftiStormUIFigure,'Title','Unziping files');
    end
    disp(strcat("-->> Unziping files......."));  
    exampleFiles = unzip(filename,pwd);
    pause(1);
    delete(filename);
    if(getGlobalGuimode())
        delete(d);
    end

    %% Moving files
    if(getGlobalGuimode())
        d = uiprogressdlg(app.CiftiStormUIFigure,'Title','Deploging the new vew version');
    end
    disp(strcat("-->> Deploging the new vew version.......")); 
    movefile( strcat('CiftiStorm-ESI-master',filesep,'*'), pwd, 'f');
    rmdir CiftiStorm-ESI-master ;   

    disp('-->> The project is already update with the laster version.');
    disp('-->> The process was stoped to refresh all file');
    disp('-->> Please configure the app properties file, before restart the process.');
    
    if(getGlobalGuimode())
        delete(d);
    end

catch
    updated = false;
    return;
end
end


