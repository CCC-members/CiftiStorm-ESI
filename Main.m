%% Brainstorm Protocol
%%%%%%%%%%%%%%%%%%%%


% Scripted leadfield pipeline for Freesurfer anatomy files
% Brainstorm (24-Feb-2019)
% Andy Hu, Feb. 24, 2019


% Authors
% - Ariosky Areces Gonzalez
% - Deirel Paz Linares
% - Usama Riaz
%
%    September 25, 2019


%%
%------------ Preparing properties --------------------
% brainstorm('stop');
addpath(fullfile('app')); 
addpath(fullfile('function'));
% addpath(strcat('bst_lf_ppl',filesep,'properties'));
% addpath(strcat('bst_lf_ppl',filesep,'guide'));
%bst_properties = jsondecode(fileread(strcat('properties',filesep,'bst_properties.json')));
app_properties = jsondecode(fileread(strcat('app_properties.json')));

disp('------------Preparing BrianStorm properties ---------------');
bst_path =  bst_properties.bst_path;
console = false;
try
    run_mode = bst_properties.run_mode;
catch
    run_mode = app_properties.run_mode;
end
if (run_mode == '1')
    console = true;
    if(isempty( bst_path))
        bst_url =  bst_properties.bst_url;
        filename = 'brainstorm.zip';
        [filepath,filename,ext] = download_file(url,pwd,filename);
        [folderpath,foldername] = unpackage_file(filename,pwd);
    end
    ProtocolName = bst_properties.protocol_name;
else
    if(isempty( bst_path))
        answer = questdlg('Did you download the brainstorm?', ...
            'Select brainstorm source', ...
            'Yes I did','Download','Cancel','Close');
        switch answer
            case 'Yes I did'
                bst_path = uigetdir('tittle','Select the Source Folder');
                if(bst_path==0)
                    disp('User selected Cancel');
                    return;
                end
                bst_properties.bs_path=bst_path;
                saveJSON(bst_properties,strcat('bst_properties.json'));
                
                
            case 'Download'
                bst_url =  bst_properties.bs_url;
                filename = 'brainstorm.zip';
                
                [filepath,filename,ext] = download_file(url,pwd,filename);
                
                [folderpath,foldername] = unpackage_file(filename,pwd);
                
                bst_properties.bs_path = fullfile(folderpath,foldername);
                saveJSON(bst_properties,strcat('bst_properties.json'));
                
            case 'Cancel'
                result = false;
                return;
        end
    end
    guiHandle = protocol_guide;
    disp('------Waitintg for Protocol------');
    uiwait(guiHandle.UIFigure);
    delete(guiHandle);
    ProtocolName = bst_properties.protocol_name;
end

addpath(genpath(bst_path));
bst_properties.bst_path = bst_path;
saveJSON(bst_properties,strcat('bst_properties.json'));

%---------------- Starting BrainStorm-----------------------
if ~brainstorm('status')
    if(console)
        brainstorm nogui local
        data_folder = bst_properties.raw_data_path;
    else
        brainstorm nogui
        data_folder = uigetdir('tittle','Select the Data Folder');
        if(data_folder==0)
            return;
        end
        bst_properties.raw_data_path = data_folder;
        saveJSON(bst_properties,strcat('bst_properties.json'));
    end
end

BrainstormDbDir = bst_get('BrainstormDbDir');
bst_properties.bs_db_path = bs_db_path;
saveJSON(bst_properties,strcat('bst_properties.json'));

% Delete existing protocol
gui_brainstorm('DeleteProtocol', ProtocolName);

% Create new protocol
gui_brainstorm('CreateProtocol', ProtocolName, 0, 0,BrainstormDbDir);


