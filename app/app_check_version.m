%  BC-VARETA check version
%
%
% Authors:
%   -   Ariosky Areces Gonzalez
%   -   Deirel Paz Linares
%   -   Eduardo Gonzalez Moreaira
%   -   Pedro Valdes Sosa

% - Date: May 31, 2019


try
    
    
    if(app_connection_status())
        
        % loading local data
        local = jsondecode(fileread(strcat('app_properties.json')));
        
        % finding online data
        url = local.generals.url_check;
        matlab.net.http.HTTPOptions.VerifyServerName = false;
        options = weboptions('ContentType','json','Timeout',Inf,'RequestMethod','auto');
        online = webread(url,options);
        
        if(local.generals.version_number < online.generals.version_number)
            answer = questdlg({'There a new version available of BC-VARETA.',' Do you want to update the laster version?'}, ...
                'Update BC-VARETA', ...
                'Yes','No','Close');
            % Handle response
            switch answer
                case 'Yes'
                    f = dialog('Position',[300 300 250 80]);
                    
                    iconsClassName = 'com.mathworks.widgets.BusyAffordance$AffordanceSize';
                    iconsSizeEnums = javaMethod('values',iconsClassName);
                    SIZE_32x32 = iconsSizeEnums(2);  % (1) = 16x16,  (2) = 32x32
                    jObj = com.mathworks.widgets.BusyAffordance(SIZE_32x32, 'Starting update.');  % icon, label
                    
                    jObj.setPaintsWhenStopped(true);  % default = false
                    jObj.useWhiteDots(false);         % default = false (true is good for dark backgrounds)
                    javacomponent(jObj.getComponent, [50,10,150,80], f);
                    jObj.start;
                    pause(1);
                    
                    
                    %% Download lasted version
                    filename = strcat('BCV_lasted_version.zip');
                    disp(strcat("Downloading lasted version......."));
                    jObj.setBusyText(strcat("Downloading lasted version "));
                    
                    url = local.generals.base_url;
                    matlab.net.http.HTTPOptions.VerifyServerName = false;
                    options = weboptions('Timeout',Inf,'RequestMethod','auto');
                    downladed_file = websave(filename,url,options);
                    
                    %% Unzip lasted version
                    pause(1);
                    jObj.setBusyText('Unpacking version...');
                    disp(strcat("Unpacking version..."));
                    
                    exampleFiles = unzip(filename,pwd);
                    pause(1);
                    delete(filename);
                    
                    movefile( strcat('BC-VARETA_Toolbox-master',filesep,'*'), pwd);
                    rmdir BC-VARETA_Toolbox-master ;
                    
                    jObj.stop;
                    jObj.setBusyText('All done!');
                    disp(strcat("All done!"));
                    pause(2);
                    delete(f);
                    
                case 'No'
                    return;
                case ''
                    return;
            end
        end
    end
    
catch
    return;
end


