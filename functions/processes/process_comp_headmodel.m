function [headmodel_options, errMessage] = process_comp_headmodel(properties, subID)

%%
%% Getting Headmodel options
%%
% Get Protocol information
modality                    = properties.general_params.modality;
Method                      = properties.headmodel_params.Method.value;
ProtocolInfo                = bst_get('ProtocolInfo');
% Get subject directory
[sSubject, iSubject]        = bst_get('Subject', subID);
[sStudies, iStudy]          = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
sStudy                      = bst_get('Study', iStudy);

[options, errMessage]       = bst_headmodeler;

options.HeadModelFile       = bst_fullfile(ProtocolInfo.STUDIES,sSubject.Name,sStudy.Name);
options.HeadModelType       = 'surface';

% Uploading Channels
BSTChannelsFile             = bst_fullfile(ProtocolInfo.STUDIES,sStudy.Channel.FileName);
BSTChannels                 = load(BSTChannelsFile);
options.Channel             = BSTChannels.Channel;

options.Radii               = properties.headmodel_params.radii';
options.Conductivity        = properties.headmodel_params.conductivity';
% Uploading head
ScalpFile                   = sSubject.Surface(sSubject.iScalp).FileName;
options.HeadFile            = ScalpFile;
% Uploading OuterSkull
OuterSkullFile              = sSubject.Surface(sSubject.iOuterSkull).FileName;
options.OuterSkullFile      = OuterSkullFile;
% options.OuterSkullFile      = [];
% Uploading InnerSkull
InnerSkullFile              = sSubject.Surface(sSubject.iInnerSkull).FileName;
options.InnerSkullFile      = InnerSkullFile;
% Uploading cortex
CortexFile                  = sSubject.Surface(sSubject.iCortex).FileName;
options.CortexFile          = CortexFile;

options.Interactive         = false;
options.SaveFile            = true;

BSTScalpFile                = bst_fullfile(ProtocolInfo.SUBJECTS, ScalpFile);
BSTOuterSkullFile           = bst_fullfile(ProtocolInfo.SUBJECTS, OuterSkullFile);
BSTInnerSkullFile           = bst_fullfile(ProtocolInfo.SUBJECTS, InnerSkullFile);
BemFiles                    = {BSTScalpFile, BSTOuterSkullFile,BSTInnerSkullFile};
options.BemFiles            = BemFiles;
%         options.BemFiles = {BSTScalpFile,BSTInnerSkullFile};
options.BemNames            = properties.headmodel_params.BemNames;
%         options.BemNames = {'Scalp','Brain'};
options.BemCond             = properties.headmodel_params.BemCond;
options.BemSelect           = properties.headmodel_params.BemSelect;

switch modality
    case 'EEG'
        options.MEGMethod   = [];
        options.EEGMethod   = Method;
        options.ECOGMethod  = [];
        options.SEEGMethod  = [];
    case 'MEG'
        options.MEGMethod   = Method;
        options.EEGMethod   = [];
        options.ECOGMethod  = [];
        options.SEEGMethod  = [];
    case 'ECOG'
        options.MEGMethod   = [];
        options.EEGMethod   = [];
        options.ECOGMethod  = Method;
        options.SEEGMethod  = [];
    case 'SEEG'
        options.MEGMethod   = [];
        options.EEGMethod   = [];
        options.ECOGMethod  = [];
        options.SEEGMethod  = Method; 
