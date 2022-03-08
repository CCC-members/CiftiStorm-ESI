function save_error = save_output_files(properites,modality,MEEGs,HeadModels,Cdatas,scalp,outerS,innerS,surf)

save_error = [];
%%
%% Creating structure for each selected event
%%
try
    for m=1:length(MEEGs)
        MEEG = MEEGs(m);
        % Creating subject folder structure
        disp(strcat("-->> Creating subject output structure"));
        [output_subject_dir] = create_data_structure(properites.general_params.bcv_config.export_path,MEEG.subID);
        HeadModel  = HeadModels(m);
        subject_info = struct;
        if(isfolder(output_subject_dir))                        
            subject_info.name           = MEEG.subID;
            subject_info.modality       = modality;
            dirref                      = replace(fullfile('leadfield',strcat(HeadModel.Comment,'.mat')),'\','/');
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
        end        
        if(isfield(MEEG,'data'))
            dirref = replace(fullfile('meeg','meeg.mat'),'\','/');
            subject_info.meeg_dir = dirref;
            disp ("-->> Saving MEEG file");
            save(fullfile(output_subject_dir,'meeg','meeg.mat'),'-struct','MEEG');
        end
        % Saving subject files
        disp ("-->> Saving leadfield file");
        save(fullfile(output_subject_dir,'leadfield',strcat(HeadModel.Comment,'.mat')),'-struct','HeadModel');
        disp ("-->> Saving surf file");
        Sc = surf.Sc;
        sub_to_FSAve = surf.sub_to_FSAve;
        iCortex = surf.iCortex;
        save(fullfile(output_subject_dir,'surf','surf.mat'),'Sc','sub_to_FSAve','iCortex');
        disp ("-->> Saving scalp file");
        Cdata = Cdatas(m);
        save(fullfile(output_subject_dir,'channel','channel.mat'),'-struct','Cdata');
        disp ("-->> Saving inner skull file");
        Shead = scalp.Sh;
        save(fullfile(output_subject_dir,'scalp','scalp.mat'),'-struct','Shead');
        disp ("-->> Saving inner skull file");
        Sinn = innerS.Sinn;
        save(fullfile(output_subject_dir,'scalp','innerskull.mat'),'-struct','Sinn');
        disp ("-->> Saving outer skull file");
        Sout = outerS.Sout;
        save(fullfile(output_subject_dir,'scalp','outerskull.mat'),'-struct','Sout');
        disp ("-->> Saving subject file");
        save(fullfile(output_subject_dir,'subject.mat'),'-struct','subject_info');
        disp("---------------------------------------------------------------------");
    end
catch
    save_error = 1;
end
end


