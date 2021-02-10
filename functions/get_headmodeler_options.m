function  headmodel_options = get_headmodeler_options(modality, subID, iStudy)
%GET_HEADMODELER_OPTIONS Summary of this function goes here
%   Detailed explanation goes here

%%
%% Get Protocol information
%%
ProtocolInfo = bst_get('ProtocolInfo');
% Get subject directory
[sSubject] = bst_get('Subject', subID);

sStudy = bst_get('Study', iStudy);
headmodel_options = struct();

headmodel_options.HeadModelFile = bst_fullfile(ProtocolInfo.STUDIES,sSubject.Name,sStudy.Name);
headmodel_options.HeadModelType = 'surface';

% Uploading Channels
BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,sStudy.Channel.FileName);
BSTChannels = load(BSTChannelsFile);
headmodel_options.Channel = BSTChannels.Channel;

headmodel_options.ECOGMethod = '';
headmodel_options.SEEGMethod = '';
headmodel_options.HeadCenter = [];
headmodel_options.Radii = [0.88,0.93,1];
headmodel_options.Conductivity = [0.33,0.0042,0.33];
headmodel_options.SourceSpaceOptions = [];
% Uploading head
ScalpFile                       = sSubject.Surface(sSubject.iScalp).FileName;
headmodel_options.HeadFile      = ScalpFile;
% Uploading OuterSkull
OuterSkullFile = sSubject.Surface(sSubject.iOuterSkull).FileName;
headmodel_options.OuterSkullFile =  OuterSkullFile;
% Uploading InnerSkull
InnerSkullFile = sSubject.Surface(sSubject.iInnerSkull).FileName;
headmodel_options.InnerSkullFile = InnerSkullFile;
% Uploading cortex
CortexFile                      = sSubject.Surface(sSubject.iCortex).FileName;
headmodel_options.CortexFile    = CortexFile;

headmodel_options.GridOptions = [];
headmodel_options.GridLoc  = [];
headmodel_options.GridOrient  = [];
headmodel_options.GridAtlas  = [];
headmodel_options.Interactive  = true;
headmodel_options.SaveFile  = true;

if(isequal(modality,'EEG'))    
    headmodel_options.Comment = 'OpenMEEG BEM';     
    headmodel_options.MegRefCoef = [];
    headmodel_options.MEGMethod = '';
    headmodel_options.EEGMethod = 'openmeeg';    
    BSTScalpFile = bst_fullfile(ProtocolInfo.SUBJECTS, ScalpFile);
    BSTOuterSkullFile = bst_fullfile(ProtocolInfo.SUBJECTS, OuterSkullFile);
    BSTInnerSkullFile = bst_fullfile(ProtocolInfo.SUBJECTS, InnerSkullFile);
    headmodel_options.BemFiles = {BSTScalpFile, BSTOuterSkullFile,BSTInnerSkullFile};
    headmodel_options.BemNames = {'Scalp','Skull','Brain'};
    headmodel_options.BemCond = [1,0.0125,1];
    headmodel_options.iMeg = [];
    headmodel_options.iEeg = 1:length(BSTChannels.Channel);
    headmodel_options.iEcog = [];
    headmodel_options.iSeeg = [];
    headmodel_options.BemSelect = [true,true,true];
    headmodel_options.isAdjoint = false;
    headmodel_options.isAdaptative = true;
    headmodel_options.isSplit = false;
    headmodel_options.SplitLength = 4000;
else    
    headmodel_options.Comment = 'Overlapping spheres'; % for EEG 'OpenMEEG BEM'   
    headmodel_options.MegRefCoef = BSTChannels.MegRefCoef;
    headmodel_options.MEGMethod = 'os_meg'; %openmeg
    headmodel_options.EEGMethod = ''; 
    headmodel_options.OuterSkullFile =  [];
end
end

