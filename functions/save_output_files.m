function save_output_files(selected_data_set,modality,MEEGs,HeadModels,iHeadModel,scalp,outerS,innerS,surf)
%%
%% Creating structure for each selected event
%%
for m=1:length(MEEGs)
    MEEG = MEEGs(m);
    % Creating subject folder structure
    disp(strcat("-->> Creating subject output structure"));
    [output_subject_dir] = create_data_structure(selected_data_set.bcv_config.export_path,MEEG.subID);
    
    subject_info = struct;
    if(isfolder(output_subject_dir))
        leadfield_dir = struct;
        for h=1:length(HeadModels)
            HeadModel = HeadModels(h);
            dirref = replace(fullfile('leadfield',strcat(HeadModel.Comment,'_',num2str(posixtime(datetime(HeadModel.History{1}))),'.mat')),'\','/');
            leadfield_dir(h).path = dirref;
        end
        subject_info.name = MEEG.subID;
        subject_info.modality = modality;
        subject_info.leadfield_dir = leadfield_dir;
        dirref = replace(fullfile('surf','surf.mat'),'\','/');
        subject_info.surf_dir = dirref;
        dirref = replace(fullfile('scalp','scalp.mat'),'\','/');
        subject_info.scalp_dir = dirref;
        dirref = replace(fullfile('scalp','innerskull.mat'),'\','/');
        subject_info.innerskull_dir = dirref;
        dirref = replace(fullfile('scalp','outerskull.mat'),'\','/');
        subject_info.outerskull_dir = dirref;
    end
    
    if(isfield(MEEG,'data'))
        dirref = replace(fullfile('meeg','meeg.mat'),'\','/');
        subject_info.meeg_dir = dirref;
        disp ("-->> Saving MEEG file");
        save(fullfile(output_subject_dir,'meeg','meeg.mat'),'MEEG');
    end
    
    % Saving subject files
    
    for h=1:length(HeadModels)
        HeadModel   = HeadModels(h);
        Comment     = HeadModel.Comment;
        Method      = HeadModel.Method;
        Ke          = HeadModel.Ke;
        GridOrient  = HeadModel.GridOrient;
        GridAtlas   = HeadModel.GridAtlas;
        History     = HeadModel.History;
        disp ("-->> Saving leadfield file");
        save(fullfile(output_subject_dir,'leadfield',strcat(HeadModel.Comment,'_',num2str(posixtime(datetime(History{1}))),'.mat')),...
            'Comment','Method','Ke','GridOrient','GridAtlas','iHeadModel','History');
    end
    disp ("-->> Saving surf file");
    Sc = surf.Sc;
    sub_to_FSAve = surf.sub_to_FSAve;
    iCortex = surf.iCortex;
    save(fullfile(output_subject_dir,'surf','surf.mat'),'Sc','sub_to_FSAve','iCortex');
    disp ("-->> Saving scalp file");
    Cdata = scalp.Cdata;
    Sh = scalp.Sh;
    save(fullfile(output_subject_dir,'scalp','scalp.mat'),'Cdata','Sh');
    disp ("-->> Saving inner skull file");
    Sinn = innerS.Sinn;
    save(fullfile(output_subject_dir,'scalp','innerskull.mat'),'Sinn');
    disp ("-->> Saving outer skull file");
    Sout = outerS.Sout;
    save(fullfile(output_subject_dir,'scalp','outerskull.mat'),'Sout');
    disp ("-->> Saving subject file");    
    save(fullfile(output_subject_dir,'subject.mat'),'subject_info');
    disp("---------------------------------------------------------------------");
end

end

