function save_error = save_output_files(varargin)

save_error = [];
%%
%% Creating structure
%%
for i=1:length(varargin)
    eval([inputname(i) '= varargin{i};']);
end
% Creating subject folder structure
disp(strcat("-->> Creating subject output structure"));
if(~exist('action', 'var'))
    action                              = 'all';
end
disp(strcat("-->> Creating subject output structure"));
[output_subject_dir]                    = create_data_structure(base_path,subID,action);
subject_info                            = struct;
subject_info.name                       = subID;
if(isequal(action,'all'))
    for i=1:length(MEEGs)
        MEEG = MEEGs(i);
        subject_info.meeg_dir{i}        = replace(fullfile('meeg',strcat(MEEG.filename,'.mat')),'\','/');
    end
end
subject_info.leadfield_dir.leadfield    = replace(fullfile('leadfield','leadfield.mat'),'\','/');
subject_info.leadfield_dir.AQCI         = replace(fullfile('leadfield','AQCI.mat'),'\','/');
subject_info.sourcemodel_dir            = replace(fullfile('sourcemodel','cortex.mat'),'\','/');
subject_info.channel_dir                = replace(fullfile('channel','channel.mat'),'\','/');
subject_info.headmodel_dir.scalp        = replace(fullfile('headmodel','scalp.mat'),'\','/');
subject_info.headmodel_dir.innerskull   = replace(fullfile('headmodel','innerskull.mat'),'\','/');
subject_info.headmodel_dir.outerskull   = replace(fullfile('headmodel','outerskull.mat'),'\','/');
subject_info.brainstorm_dir             = replace(fullfile('brainstorm',strcat(subID,'.zip')),'\','/');
subject_info.completed                  = true;

% Saving subject files
if(isequal(action,'all'))
    disp ("-->> Saving MEEG file");
    for i=1:length(MEEGs)
        EEG = MEEGs(i);
        save(fullfile(output_subject_dir,subject_info.meeg_dir{i}),'-struct','EEG');
    end
end

%%
%% Export subject from protocol
%%
if(isequal(action,'all'))
    disp ("-->> Saving Brainstorm subject file");
    process_export_subject(output_subject_dir, subID, MEEGs(1));
end
disp ("-->> Saving channel file");
save(fullfile(output_subject_dir,subject_info.channel_dir),'-struct','Cdata');
disp ("-->> Saving leadfield file");
save(fullfile(output_subject_dir,subject_info.leadfield_dir.leadfield),'-struct','HeadModels');
disp ("-->> Saving AQCI file");
save(fullfile(output_subject_dir,subject_info.leadfield_dir.AQCI),'-struct','AQCI');
disp ("-->> Saving scalp file");
save(fullfile(output_subject_dir,subject_info.headmodel_dir.scalp),'-struct','Shead');
disp ("-->> Saving outer skull file");
save(fullfile(output_subject_dir,subject_info.headmodel_dir.outerskull),'-struct','Sout');
disp ("-->> Saving inner skull file");
save(fullfile(output_subject_dir,subject_info.headmodel_dir.innerskull),'-struct','Sinn');
disp ("-->> Saving surf file");
save(fullfile(output_subject_dir,subject_info.sourcemodel_dir),'-struct','Scortex');
disp ("-->> Saving subject file");

saveJSON(subject_info,fullfile(output_subject_dir,strcat(subID,'.json')));
h = matlab.desktop.editor.openDocument(fullfile(output_subject_dir,strcat(subID,'.json')));
h.smartIndentContents
h.save
h.close
disp("--------------------------------------------------------------------------");
end


