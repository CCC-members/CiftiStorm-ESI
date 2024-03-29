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
dirref                      = replace(fullfile('leadfield','headmodel.mat'),'\','/');
subject_info.leadfield_dir  = dirref;
dirref                      = replace(fullfile('surf','surf.mat'),'\','/');
subject_info.surf_dir       = dirref;
dirref                      = replace(fullfile('channel','channel.mat'),'\','/');
subject_info.channel_dir    = dirref;
dirref                      = replace(fullfile('scalp','scalp.mat'),'\','/');
subject_info.scalp_dir      = dirref;
dirref                      = replace(fullfile('scalp','innerskull.mat'),'\','/');
subject_info.innerskull_dir = dirref;
dirref                      = replace(fullfile('scalp','outerskull.mat'),'\','/');
subject_info.outerskull_dir = dirref;
subject_info.completed      = false;
% Saving subject files
disp ("-->> Saving scalp file");
save(fullfile(output_subject_dir,'scalp','scalp.mat'),'-struct','Shead');
disp ("-->> Saving outer skull file");
save(fullfile(output_subject_dir,'scalp','outerskull.mat'),'-struct','Sout');
disp ("-->> Saving inner skull file");
save(fullfile(output_subject_dir,'scalp','innerskull.mat'),'-struct','Sinn');
disp ("-->> Saving channel file");
save(fullfile(output_subject_dir,'channel','channel.mat'),'-struct','Cdata');
disp ("-->> Saving leadfield file");
save(fullfile(output_subject_dir,'leadfield','headmodel.mat'),'-struct','HeadModels');
disp ("-->> Saving surf file");
save(fullfile(output_subject_dir,'surf','surf.mat'),'-struct','Scortex');
disp ("-->> Saving subject file");
save(fullfile(output_subject_dir,'subject.mat'),'-struct','subject_info');
disp("--------------------------------------------------------------------------");
end


