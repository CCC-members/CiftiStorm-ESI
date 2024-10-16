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


%%
%% ----------- Create CiftiStrom Database ---------------------
%%
cfs_create_db()

end

