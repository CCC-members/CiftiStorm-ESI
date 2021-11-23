function [EEG, command] = readplot_plg( varargin )
command = '[EEG LASTCOM] = readplot_plg();';
EEG = [];

if (nargin == 0)
    % reading file path
    [filename, pathname] = uigetfile('*.plg', 'Load a PLG-file');
    if filename == 0 return; end;

    [pathname, filename, extname] = fileparts(fullfile(pathname, filename));
else
    filename = varargin{1};
    [pathname, filename, extname] = fileparts(filename);
end
% pathname = [pathname '\'];
if(strcmp(extname,'xml'))
    [pat_info inf_info plg_info mrk_info win_info cdc_info states_name] = plg_read(fullfile(pathname, filename));
else
% Read PLG
    [pat_info inf_info plg_info mrk_info win_info cdc_info states_name] = plg2matlab(fullfile(pathname, filename));
end
data = plg_info.data;
% Check PLG data
if isempty(plg_info)
    error('The .plg file is mandatory');
end
if isempty(inf_info)
    error('The .inf file is mandatory');
end
if isempty(win_info)
    warning('The .win file is not provided.');
end


EEG.filename = '';
EEG.filepath = '';
EEG.locationpath = pathname;
EEG.srate = inf_info.PLGSR;
EEG.icawinv = [];
EEG.icasphere = [];
EEG.icaweights = [];
EEG.icaact = [];
EEG.event = [];
EEG.epoch = [];
EEG.comments = '';
EEG.ref = 'common';
EEG.history = '';
EEG.eventdescription = {};
EEG.epochdescription = {};
EEG.specdata = [];
EEG.specicaact = [];
if length(pat_info.Name) > 25
    len = 25;
else
    len = length(pat_info.Name);
end
EEG.setname = pat_info.Name(1:len);
EEG.pnts = size(data, 2);
EEG.trials = 1;
EEG.xmin = 0;
EEG.xmax = EEG.xmin+(EEG.pnts-1)*(1/EEG.srate);
EEG.data = data;
EEG.times = (0:EEG.pnts-1)/EEG.srate.*1000;  

%EEG.etc.mrk= mrk_info;
for it =1 : mrk_info.n
    if ~strcmp(mrk_info.code(it),' ')
        EEG.event(it).type = char(mrk_info.code(it));
        EEG.event(it).position = [];
        EEG.event(it).latency = mrk_info.pos(it);
        EEG.event(it).urevent = it;

        EEG.urevent(it).type = EEG.event(it).type;
        EEG.urevent(it).position = EEG.event(it).position;
        EEG.urevent(it).latency = EEG.event(it).latency;
    end
end


EEG.etc.inf.PLGAmp = inf_info.PLGAmp;
EEG.etc.inf.Gains = inf_info.Gains;
EEG.etc.inf.LCut = inf_info.LCut;
EEG.etc.inf.HCut = inf_info.HCut;
EEG.etc.inf.REF = inf_info.PLGREF;
try
    
EEG.etc.inf.ValidEEG = inf_info.ValidEEG;
ind = find(strcmp(EEG.etc.inf.ValidEEG,'ON')==1);
catch
    ind = (1:size(EEG.data,1));
end

EEG.etc.inf.states_name =states_name;
EEG.etc.cdc = cdc_info.data;
EEG.TW = load_states(win_info);

EEG.data = EEG.data(ind,:);
EEG.nbchan =size(EEG.data,1);
% Read channels
for it2 = 1:EEG.nbchan
    elecname = inf_info.PLGMontage{it2};
    EEG.chanlocs(it2).labels = elecname;    
end

% struct EEG.reject
EEG.reject.rejjp = [];
EEG.reject.rejjpE = [];
EEG.reject.rejkurt = [];
EEG.reject.rejkurtE = [];
EEG.reject.rejmanual = [];
EEG.reject.rejmanualE = [];
EEG.reject.rejthresh = [];
EEG.reject.rejthreshE = [];
EEG.reject.rejconst = [];
EEG.reject.rejconstE = [];
EEG.reject.rejfreq = [];
EEG.reject.rejfreqE = [];
EEG.reject.icarejjp = [];
EEG.reject.icarejjpE = [];
EEG.reject.icarejkurt = [];
EEG.reject.icarejkurtE = [];
EEG.reject.icarejmanual = [];
EEG.reject.icarejmanualE = [];
EEG.reject.icarejthresh = [];
EEG.reject.icarejthreshE = [];
EEG.reject.icarejconst = [];
EEG.reject.icarejconstE = [];
EEG.reject.icarejfreq = [];
EEG.reject.icarejfreqE = [];
EEG.reject.rejglobal = [];
EEG.reject.rejglobalE = [];
EEG.reject.rejmanualcol = [1 1 0.7830];
EEG.reject.rejthreshcol = [0.8487 1 0.5008];
EEG.reject.rejconstcol = [0.6940 1 0.7008];
EEG.reject.rejjpcol = [1 0.6991 0.7537];
EEG.reject.rejkurtcol = [0.6880 0.7042 1];
EEG.reject.rejfreqcol = [0.9596 0.7193 1];
EEG.reject.disprej = {};
EEG.reject.threshold = [0.8000 0.8000 0.8000];
EEG.reject.threshentropy = 600;
EEG.reject.threshkurtact = 600;
EEG.reject.threshkurtdist = 600;
EEG.reject.gcompreject = [];

% struct EEG.stats
EEG.stats.jp = [];
EEG.stats.jpE = [];
EEG.stats.icajp = [];
EEG.stats.icajpE = [];
EEG.stats.kurt = [];
EEG.stats.kurtE = [];
EEG.stats.icakurt = [];
EEG.stats.icakurtE = [];
EEG.stats.compenta = [];
EEG.stats.compentr = [];
EEG.stats.compkurta = [];
EEG.stats.compkurtr = [];
EEG.stats.compkurtdist = [];
command = ['EEG = readplot_plg(' '''' filename '''' ', ' '''' pathname '''' ');'];

end