%-------------- Uploading Data subject --------------------------
disp(strcat('------Data Source:  ', data_folder ));
subjects = dir(data_folder);
for j=1:size(subjects,1)
    subject_name = subjects(j).name;
    if(isfolder(fullfile(data_folder,subject_name)) & subject_name ~= '.' & string(subject_name) ~="..")
        disp(strcat('------------> Processing subject: ', subject_name , ' <--------------'));
        % Input files
        sucject_folder = fullfile(data_folder,subject_name);
        if(exist(strcat(sucject_folder,filesep,subject_name,'_EEG_anatomy_t13d_anatVOL_20060115002658_2.nii_out',filesep,'mri',filesep,'T1.mgz'),'file'))
            
            sFiles = [];
            
            RawFiles = {strcat(sucject_folder,filesep,subject_name,'_EEG_anatomy_t13d_anatVOL_20060115002658_2.nii_out',filesep,'mri',filesep,'T1.mgz'), ...
                strcat(sucject_folder,filesep,subject_name,'_EEG_anatomy_t13d_anatVOL_20060115002658_2.nii_out'), ...
                strcat(sucject_folder,filesep,subject_name,'_EEG_data.mat'),...
                'E:\ProyectoPipeline\PipelineAndy\exampledata\channel_CNEURO_ASA_10-05_58.mat'};
            
            
            % Start a new report
            bst_report('Start', sFiles);
            
            % Process: Import MRI
            try
                sFiles = bst_process('CallProcess', 'process_import_mri', sFiles, [], 'subjectname', subject_name, 'mrifile', {RawFiles{1}, 'MGH'});
            catch exception
                disp(strcat('Error: '));
                disp(exception);
                disp('Jumping to the next subject..........');
                disp('---------------------------------------');
                disp('    -------------------------     ');
                continue;
            end
            
            % Process: Compute MNI transformation
            try
                sFiles = bst_process('CallProcess', 'process_mni_affine', sFiles, [], 'subjectname', subject_name);
            catch exception
                disp(strcat('Error: '));
                disp(exception);
                disp('Jumping to the next subject..........');
                disp('---------------------------------------');
                disp('    -------------------------     ');
                continue;
            end
            
            % Check Fiducials
            try
                Fiducial =  load(strcat(BrainstormDbDir, filesep,ProtocolName,filesep,'anat',filesep,subject_name,filesep,'subjectimage_T1.mat'));
            catch exception
                disp(strcat('Error: '));
                disp(exception);
                disp('Jumping to the next subject..........');
                disp('---------------------------------------');
                disp('    -------------------------     ');
                continue;
            end
            
            % Process: Import anatomy folder
            try
                process_import_anatomy = bst_properties.process_import_anatomy;
                
                sFiles = bst_process('CallProcess', 'process_import_anatomy', sFiles, [],...
                    'subjectname', subject_name,...
                    'mrifile',     {RawFiles{2}, char(process_import_anatomy.mrifile2)},...
                    'nvertices',   str2double(process_import_anatomy.nvertices), ...
                    'nas', Fiducial.SCS.NAS,...
                    'lpa', Fiducial.SCS.LPA,...
                    'rpa', Fiducial.SCS.RPA,...
                    'ac', Fiducial.NCS.AC,...
                    'pc', Fiducial.NCS.PC,...
                    'ih', Fiducial.NCS.IH,...
                    'aseg', str2double(process_import_anatomy.aseg));
            catch exception
                disp(strcat('Error: '));
                disp(exception);
                disp('Jumping to the next subject..........');
                disp('---------------------------------------');
                disp('    -------------------------     ');
                continue;
            end
            
            % Process: Generate BEM surfaces
            try
                process_generate_bem = bst_properties.process_generate_bem;
                
                sFiles = bst_process('CallProcess', 'process_generate_bem', sFiles, [], ...
                    'subjectname', subject_name, ...
                    'nscalp',      str2double(process_generate_bem.nscalp), ...
                    'nouter',      str2double(process_generate_bem.nouter), ...
                    'ninner',      str2double(process_generate_bem.ninner), ...
                    'thickness',   str2double(process_generate_bem.thickness));
            catch exception
                disp(strcat('Error: '));
                disp(exception);
                disp('Jumping to the next subject..........');
                disp('---------------------------------------');
                disp('    -------------------------     ');
                continue;
            end
            
            % Process: Create link to raw file
            try
                process_import_data_raw = bst_properties.process_import_data_raw;
                
                sFiles = bst_process('CallProcess', 'process_import_data_raw', sFiles, [], ...
                    'subjectname',    subject_name, ...
                    'datafile',       {RawFiles{3}, char(process_import_data_raw.datafile)}, ...
                    'channelreplace', str2double(process_import_data_raw.channelreplace), ...
                    'channelalign',   str2double(process_import_data_raw.channelalign), ...
                    'evtmode',        char(process_import_data_raw.evtmode));
            catch exception
                disp(strcat('Error: '));
                disp(exception);
                disp('Jumping to the next subject..........');
                disp('---------------------------------------');
                disp('    -------------------------     ');
                continue;
            end
            
            % Process: Set channel file
            %             try
            process_import_channel = bst_properties.process_import_channel;
            
            sFiles = bst_process('CallProcess', 'process_import_channel', sFiles, [], ...
                'channelfile',  {RawFiles{4},'BST'}, ...
                'usedefault',   str2double(process_import_channel.usedefault), ...  % ICBM152: 10-20 19
                'channelalign', str2double(process_import_channel.channelalign), ...
                'fixunits',     str2double(process_import_channel.fixunits), ...
                'vox2ras',      str2double(process_import_channel.vox2ras));
            %             catch exception
            %                 disp(strcat('Error: '));
            %                 disp(exception);
            %                 disp('Jumping to the next subject..........');
            %                 disp('---------------------------------------');
            %                 disp('    -------------------------     ');
            %                 continue;
            %             end
            
            % Process: Refine registration
            try
                sFiles = bst_process('CallProcess', 'process_headpoints_refine', sFiles, []);
            catch exception
                disp(strcat('Error: '));
                disp(exception);
                disp('Jumping to the next subject..........');
                disp('---------------------------------------');
                disp('    -------------------------     ');
                continue;
            end
            
            % Process: Project electrodes on scalp
            try
                sFiles = bst_process('CallProcess', 'process_channel_project', sFiles, []);
            catch exception
                disp(strcat('Error: '));
                disp(exception);
                disp('Jumping to the next subject..........');
                disp('---------------------------------------');
                disp('    -------------------------     ');
                continue;
            end
            
            % Process: Compute head model
            %             try
            process_headmodel = bst_properties.process_headmodel;
            
            sFiles = bst_process('CallProcess', 'process_headmodel', sFiles, [], ...
                'Comment',     char(process_headmodel.Comment), ...
                'sourcespace', str2double(process_headmodel.sourcespace), ...  % Cortex surface
                'volumegrid',  struct(...
                'Method',        char(process_headmodel.Method), ...
                'nLayers',       str2double(process_headmodel.nLayers), ...
                'Reduction',     str2double(process_headmodel.Reduction), ...
                'nVerticesInit', str2double(process_headmodel.nVerticesInit), ...
                'Resolution',    str2double(process_headmodel.Resolution), ...
                'FileName',      process_headmodel.FileName), ...
                'eeg',           str2double(process_headmodel.eeg), ...  % OpenMEEG BEM
                'openmeeg',    struct(...
                'BemSelect',    process_headmodel.BemSelect, ...
                'BemCond',      process_headmodel.BemCond, ...
                'BemNames',     {process_headmodel.BemNames}, ...
                'BemFiles',     {process_headmodel.BemFiles}, ...
                'isAdjoint',    str2double(process_headmodel.isAdjoint), ...
                'isAdaptative', str2double(process_headmodel.isAdaptative), ...
                'isSplit',      str2double(process_headmodel.isSplit), ...
                'SplitLength', str2double(process_headmodel.SplitLength)));
            %             catch exception
            %                 disp(strcat('Error: '));
            %                 disp(exception);
            %                 disp('Jumping to the next subject..........');
            %                 disp('---------------------------------------');
            %                 disp('    -------------------------     ');
            %                 continue;
            %             end
            
            % Save lead field
            try
                load(strcat(BrainstormDbDir,filesep,ProtocolName,filesep,'data',filesep,subject_name,filesep,'@raw',subject_name,'_EEG_data',filesep,'headmodel_surf_openmeeg.mat'));
                Gain3d=Gain; Gain = bst_gain_orient(Gain3d, GridOrient);
                save(strcat('bst_result',filesep,subject_name,filesep,'Gain.mat'), 'Gain', 'Gain3d');
            catch exception
                disp(strcat('Error: '));
                disp(exception);
                disp('Jumping to the next subject..........');
                disp('---------------------------------------');
                disp('    -------------------------     ');
                continue;
            end
            
            % Save patch
            try
                load(strcat(BrainstormDbDir,filesep,ProtocolName,filesep,'anat',filesep,subject_name,filesep,'tess_cortex_pial_low.mat'));
                save(strcat('bst_result',filesep,subject_name,filesep,'patch.mat'),'Vertices','Faces');
            catch exception
                disp(strcat('Error: '));
                disp(exception);
                disp('Jumping to the next subject..........');
                disp('---------------------------------------');
                disp('    -------------------------     ');
                continue;
            end
            
            % Save and display report
            try
                ReportFile = bst_report('Save', sFiles);
                bst_report('Open', ReportFile);
                % bst_report('Export', ReportFile, ExportDir);
            catch exception
                disp(strcat('Error: '));
                disp(exception);
                disp('Jumping to the next subject..........');
                disp('---------------------------------------');
                disp('    -------------------------     ');
                continue;
            end
        else
            fprintf(2,'-----------Process warning------------');
            disp('--------------------------------------------------')
            disp(strcat('The subject: ',subject_name));
            disp(strcat('Sourse folder: ',data_folder));
            fprintf(2,strcat('----  Have not a correct structure or miss the T1 file -----'));
            disp('--------------------------------------------------')
        end
    end
end

brainstorm('stop');




