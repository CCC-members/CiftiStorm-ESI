function  options = get_headmodeler_options(modality, subID, iStudy)
%GET_HEADMODELER_OPTIONS Summary of this function goes here
%   Detailed explanation goes here

%%
%% Get Protocol information
%%
ProtocolInfo                = bst_get('ProtocolInfo');
% Get subject directory
[sSubject]                  = bst_get('Subject', subID);

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
options.Radii               = [0.88,0.93,1];
options.Conductivity        = [0.33,0.0042,0.33];
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

if(isequal(modality,'EEG'))
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
end

