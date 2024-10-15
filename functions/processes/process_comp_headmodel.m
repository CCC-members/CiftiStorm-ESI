function [CiftiStorm, OPTIONS] = process_comp_headmodel(CiftiStorm, properties, subID, CSurfaces, app)

if(getGlobalGuimode())
    uimsg = uiprogressdlg(app,'Title',strcat("Process Compute Headmodel for: ", subID));
end

%%
%% Getting Headmodel options
%%
errMessage = [];
% Get Protocol information
headmodel_params            = properties.headmodel_params.Method;
Method                      = headmodel_params.name;
ProtocolInfo                = bst_get('ProtocolInfo');
% Get subject directory
[sSubject, iSubject]        = bst_get('Subject', subID);
if(isequal(properties.channel_params.channel_type.id,'raw'))
    [~, iStudy]             = bst_get('StudyWithSubject', sSubject.FileName);
else
    [~, iStudy]             = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
end
for i=1:length(CSurfaces)
    CSurface = CSurfaces(i);
    if(~isempty(CSurface.name) && isequal(CSurface.type,'cortex'))
        switch Method
            case 'meg_sphere'
                sMethod.Comment = 'Single sphere';
                sMethod.HeadModelType = 'surface';
                sMethod.MEGMethod = 'meg_sphere';
                sMethod.EEGMethod = '';
                sMethod.ECOGMethod = '';
                sMethod.SEEGMethod = '';
                sMethod.SaveFile = 1;

            case 'eeg_3sphereberg'
                sMethod.Comment = '3-shell sphere';
                sMethod.HeadModelType = 'surface';
                sMethod.MEGMethod = '';
                sMethod.EEGMethod = 'eeg_3sphereberg';
                sMethod.ECOGMethod = '';
                sMethod.SEEGMethod = '';
                sMethod.SaveFile = 1;

            case 'os_meg'
                sMethod.Comment = 'Overlapping spheres';
                sMethod.HeadModelType = 'surface';
                sMethod.MEGMethod = 'os_meg';
                sMethod.EEGMethod = '';
                sMethod.ECOGMethod = '';
                sMethod.SEEGMethod = '';
                sMethod.SaveFile = 1;

            case 'openmeeg'
                sMethod.Comment = 'OpenMEEG BEM';
                sMethod.HeadModelType = 'surface';
                sMethod.MEGMethod = '';
                sMethod.EEGMethod = 'openmeeg';
                sMethod.ECOGMethod = '';
                sMethod.SEEGMethod = '';
                sMethod.SaveFile = 1;

            case 'duneuro'
                sMethod.Comment = 'DUNEuro FEM';
                sMethod.HeadModelType = 'surface';
                sMethod.MEGMethod = '';
                sMethod.EEGMethod = 'duneuro';
                sMethod.ECOGMethod = '';
                sMethod.SEEGMethod = '';
                sMethod.SaveFile = 1;

                fem_params                  = properties.headmodel_params.Method.methods;
                fem_mesh_params             = fem_params.FemMesh;
                mesh_opt                    = process_fem_mesh( 'GetDefaultOptions' );
                mesh_opt.Method             = fem_mesh_params.Method.value;
                mesh_opt.MeshType           = fem_mesh_params.MeshType.value;
                mesh_opt.MaxVol             = fem_mesh_params.MaxVol.value;
                mesh_opt.KeepRatio          = fem_mesh_params.KeepRatio.value ./100;
                mesh_opt.BemFiles           = BemFiles;
                mesh_opt.MergeMethod        = fem_mesh_params.MergeMethod.value;
                mesh_opt.VertexDensity      = fem_mesh_params.VertexDensity.value;
                mesh_opt.NbVertices         = fem_mesh_params.NbVertices.value;
                mesh_opt.NodeShift          = fem_mesh_params.NodeShift.value;
                mesh_opt.Downsample         = fem_mesh_params.Downsample.value;
                mesh_opt.Zneck              = fem_mesh_params.Zneck.value;
                [isOk, errMsg]              = process_fem_mesh('Compute', iSubject, [], false, mesh_opt);

                [sSubject]                  = bst_get('Subject', subID);
                FemFile                     = sSubject.Surface(sSubject.iFEM).FileName;
                BSTFemFile                  = bst_fullfile(ProtocolInfo.SUBJECTS, FemFile);
                options.FemFile             = BSTFemFile;
                options.FemCond             = fem_params.FemCond;
                options.FemSelect           = fem_params.FemSelect;
                options.UseTensor           = fem_params.UseTensor;
                options.Isotropic           = fem_params.Isotropic;
                options.SrcShrink           = 0;
                options.SrcForceInGM        = 0;
                options.FemType             = 'fitted';
                options.SolverType          = 'cg';
                options.GeometryAdapted     = 0;
                options.Tolerance           = 1.0000e-08;
                options.ElecType            = 'normal';
                options.MegIntorderadd      = 0;
                options.MegType             = 'physical';
                options.SolvSolverType      = 'cg';
                options.SolvPrecond         = 'amg';
                options.SolvSmootherType    = 'ssor';
                options.SolvIntorderadd     = 0;
                options.DgSmootherType      = 'ssor';
                options.DgScheme            = 'sipg';
                options.DgPenalty           = 20;
                options.DgEdgeNormType      = 'houston';
                options.DgWeights           = 1;
                options.DgReduction         = 1;
                options.SolPostProcess      = 1;
                options.SolSubstractMean    = 0;
                options.SolSolverReduction  = 1.0000e-10;
                options.SrcModel            = 'venant';
                options.SrcIntorderadd      = 0;
                options.SrcIntorderadd_lb   = 2;
                options.SrcNbMoments        = 3;
                options.SrcRefLen           = 20;
                options.SrcWeightExp        = 1;
                options.SrcRelaxFactor      = 6;
                options.SrcMixedMoments     = 1;
                options.SrcRestrict         = 1;
                options.SrcInit             = 'closest_vertex';
                options.BstSaveTransfer     = 0;
                options.BstEegTransferFile  = 'eeg_transfer.dat';
                options.BstMegTransferFile  = 'meg_transfer.dat';
                options.BstEegLfFile        = 'eeg_lf.dat';
                options.BstMegLfFile        = 'meg_lf.dat';
                options.UseIntegrationPoint = 1;
                options.EnableCacheMemory   = 0;
                options.MegPerBlockOfSensor = 0;
        end

        %%
        %% Computing Headmodel
        %%
        [OPTIONS, errMessage] = script_panel_headmodel('ComputeHeadModel', iStudy,sMethod);        

    end
end
if(isempty(errMessage))
    CiftiStorm.Participants(end).Status             = "Processing";
    CiftiStorm.Participants(end).FileInfo           = "";
    CiftiStorm.Participants(end).Process(end+1).Name    = "Headmodel";
    CiftiStorm.Participants(end).Process(end).Status  = "Completed";
    CiftiStorm.Participants(end).Process(end).Error   = errMessage;
else
    CiftiStorm.Participants(end).Status             = "Rejected";
    CiftiStorm.Participants(end).FileInfo           = "";
    CiftiStorm.Participants(end).Process(end+1).Name    = "Headmodel";
    CiftiStorm.Participants(end).Process(end).Status  = "Rejected";
    CiftiStorm.Participants(end).Process(end).Error   = errMessage;
end

if(getGlobalGuimode())
    delete(uimsg);
end

end