function cfs_create_db()
app.ciftistormDir = fullfile(getUserDir(),'.CiftiStorm');
if(~isfolder(app.ciftistormDir))
    mkdir(app.ciftistormDir);
end
%% Defaults
if(~isfolder(fullfile(app.ciftistormDir,'defaults')))
    mkdir(fullfile(app.ciftistormDir,'defaults'));
end
if(~isfolder(fullfile(app.ciftistormDir,'defaults','anatomy')))
    mkdir(fullfile(app.ciftistormDir,'defaults','anatomy'));
end
if(~isfolder(fullfile(app.ciftistormDir,'defaults','eeg')))
    mkdir(fullfile(app.ciftistormDir,'defaults','eeg'));
    mkdir(fullfile(app.ciftistormDir,'defaults','eeg','Colin27'));
    mkdir(fullfile(app.ciftistormDir,'defaults','eeg','ICBM152'));
    mkdir(fullfile(app.ciftistormDir,'defaults','eeg','NotAligned'));
end
if(~isfolder(fullfile(app.ciftistormDir,'defaults','meg')))
    mkdir(fullfile(app.ciftistormDir,'defaults','meg'));
end

%% Datasets
if(~isfolder(fullfile(app.ciftistormDir,'Datasets')))
    mkdir(fullfile(app.ciftistormDir,'Datasets'));
end
if(~isfile(fullfile(app.ciftistormDir,'Datasets','Datasets.json')))
    saveJSON([],fullfile(app.ciftistormDir,'Datasets','Datasets.json'));
end
end

