function [] = export_subject_BCV_structure(selected_data_set,subID)

%%
%% Get Protocol information
%%
% try
    ProtocolInfo = bst_get('ProtocolInfo');
    % Get subject directory
    [sSubject] = bst_get('Subject', subID);
    if(isempty(sSubject) || isempty(sSubject.iAnatomy) || isempty(sSubject.iCortex) || isempty(sSubject.iInnerSkull) || isempty(sSubject.iOuterSkull) || isempty(sSubject.iScalp))
        return;
    end
    subjectSubDir = bst_fileparts(sSubject.FileName);    
    
    prefix = '@intra';
    if(isfield(selected_data_set, 'use_raw_data'))
        if(isequal(selected_data_set.use_raw_data,true))
            prefix = ['@raw',subjectSubDir];
        end
    end
    
    bcv_path = selected_data_set.bcv_input_path;
    if(~isfolder(bcv_path))
        mkdir(bcv_path);
    end
    
    %% Creating subject folder structure
    disp('-->> Creating subject folder structure.');
    [output_subject] = create_data_structure(bcv_path,sSubject.Name);
    
    %% Uploding Subject file into BrainStorm Protocol
    disp('BST-P ->> Uploding Subject file into BrainStorm Protocol.')
    
    % process_waitbar = waitbar(0,strcat('Importing data subject: ' , subject_name ));
    %%
    %% Genering leadfield file
    %%
    
    disp ("-->> Genering leadfield file");
    BSTHeadMOdelBaseFile = fullfile(ProtocolInfo.STUDIES,subjectSubDir,prefix);
    BSTHeadModelFiles = dir(fullfile(BSTHeadMOdelBaseFile,'headmodel_surf_openmeeg*.mat'));
    [~,idx] = sort([BSTHeadModelFiles.datenum]);
    BSTHeadModelFile = BSTHeadModelFiles(idx(end));
    BSTHeadModel = load(fullfile(BSTHeadModelFile.folder,BSTHeadModelFile.name));
    Ke = BSTHeadModel.Gain; 
    GridOrient = BSTHeadModel.GridOrient;
    GridAtlas = BSTHeadModel.GridAtlas;
    %%
    %% Genering surf file
    %%
    disp ("-->> Genering surf file");
    CortexFile     = sSubject.Surface(sSubject.iCortex).FileName;
    BSTCortexFile = bst_fullfile(ProtocolInfo.SUBJECTS, CortexFile);
    Sc = load(BSTCortexFile);    
    
    %%
    %% Genering scalp file
    %%
    disp ("-->> Genering scalp file");
    BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,subjectSubDir,prefix,'channel.mat');
    Ceeg = load(BSTChannelsFile);
    
    ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;
    BSTScalpFile = bst_fullfile(ProtocolInfo.SUBJECTS, ScalpFile);
    Sh = load(BSTScalpFile);  
    
    %%
    %% Genering eeg file
    %%
    if(isfield(selected_data_set, 'preprocessed_eeg'))
        if(~isequal(selected_data_set.preprocessed_eeg.path,'none'))
            [filepath,name,ext]= fileparts(selected_data_set.preprocessed_eeg.file_location);
            file_name = strrep(name,'SubID',subID);
            eeg_file = fullfile(selected_data_set.preprocessed_eeg.path,subID,filepath,[file_name,ext]);
            if(isfile(eeg_file))
                disp ("-->> Genering eeg file");
                [hdr, data] = import_eeg_format(eeg_file,selected_data_set.preprocessed_eeg.format);
                labels = hdr.label;
                labels = strrep(labels,'REF','');
                [Ceeg] = remove_channels_from_layout(labels,Ceeg);
                save(strcat(output_subject,filesep,'eeg',filesep,'eeg.mat'),'data');
            end
        end
    end
    
    save(strcat(output_subject,filesep,'leadfield',filesep,'leadfield.mat'),'Ke','GridOrient','GridAtlas');
    save(strcat(output_subject,filesep,'surf',filesep,'surf.mat'),'Sc');
    save(strcat(output_subject,filesep,'scalp',filesep,'scalp.mat'),'Ceeg','Sh');
    
    % waitbar(0.25,process_waitbar,strcat('Genering eeg file for: ' , subject_name ));
    % waitbar(0.5,process_waitbar,strcat('Genering leadfield file for: ' , subject_name ));
    %  -------- Genering scalp file -------------------------------
    %delete(process_waitbar);
% catch exception
%     brainstorm stop;
%     fprintf(2,strcat("\n -->> Protocol stoped \n"));
%     msgText = getReport(exception);
%     fprintf(2,strcat("\n -->> ", string(msgText), "\n"));
% end


end

