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
action                      = 'anat';
[output_subject_dir]        = create_data_structure(base_path,subID,action);
subject_info                = struct;
subject_info.name           = subID;
subject_info.modality       = modality;
dirref                      = replace(fullfile('leadfield','leadfield.mat'),'\','/');
subject_info.leadfield_dir  = dirref;
dirref                      = replace(fullfile('sourcemodel','cortex.mat'),'\','/');
subject_info.surf_dir       = dirref;
dirref                      = replace(fullfile('channel','channel.mat'),'\','/');
subject_info.channel_dir    = dirref;
dirref                      = replace(fullfile('headmodel','scalp.mat'),'\','/');
subject_info.scalp_dir      = dirref;
dirref                      = replace(fullfile('headmodel','innerskull.mat'),'\','/');
subject_info.innerskull_dir = dirref;
dirref                      = replace(fullfile('headmodel','outerskull.mat'),'\','/');
subject_info.outerskull_dir = dirref;
subject_info.completed      = false;
% Saving subject files
disp ("-->> Saving scalp file");
save(fullfile(output_subject_dir,'headmodel','scalp.mat'),'-struct','Shead');
disp ("-->> Saving outer skull file");
save(fullfile(output_subject_dir,'headmodel','outerskull.mat'),'-struct','Sout');
disp ("-->> Saving inner skull file");
save(fullfile(output_subject_dir,'headmodel','innerskull.mat'),'-struct','Sinn');
disp ("-->> Saving channel file");
save(fullfile(output_subject_dir,'channel','channel.mat'),'-struct','Cdata');
disp ("-->> Saving leadfield file");
save(fullfile(output_subject_dir,'leadfield','leadfield.mat'),'-struct','HeadModels');
disp ("-->> Saving surf file");
save(fullfile(output_subject_dir,'sourcemodel','cortex.mat'),'-struct','Scortex');
disp ("-->> Saving subject file");
save(fullfile(output_subject_dir,'subject.mat'),'-struct','subject_info');
disp("--------------------------------------------------------------------------");
end


