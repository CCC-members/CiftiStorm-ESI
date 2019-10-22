function [] = export_subject_BCV(sSubject)


app_properties = jsondecode(fileread(strcat('app',filesep,'app_properties.json')));
selected_data_set = app_properties.data_set(app_properties.selected_data_set.value);
selected_data_set = selected_data_set{1,1};
bcv_path = selected_data_set.bcv_input_path;

if(~isfolder(bcv_path))
    mkdir(bcv_path);
end

%% Creating subject folder structure
disp('BST-P ->> Creating subject folder structure.');
subject_path = fullfile(bcv_path,sSubject.Name);
mkdir(subject_path);
eeg_path = fullfile(subject_path,'eeg');
mkdir(eeg_path);
leadfield_path = fullfile(subject_path,'leadfield');
mkdir(leadfield_path);
scalp_path = fullfile(subject_path,'scalp');
mkdir(scalp_path);
surf_path = fullfile(subject_path,'surf');
mkdir(surf_path);
 

[path,subject_name,ext] = fileparts(subject,sSubject.Name);

%% Uploding Subject file into BrainStorm Protocol
disp('BST-P ->> Uploding Subject file into BrainStorm Protocol.')





process_waitbar = waitbar(0,strcat('Importing data subject: ' , subject_name ));

[output_subject] = create_data_structure(bcv_input_folder,subject_name);

sub_folders = dir(subject);
chanlocs = '';
K_6k = double([]);
orig_leadfield = '';

for i=1:size(sub_folders,1)
    subfolder = sub_folders(i).name;
    if(isfolder(fullfile(subject,subfolder)) & subfolder ~= '.' & string(subfolder) ~="..")
        if(contains(subfolder,'data','IgnoreCase',true))
            waitbar(0.25,process_waitbar,strcat('Genering eeg file for: ' , subject_name ));
            
            files=dir(fullfile(subject,subfolder));
            if(numel(files)>2  &  contains(files(3).name,'.mat'))
                filename_resting = files(3).name;
                if(isfile(fullfile(subject,subfolder,filename_resting)))
                    disp (">> Genering eeg file");
                    load(fullfile(subject,subfolder,filename_resting));
                    data = result.data;
                    save(strcat(output_subject,filesep,'eeg',filesep,'eeg.mat'),'data');
                    chanlocs = result.chanlocs;
                end
            end
        end
        if(contains(subfolder,'brainstorm','IgnoreCase',true))
            brainstorm_folder = subfolder;
            waitbar(0.5,process_waitbar,strcat('Genering leadfield file for: ' , subject_name ));
            
            data_dir = fullfile(subject,subfolder,'data');
            files_data = dir(data_dir);
            load(fullfile(data_dir,'channel.mat'));
            all_channel = Channel;
            for h = 1 : size(files_data,1)
                file_data = files_data(h).name;
                if(contains(file_data,'headmodel','IgnoreCase',true))
                    load(strcat(data_dir,filesep,file_data));
                    orig_leadfield = bst_gain_orient(Gain, GridOrient);
                end
            end
            
            
            
        end
    end
end
%----- Genering leadfield file -----------------------------------
%----- Delete bad channels -----------------------------------
disp (">> Genering leadfield file");

reduced_channel = struct;
if(~isempty(chanlocs))
    conv_ASA343 = {length(chanlocs)};
    
    for p = 1 : length(chanlocs)
        true_label = chanlocs(p).labels;
        for o = 1 : length(all_channel)
            orig_label = all_channel(o).Name;
            if(isequal(true_label,orig_label))
                row = orig_leadfield(o,:);
                K_6k(end + 1,:) =  row;
                conv_ASA343(p) = {o};
                if (p == 1)
                    for fn = fieldnames(all_channel)'
                        reduced_channel(p).(fn{1}) = all_channel(o).(fn{1});
                    end
                else
                    reduced_channel(p) = all_channel(o);
                end
                break;
            end
        end
        if (~isequal(length(true_label),length(K_6k)))
            row = orig_leadfield(end,:);
            K_6k(end + 1,:) =  row;
            conv_ASA343(end + 1) = {length(all_channel)};
            reduced_channel(end + 1) = all_channel(end);
        end
        save(strcat(output_subject,filesep,'leadfield',filesep,'leadfield.mat'),'K_6k');
        
    end
else
    chanlocs = all_channel;
    reduced_channel = all_channel;
    K_6k = orig_leadfield;
    conv_ASA343 = {length(all_channel)};
    for i = 1:length(all_channel)
        conv_ASA343(i)= {i} ;
    end   
     save(strcat(output_subject,filesep,'leadfield',filesep,'leadfield.mat'),'K_6k');
end

%  -------- Genering scalp file -------------------------------
disp (">> Genering scalp file");
% ---- Geting ASA_343 -----------------------
waitbar(0.75,process_waitbar,strcat('Genering scalp file for: ' , subject_name ));

ASA_343 = struct;
ASA_343.Comment = Comment;
ASA_343.MegRefCoef = MegRefCoef;
ASA_343.Projector =  Projector;
ASA_343.TransfMeg = TransfMeg;
ASA_343.TransfMegLabels = TransfMegLabels;
ASA_343.TransfEegLabels = TransfEegLabels;
ASA_343.TransfEeg = TransfEeg;
ASA_343.HeadPoints = HeadPoints;
ASA_343.Channel = reduced_channel;
ASA_343.IntraElectrodes = IntraElectrodes;
ASA_343.History = History;
ASA_343.SCS = SCS;


% ---- Geting electrodes_343 -----------------------
elect_58_343 = struct;
try
    elect_58_343.label = {chanlocs.labels}';
catch
    elect_58_343.label = {chanlocs.Name}';
end
elect_58_343.conv_ASA343 = conv_ASA343';



% ----- Geting S_H --------------------------------
surf_file = SurfaceFile;
[filepath,surf_name,ext]  =  fileparts(surf_file);

anat_dir = fullfile(subject,brainstorm_folder,'anat');
load(strcat(anat_dir,filesep,surf_name,'.mat'));

S_h = struct;
S_h.Faces = Faces;
S_h.Vertices = Vertices;
S_h.Comment = Comment;
S_h.Atlas = Atlas;
S_h.iAtlas = iAtlas;
S_h.VertConn = VertConn;
S_h.VertNormals = VertNormals;
S_h.Curvature = Curvature;
S_h.SulciMap = SulciMap;
S_h.History = History;

% ----------------- Saving scalp file ----------------
save(strcat(output_subject,filesep,'scalp',filesep,'scalp.mat'),'ASA_343','elect_58_343','S_h');


waitbar(1,process_waitbar,strcat('Genering surf file for: ' , subject_name ));
%  -------- Genering surf file -------------------------------
disp (">> Genering surf file");
S_6k = struct;
S_6k.Faces = Faces;
S_6k.Vertices = Vertices;
S_6k.Comment = Comment;
S_6k.History = History;
% S_6k.Reg = Reg;
S_6k.VertConn = VertConn;
S_6k.VertNormals = VertNormals;
S_6k.Curvature = Curvature;
S_6k.SulciMap = SulciMap;
S_6k.Atlas = Atlas;
S_6k.iAtlas = iAtlas;

% ----------------- Saving surf file ----------------
save(strcat(output_subject,filesep,'surf',filesep,'surf.mat'),'S_6k');
delete(process_waitbar);


end

