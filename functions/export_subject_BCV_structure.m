function [] = export_subject_BCV_structure(selected_data_set)

%%
%% Get Protocol information
%%
ProtocolInfo = bst_get('ProtocolInfo');
% Get subject directory
[sSubject] = bst_get('Subject', subID);
subjectSubDir = bst_fileparts(sSubject.FileName);


prefix = '@intra';
if(isfield(selected_data_set, 'eeg_data_path'))
    eeg_data_path = char(selected_data_set.eeg_data_path);
    if(~isequal(eeg_data_path,"none"))
        prefix = '@raw';
    end
end

bcv_path = selected_data_set.bcv_input_path;
if(~isfolder(bcv_path))
    mkdir(bcv_path);
end

%% Creating subject folder structure
disp('-->> Creating subject folder structure.');
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

waitbar(0.25,process_waitbar,strcat('Genering eeg file for: ' , subject_name ));

disp ("-->> Genering eeg file");
load(fullfile(subject,subfolder,filename_resting));
data = result.data;
save(strcat(output_subject,filesep,'eeg',filesep,'eeg.mat'),'data');

waitbar(0.5,process_waitbar,strcat('Genering leadfield file for: ' , subject_name ));


load(fullfile(data_dir,'channel.mat'));
all_channel = Channel;

load(strcat(data_dir,filesep,file_data));
orig_leadfield = bst_gain_orient(Gain, GridOrient);
                    

%----- Genering leadfield file -----------------------------------
%----- Delete bad channels -----------------------------------
disp (">> Genering leadfield file");

save(strcat(output_subject,filesep,'leadfield',filesep,'leadfield.mat'),'K_6k');
        
 
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

