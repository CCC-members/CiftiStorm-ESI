function [EEG, command] = pop_load_plg(varargin)

command = '';
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
% Read PLG
[pat_info inf_info plg_info mrk_info win_info cdc_info] = plg2matlab(fullfile(pathname, filename));
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
% Read channels
for it2 = 1:inf_info.PLGNC
    elecname = inf_info.PLGMontage{it2};
    if (elecname(3) == '_')
        EEG.chanlocs(it2).labels = elecname(1:2);
    else
        EEG.chanlocs(it2).labels = elecname;
    end
end
% Select type of analysis
if (nargin == 0)
    n_answer = input(['\nSelect (1, 2, or 3): \n1.- EEG quantitative analysis ' ...
        '\n2.- EEG continuous quantitative analysis ' ...
        '\n3.- Evoked Potential analysis (import events) ' ...
        '\n4.- Evoked Potential analysis (import selected windows)\nopcion: ']);
else
    n_answer = varargin{2};
end
switch (n_answer)
    case 1 % EEG quantitative analysis
        disp('Introduce state mark for selecting window segments');
        disp('From ''A'' to ''L'' for quantitative analysis');
        cstate = input('state for selecting segments? ');
        long_ventana = input('long selected for EEG window? ');
        data = select_state(data, win_info, cstate, long_ventana);
        EEG.setname = 'Epoched PLG Data';
        EEG.filename = '';
        EEG.filepath = '';
        EEG.pnts = size(data, 2);
        EEG.nbchan = inf_info.PLGNC;
        EEG.trials = size(data, 3);
        EEG.srate = inf_info.PLGSR;
        EEG.xmin = 0;
        EEG.xmax = EEG.xmin+(EEG.pnts-1)*(1/EEG.srate);
        EEG.data = data;
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
        EEG.times = (EEG.pnts/EEG.srate)*(0:EEG.pnts-1);
        EEG.specdata = [];
        EEG.specicaact = [];
        % some data processing
        EEG = pop_rmbase(EEG, 1000*[EEG.xmin EEG.xmax]);
    case {2, 3, 4}
        EEG.filename = '';
        EEG.filepath = '';
        EEG.nbchan = inf_info.PLGNC;
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
        if (n_answer == 2)
            % EEG continuous quantitative analysis
            EEG.setname = 'Continuous EEG';
            EEG.pnts = size(data, 2);
            EEG.trials = 1;
            EEG.xmin = 0;
            EEG.xmax = EEG.xmin+(EEG.pnts-1)*(1/EEG.srate);
            EEG.data = data;
            EEG.times = (0:EEG.pnts-1)/EEG.srate.*1000;
        elseif (n_answer == 3)
            % Continuous ERP analysis
            EEG.setname = 'Continuous EP Data';
            EEG.pnts = size(data, 2);
            EEG.trials = 1;
            EEG.xmin = 0;
            EEG.xmax = EEG.xmin+(EEG.pnts-1)*(1/EEG.srate);
            EEG.data = data;
            EEG.times = (0:EEG.pnts-1)/EEG.srate.*1000;
            n_event = mrk_info.n;
            for it = 1:n_event
                if (mrk_info.code(it) == 2)
                    EEG.event(it).type = 'Interrupcion-2';
                elseif (mrk_info.code(it) == 65)
                    EEG.event(it).type = 'A-65';
                elseif (mrk_info.code(it) == 5)
                    EEG.event(it).type = 'Contexto-5';
                elseif (mrk_info.code(it) == 6)
                    EEG.event(it).type = 'Resp.Correcta-6';
                elseif (mrk_info.code(it) == 7)
                    EEG.event(it).type = 'Resp.Incorrecta-7';
                elseif (mrk_info.code(it) == 9)
                    EEG.event(it).type = 'Aviso-9';
                elseif (mrk_info.code(it) == 10)
                    EEG.event(it).type = 'Aviso.Respuesta-10';
                elseif (mrk_info.code(it) == 11)
                    EEG.event(it).type = 'NoRespuesta-11';
                elseif (mrk_info.code(it) >= 128)
                    sfield = ['f' num2str(mrk_info.code(it)) 'MInfo'];
                    if isfield(inf_info, sfield)
                        EEG.event(it).type = inf_info.(sfield){1};
                    else
                        EEG.event(it).type = ['E-' num2str(mrk_info.code(it))];
                    end
                else
                    error('code unexpected');
                end
                
                % moverse al instante de tiempo (ms) en que ocurre el evento
                it_ms = EEG.xmin + (mrk_info.pos(it)-1)/EEG.srate;

                EEG.event(it).position = [];
                EEG.event(it).latency = mrk_info.pos(it);
                EEG.event(it).urevent = it;

                EEG.urevent(it).type = EEG.event(it).type;
                EEG.urevent(it).position = EEG.event(it).position;
                EEG.urevent(it).latency = EEG.event(it).latency;
            end
        else
            % Epoched ERP
            EEG.setname = 'Windowed EP Data';
            % number of selected windows
            EEG.trials = win_info.n - length(find(win_info.code == 3));
            % length of selected windows
            indsel = find(win_info.code ~= 3); ind = indsel(1);
            EEG.pnts = win_info.end_arr(ind) - win_info.begin_arr(ind) + 1;
            % Removing non-selected windows 191108
            window_begin = win_info.begin_arr(indsel);
            window_end = win_info.end_arr(indsel);
            % Select EEG data for windows
            EEG.data = zeros(EEG.nbchan, EEG.pnts, EEG.trials);
            for it = 1:EEG.trials
                EEG.data(:, :, it) = data(:, window_begin(it):window_end(it));
            end
            % times for epoched data
            EEG.xmin = 0;
            EEG.xmax = EEG.xmin + (EEG.pnts-1)*(1/EEG.srate);
            EEG.times = (0:EEG.pnts-1)/EEG.srate.*1000;
            % Selection of corresponding events.
            nevent = 0;
            for it = 1:EEG.trials
                ind = find((mrk_info.pos >= window_begin(it)) & (mrk_info.pos <= window_end(it)));
                nbase = EEG.pnts*(it-1) - window_begin(it) + 1;
                for it_event = ind(:)'
                    nevent = nevent + 1;
                    if (mrk_info.code(it_event) == 2)
                        EEG.event(nevent).type = 'Interrupcion-2';
                    elseif (mrk_info.code(it_event) == 65)
                        EEG.event(nevent).type = 'A-65';
                    elseif (mrk_info.code(it_event) == 5)
                        EEG.event(nevent).type = 'Contexto-5';
                    elseif (mrk_info.code(it_event) == 6)
                        EEG.event(nevent).type = 'Resp.Correcta-6';
                    elseif (mrk_info.code(it_event) == 7)
                        EEG.event(nevent).type = 'Resp.Incorrecta-7';
                    elseif (mrk_info.code(it_event) == 9)
                        EEG.event(nevent).type = 'Aviso-9';
                    elseif (mrk_info.code(it_event) == 10)
                        EEG.event(nevent).type = 'Aviso.Respuesta-10';
                    elseif (mrk_info.code(it_event) == 11)
                        EEG.event(nevent).type = 'NoRespuesta-11';
                    elseif (mrk_info.code(it_event) >= 128)
                        sfield = ['f' num2str(mrk_info.code(it_event)) 'MInfo'];
                        if isfield(inf_info, sfield)
                            EEG.event(nevent).type = inf_info.(sfield){1};
                        else
                            EEG.event(nevent).type = ['E-' num2str(mrk_info.code(it_event))];
                        end
                    else
                        error('code unexpected');
                    end
                    EEG.event(nevent).latency = nbase + mrk_info.pos(it_event);
                    EEG.event(nevent).epoch = it;
                end
            end
        end
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
command = ['EEG = pop_load_plg(' '''' filename '''' ', ' '''' pathname '''' ');'];

return;