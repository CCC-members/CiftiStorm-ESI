function [headmodel_options, errMessage] = process_comp_headmodel(properties, subID)

%%
%% Getting Headmodel options
%%
% Get Protocol information
ProtocolInfo                = bst_get('ProtocolInfo');
% Get subject directory
[sSubject]                  = bst_get('Subject', subID);
[sStudies, iStudy]          = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
sStudy                      = bst_get('Study', iStudy);
options                     = struct();

options.HeadModelFile       = bst_fullfile(ProtocolInfo.STUDIES,sSubject.Name,sStudy.Name);
options.HeadModelType       = 'surface';

% Uploading Channels
BSTChannelsFile             = bst_fullfile(ProtocolInfo.STUDIES,sStudy.Channel.FileName);
BSTChannels                 = load(BSTChannelsFile);
options.Channel             = BSTChannels.Channel;

options.ECOGMethod          = '';
options.SEEGMethod          = '';
options.HeadCenter          = [];
options.Radii               = properties.headmodel_params.general.radii';
options.Conductivity        = properties.headmodel_params.general.conductivity';
options.SourceSpaceOptions  = [];
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

options.GridOptions         = [];
options.GridLoc             = [];
options.GridOrient          = [];
options.GridAtlas           = [];
options.Interactive         = true;
options.SaveFile            = true;

if(isequal(properties.general_params.modality,'EEG'))
    
    options.Comment         = 'OpenMEEG BEM';
    options.MegRefCoef      = [];
    options.MEGMethod       = '';
    options.EEGMethod       = 'openmeeg';
    BSTScalpFile            = bst_fullfile(ProtocolInfo.SUBJECTS, ScalpFile);
    BSTOuterSkullFile       = bst_fullfile(ProtocolInfo.SUBJECTS, OuterSkullFile);
    BSTInnerSkullFile       = bst_fullfile(ProtocolInfo.SUBJECTS, InnerSkullFile);
    options.BemFiles        = {BSTScalpFile, BSTOuterSkullFile,BSTInnerSkullFile};
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
else
    options.Comment         = 'Overlapping spheres'; % for EEG 'OpenMEEG BEM'
    options.MegRefCoef      = BSTChannels.MegRefCoef;
    options.MEGMethod       = 'os_meg'; %openmeg
    options.EEGMethod       = '';
    options.OuterSkullFile  = [];
end

%%
%% Computing Headmodel 
%%
[headmodel_options, errMessage] = bst_headmodeler(options);

sStudy = bst_get('Study', iStudy);
% If a new head model is available
sHeadModel                      = db_template('headmodel');
sHeadModel.FileName             = file_short(headmodel_options.HeadModelFile);
sHeadModel.Comment              = headmodel_options.Comment;
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
%%
%% Checking the report output structure
%%
[subject_report_path, report_name] = get_report_path(properties, subID);
qc_headmodel(headmodel_options,properties.general_params.modality,subject_report_path);

%%
%% Save and display report
%%
ReportFile = bst_report('Save', []);
bst_report('Export',  ReportFile,report_name);
bst_report('Open', ReportFile);
bst_report('Close');
processed = true;
disp(strcat("-->> Process finished for subject: Template"));

end

