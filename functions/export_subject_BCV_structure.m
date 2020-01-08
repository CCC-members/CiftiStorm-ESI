function [] = export_subject_BCV_structure(selected_data_set,subID)

%%
%% Get Protocol information
%%
% try
    ProtocolInfo = bst_get('ProtocolInfo');
    % Get subject directory
    sSubject = bst_get('Subject', subID);
    [sStudies, iStudies] = bst_get('StudyWithSubject', sSubject.FileName);
    if(~isempty(iStudies))
    else
        [sStudies, iStudies] = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
    end
    sStudy = bst_get('Study', iStudies);
    if(isempty(sSubject) || isempty(sSubject.iAnatomy) || isempty(sSubject.iCortex) || isempty(sSubject.iInnerSkull) || isempty(sSubject.iOuterSkull) || isempty(sSubject.iScalp))
        return;
    end
    bcv_path = selected_data_set.bcv_input_path;
    if(~isfolder(bcv_path))
        mkdir(bcv_path);
    end
    
    %% Uploding Subject file into BrainStorm Protocol
    disp('BST-P ->> Uploding Subject file into BrainStorm Protocol.')
    
    % process_waitbar = waitbar(0,strcat('Importing data subject: ' , subject_name ));
    %%
    %% Genering leadfield file
    %%
    
    disp ("-->> Genering leadfield file");
    BSTHeadModelFiles = fullfile(ProtocolInfo.STUDIES,sStudy.HeadModel(sStudy.iHeadModel).FileName);
    BSTHeadModel = load(BSTHeadModelFiles);
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
    BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,sStudy.Channel(sStudy.iChannel).FileName);
    Cdata = load(BSTChannelsFile);
    
    ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;
    BSTScalpFile = bst_fullfile(ProtocolInfo.SUBJECTS, ScalpFile);
    Sh = load(BSTScalpFile);  
    
    %%
    %% Genering inner skull file
    %%
    disp ("-->> Genering inner skull file");
    InnerSkullFile = sSubject.Surface(sSubject.iInnerSkull).FileName;
    BSTInnerSkullFile = bst_fullfile(ProtocolInfo.SUBJECTS, InnerSkullFile);
    Sinn = load(BSTInnerSkullFile);  
      
     %%
    %% Genering outer skull file
    %%
    disp ("-->> Genering outer skull file");
    OuterSkullFile = sSubject.Surface(sSubject.iOuterSkull).FileName;
    BSTOuterSkullFile = bst_fullfile(ProtocolInfo.SUBJECTS, OuterSkullFile);
    Sout = load(BSTOuterSkullFile);  
      
    %% Creating subject folder structure
    disp(strcat("-->> Saving BC-VARETA structure. Subject: ",sSubject.Name));
    [output_subject_dir] = create_data_structure(bcv_path,sSubject.Name,selected_data_set.modality);
    subject_info = struct;     
    
    if(isfolder(output_subject_dir))       
        subject_info.leadfield_dir = fullfile('leadfield','leadfield.mat');
        subject_info.surf_dir = fullfile('surf','surf.mat');
        subject_info.scalp_dir = fullfile('scalp','scalp.mat');
        subject_info.innerskull_dir = fullfile('scalp','innerskull.mat');
        subject_info.outerskull_dir = fullfile('scalp','outerskull.mat');
        subject_info.modality = selected_data_set.modality;
        subject_info.name = sSubject.Name;
    end
    
    %%
    %% Genering eeg file
    %%
    if(isfield(selected_data_set, 'preprocessed_eeg'))
        if(~isequal(selected_data_set.preprocessed_eeg.base_path,'none'))
            filepath = strrep(selected_data_set.preprocessed_eeg.file_location,'SubID',subID);
            base_path =  strrep(selected_data_set.preprocessed_eeg.base_path,'SubID',subID);
            eeg_file = fullfile(base_path,filepath);
            if(isfile(eeg_file))
                disp ("-->> Genering eeg file");
                [hdr, data] = import_eeg_format(eeg_file,selected_data_set.preprocessed_eeg.format);
                labels = hdr.label;
                labels = strrep(labels,'REF','');
                disp ("-->> Removing Channels  by preprocessed EEG");
                [Cdata,Ke] = remove_channels_and_leadfield_from_layout(labels,Cdata,Ke);
                disp ("-->> Sorting Channels and LeadField by preprocessed EEG");
                [Cdata,Ke] = sort_channels_and_leadfield_by_labels(label,Cdata,Ke);
                
                subject_info.eeg_dir = fullfile('eeg','eeg.mat');
                subject_info.eeg_info_dir = fullfile('eeg','eeg_info.mat');
                disp ("-->> Saving eeg_info file");
                save(fullfile(output_subject_dir,'eeg','eeg_info.mat'),'hdr');
                disp ("-->> Saving eeg file");
                save(fullfile(output_subject_dir,'eeg','eeg.mat'),'data');
            end
        end
    end
    if(isfield(selected_data_set, 'preprocessed_meg'))
        if(~isequal(selected_data_set.preprocessed_meg.base_path,'none'))
           filepath = strrep(selected_data_set.preprocessed_meg.file_location,'SubID',subID);
            base_path =  strrep(selected_data_set.preprocessed_meg.base_path,'SubID',subID);
            meg_file = fullfile(base_path,filepath);
            if(isfile(meg_file))
                disp ("-->> Genering meg file");               
                meg = load(meg_file);
                hdr = meg.data.hdr;
                fsample = meg.data.fsample;
                trialinfo = meg.data.trialinfo;
                grad = meg.data.grad;
                time = meg.data.time;
                label = meg.data.label;
                cfg = meg.data.cfg;
                %                 labels = strrep(labels,'REF','');
                disp ("-->> Removing Channels  by preprocessed MEG");
                [Cdata,Ke] = remove_channels_and_leadfield_from_layout(label,Cdata,Ke);
                disp ("-->> Sorting Channels and LeadField by preprocessed MEG");
                [Cdata,Ke] = sort_channels_and_leadfield_by_labels(label,Cdata,Ke);
                
                data = [];
                for i=1: length(meg.data.trial)
                    disp (strcat("-->> Indexing trial #: ",string(i)));
                    trial = cell2mat(meg.data.trial(1,i));                    
                    data = [data trial];
                end                
                subject_info.meg_dir = fullfile('meg','meg.mat');
                subject_info.meg_info_dir = fullfile('meg','meg_info.mat');
                disp ("-->> Saving meg_info file");
                save(strcat(output_subject_dir,filesep,'meg',filesep,'meg_info.mat'),'hdr','fsample','trialinfo','grad','time','label','cfg');
                disp ("-->> Saving meg file");
                save(strcat(output_subject_dir,filesep,'meg',filesep,'meg.mat'),'data');
            end
       end
    end   
    disp ("-->> Saving leadfield file");
    save(fullfile(output_subject_dir,'leadfield','leadfield.mat'),'Ke','GridOrient','GridAtlas');
    disp ("-->> Saving surf file");
    save(fullfile(output_subject_dir,'surf','surf.mat'),'Sc');
    disp ("-->> Saving scalp file");
    save(fullfile(output_subject_dir,'scalp','scalp.mat'),'Cdata','Sh');
    disp ("-->> Saving inner skull file");
    save(fullfile(output_subject_dir,'scalp','innerskull.mat'),'Sinn');
    disp ("-->> Saving outer skull file");
    save(fullfile(output_subject_dir,'scalp','outerskull.mat'),'Sout');
    disp ("-->> Saving subject file");
    save(fullfile(output_subject_dir,'subject.mat'),'subject_info');
    
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

