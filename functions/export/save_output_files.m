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
action                                  = 'anat';
[output_subject_dir]                    = create_data_structure(base_path,subID,action);
subject_info                            = struct;
subject_info.name                       = subID;
subject_info.modality                   = modality;
subject_info.leadfield_dir.leadfield    = replace(fullfile('leadfield','leadfield.mat'),'\','/');
subject_info.leadfield_dir.AQCI         = replace(fullfile('leadfield','AQCI.mat'),'\','/');
subject_info.sourcemodel_dir            = replace(fullfile('sourcemodel','cortex.mat'),'\','/');
subject_info.channel_dir                = replace(fullfile('channel','channel.mat'),'\','/');
subject_info.headmodel_dir.scalp        = replace(fullfile('headmodel','scalp.mat'),'\','/');
subject_info.headmodel_dir.outerskull   = replace(fullfile('headmodel','outerskull.mat'),'\','/');
subject_info.headmodel_dir.innerskull   = replace(fullfile('headmodel','innerskull.mat'),'\','/');
subject_info.completed                  = false;

% Saving subject files
disp ("-->> Saving scalp file");
save(fullfile(output_subject_dir,subject_info.headmodel_dir.scalp),'-struct','Shead');
disp ("-->> Saving outer skull file");
save(fullfile(output_subject_dir,subject_info.headmodel_dir.outerskull),'-struct','Sout');
disp ("-->> Saving inner skull file");
save(fullfile(output_subject_dir,subject_info.headmodel_dir.innerskull),'-struct','Sinn');
disp ("-->> Saving channel file");
save(fullfile(output_subject_dir,subject_info.channel_dir),'-struct','Cdata');
disp ("-->> Saving leadfield file");
save(fullfile(output_subject_dir,subject_info.leadfield_dir.leadfield),'-struct','HeadModels');
save(fullfile(output_subject_dir,subject_info.leadfield_dir.AQCI),'-struct','AQCI');
disp ("-->> Saving surf file");
save(fullfile(output_subject_dir,subject_info.sourcemodel_dir),'-struct','Scortex');
disp ("-->> Saving subject file");
subjectFile = fullfile(output_subject_dir,strcat(subID,'.json'));
saveJSON(subject_info,subjectFile);
h = matlab.desktop.editor.openDocument(subjectFile);
h.smartIndentContents
h.save
h.close
disp("--------------------------------------------------------------------------");
end


