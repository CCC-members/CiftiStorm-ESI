function result = app_check_matlab_version()
%  BC-VARETA check matlab version
%
%
% Authors:
%   -   Ariosky Areces Gonzalez
%   -   Deirel Paz Linares
%   -   Eduardo Gonzalez Moreaira
%   -   Pedro Valdes Sosa

% - Date: Jun 10, 2019


if verLessThan('matlab','9.5')
    disp(strcat(">> You have installed the Matlab version: ",version ));
    disp(strcat('>> BC-VARETA was developed in Matlab: 9.5.0.944444 (R2018b)'));
    disp(strcat('>> Some functionalities will present problems, if you continue run the process'));
    disp(strcat('>> You need install the MATLAB Runtime, R2018b (9.5) or superior'));
    disp(strcat('>> https://www.mathworks.com/products/compiler/matlab-runtime.html'));
    
   app_properties = jsondecode(fileread(strcat('app_properties.json')));    
    if(~app_properties.run_bash_mode.value)
        
        answer = questdlg({strcat('>> You have installed the Matlab version: ',version,'.'),...
            '>> BC-VARETA was developed in Matlab: 9.5.0.944444 (R2018b).',...
            '>> Some functionalities will present problems, if you continue run the process.',...
            '>> You need install the MATLAB Runtime, R2018b (9.5) or superior.',...
            'Do you want to download MATLAB Runtime automaticaly?',...
            '- Yes: Download the MATLAB Runtime and stop the BC-VARETA process.',...
            '- No: Continue the BC-VARETA process',...
            '- Cancel: Stop the BC-VARETA process'}, ...
            'Matlab version warning', ...
            'Yes','No','Cancel','Close');
        % Handle response
        switch answer
            case 'Yes'
                if(app_connection_status())                    
                    if ismac
                        url = app_properties.matlab_runtime.mac;
                    elseif isunix
                        url = app_properties.matlab_runtime.linux;
                    elseif ispc
                        url = app_properties.matlab_runtime.win;
                    end
                    
                    download_path  = uigetdir('tittle','Select the Download Folder');
                    if(download_path==0)
                        result = false;
                        return;
                    end
                    
                    f = dialog('Position',[300 300 250 80]);
                    define_ico(f);
                    iconsClassName = 'com.mathworks.widgets.BusyAffordance$AffordanceSize';
                    iconsSizeEnums = javaMethod('values',iconsClassName);
                    SIZE_32x32 = iconsSizeEnums(2);  % (1) = 16x16,  (2) = 32x32
                    jObj = com.mathworks.widgets.BusyAffordance(SIZE_32x32, 'Starting download.');  % icon, label
                    
                    jObj.setPaintsWhenStopped(true);  % default = false
                    jObj.useWhiteDots(false);         % default = false (true is good for dark backgrounds)
                    javacomponent(jObj.getComponent, [40,10,150,80], f);
                    jObj.start;
                    pause(1);
                    
                    %% Download Matlab runtime
                    [FILEPATH,NAME,EXT] = fileparts(url);
                    filename = strcat(NAME,'.',EXT);
                    disp(strcat("Downloading Matlab runtime......."));
                    jObj.setBusyText(strcat("Downloading Matlab runtime "));
                    
                    matlab.net.http.HTTPOptions.VerifyServerName = false;
                    options = weboptions('Timeout',Inf,'RequestMethod','auto');
                    downladed_file = websave(fullfile(download_path,filename),url,options);
                    
                    jObj.stop;
                    jObj.setBusyText('All done!');
                    disp(strcat("All done!"));
                    delete(f);
                end
            case 'Cancel'
                result = false;
                return;
            case 'Close'
                result = false;
                return;
            case ''
                result = false;
                return;
        end
    else
        result = false;
        return;
    end   
end
result = true;
end