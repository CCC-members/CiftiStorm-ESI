function app_properties = init_processing(properties_file)
try
    app_properties = jsondecode(fileread(fullfile('app','properties.json')));
catch EM
    fprintf(2,"\n ->> Error: The app/properties file do not have a correct format \n");
    disp("-->> Message error");
    disp(EM.message);
    disp('-->> Process stopped!!!');
    return;
end

%% Printing data information
disp(strcat("-->> Name:",app_properties.generals.name));
disp(strcat("-->> Version:",app_properties.generals.version));
disp(strcat("-->> Version date:",app_properties.generals.version_date));
disp("==========================================================================");

%% ------------ Checking MatLab compatibility ----------------
if(app_properties.generals.check_matlab_version)
    disp('-->> Checking installed matlab version');
    if(~check_matlab_version())
        return;
    end
end

%% ------------  Checking updates --------------------------
if(app_properties.generals.check_app_update)
    disp('-->> Checking last project version');
    [updated, errors] = update_version();
    iconnection = isnetav();
    if(iconnection)
        % loading local data
        local = jsondecode(fileread(strcat('app/properties.json')));
        % finding online data        
        url = local.generals.url_check;
        matlab.net.http.HTTPOptions.VerifyServerName = false;
        options = weboptions('ContentType','json','Timeout',Inf,'RequestMethod','auto');
        online = webread(url,options);
        disp('-->> Comparing local and master version');
        
        if(local.generals.version_number < online.generals.version_number)
            answer = questdlg({'There a new version available of CiftiStorm pipeline.',' Do you want to update the latest version?'}, ...
                'Update CiftiStorm', ...
                'Yes','No','Close');
            % Handle response
            switch answer
                case 'Yes'
                    [updated, errors] = update_version();
                    if(updated)
                        msg = msgbox({'CiftiStorm was updated with the latest version.',...
                            'The application will be closed.'},'Info',"help","modal");
                        waitfor(msg);
                    end
            end
        else
            disp('-->> Nothing to update');
        end
    else
        disp('-->> Internet connection problems.');
        if(getGlobalGuimode())            
            msg = msgbox({'There are some problems with your internet connection.',...
                'Please check your internet conection.'},'Info',"help","modal");
            waitfor(msg);
            figure(app.CiftiStormUIFigure);
        end
    end    
end
%%
%% ----------- Create CiftiStrom Database ---------------------
%%
cfs_create_db()

end