end
switch Method    
    case 'openmeeg'
        options.MegRefCoef      = [];
        options.MEGMethod       = '';
        options.EEGMethod       = 'openmeeg';
        options.BemFiles        = BemFiles;
        %         options.BemFiles = {BSTScalpFile,BSTInnerSkullFile};
        options.BemNames        = {'Scalp','Skull','Brain'};
        %         options.BemNames = {'Scalp','Brain'};
        options.BemCond         = [1,0.0125,1];
        %         options.BemCond = [1,1];
        options.iMeg            = [];
        options.iEeg            = 1:length(BSTChannels.Channel);
        options.iEcog           = [];
        options.iSeeg           = [];
        options.BemSelect       = [true,true,true];
        %         options.BemSelect = [true,true];
        options.isAdjoint       = false;
        options.isAdaptative    = true;
        options.isSplit         = false;
        options.SplitLength     = 4000;
    case 'os_meg'
        
        options.MegRefCoef      = BSTChannels.MegRefCoef;
        options.MEGMethod       = 'os_meg'; %openmeg
        options.EEGMethod       = '';
        options.OuterSkullFile  = [];
    case 'duneuro'
        fem_params              = properties.headmodel_params.method_type{3};
        fem_mesh_params         = fem_params.FemMesh;
        mesh_opt                = process_fem_mesh( 'GetDefaultOptions' );
        mesh_opt.Method         = fem_mesh_params.Method.value;
        mesh_opt.MeshType       = fem_mesh_params.MeshType.value;
        mesh_opt.MaxVol         = fem_mesh_params.MaxVol.value;
        mesh_opt.KeepRatio      = fem_mesh_params.KeepRatio.value ./100;        
        mesh_opt.BemFiles       = BemFiles;
        mesh_opt.MergeMethod    = fem_mesh_params.MergeMethod.value;
        mesh_opt.VertexDensity  = fem_mesh_params.VertexDensity.value;
        mesh_opt.NbVertices     = fem_mesh_params.NbVertices.value;
        mesh_opt.NodeShift      = fem_mesh_params.NodeShift.value;
        mesh_opt.Downsample     = fem_mesh_params.Downsample.value;
        mesh_opt.Zneck          = fem_mesh_params.Zneck.value;        
        [isOk, errMsg]          = process_fem_mesh('Compute', iSubject, [], false, mesh_opt);
        
        [sSubject]              = bst_get('Subject', subID);
        FemFile                 = sSubject.Surface(sSubject.iFEM).FileName;
        BSTFemFile              = bst_fullfile(ProtocolInfo.SUBJECTS, FemFile);
        options.FemFile         = BSTFemFile;
        options.FemCond         = fem_params.FemCond;
        options.FemSelect       = fem_params.FemSelect;                
        options.UseTensor       = fem_params.UseTensor;
        options.Isotropic       = fem_params.Isotropic;
        options.SrcShrink       = 0;
        options.SrcForceInGM    = 0;           
        options.FemType         = 'fitted';
        options.SolverType      = 'cg';
        options.GeometryAdapted = 0;
        options.Tolerance       = 1.0000e-08;
        options.ElecType        = 'normal';
        options.MegIntorderadd  = 0;
        options.MegType         = 'physical';
        options.SolvSolverType  = 'cg';
        options.SolvPrecond     = 'amg';
        options.SolvSmootherType = 'ssor'; 
        options.SolvIntorderadd = 0;
        options.DgSmootherType  = 'ssor';
        options.DgScheme        = 'sipg';
        options.DgPenalty       = 20;
        options.DgEdgeNormType  = 'houston';
        options.DgWeights       = 1;
        options.DgReduction     = 1;
        options.SolPostProcess  = 1;
        options.SolSubstractMean = 0;
        options.SolSolverReduction = 1.0000e-10;
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

    case 'meg_sphere'
    case 'eeg_3sphereberg'       
end

%%
%% Computing Headmodel 
%%
[headmodel_options, errMessage] = bst_headmodeler(options);

sStudy = bst_get('Study', iStudy);
% If a new head model is available
sHeadModel                      = db_template('headmodel');
sHeadModel.FileName             = file_short(headmodel_options.HeadModelFile);
sHeadModel.Comment              = strrep(headmodel_options.Comment,' ','');
sHeadModel.HeadModelType        = headmodel_options.HeadModelType;
% Update Study structure
iHeadModel                      = length(sStudy.HeadModel) + 1;
sStudy.HeadModel(iHeadModel)    = sHeadModel;
sStudy.iHeadModel               = iHeadModel;
sStudy.iChannel                 = length(sStudy.Channel);
% Update DataBase
bst_set('Study', iStudy, sStudy);
db_save();

%%
%% Quality control of Head model
%%
qc_headmodel(headmodel_options, properties, subID);

end

