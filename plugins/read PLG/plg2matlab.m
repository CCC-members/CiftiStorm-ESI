function [pat_info, inf_info, plg_info, mrk_info, win_info, cdc_info, states_name] = plg2matlab(path_filename)



pat_info = [];
inf_info = [];
plg_info = [];
mrk_info = [];
win_info = [];
cdc_info = [];

% CHECKING INPUT
if (nargin == 0) || isempty(path_filename)
    [filename, pathname] = uigetfile('*.pat', 'Pick a .pat file info');
    if filename == 0, return; end;
    path_filename = fullfile(pathname, filename);
    clear pathname filename;
end
[pathname, filename] = fileparts(path_filename);
% pathname = [pathname '\'];

%% reading .pat
path_filename = fullfile(pathname, [filename '.pat']);
[sfield, s_igual, nval, value] = textread(path_filename,'%s%s%s%s');
ind = find(strcmp(sfield, 'Center'));
if ~isempty(ind), pat_info.Center = value{ind}; end
ind = find(strcmp(sfield, 'Name'));
if ~isempty(ind), pat_info.Name = value{ind}; end
ind = find(strcmp(sfield, 'Sex'));
if ~isempty(ind), pat_info.Sex = value{ind}; end
ind = find(strcmp(sfield, 'BirthDate'));
if ~isempty(ind), pat_info.BirthDate = value{ind}; end
ind = find(strcmp(sfield, 'Age'));
s_age = strrep(value{ind}, '_', '');
if ~isempty(ind), pat_info.Age = str2double(deblank(s_age)); end
ind = find(strcmp(sfield, 'RecordDate'));
if ~isempty(ind), pat_info.RecordDate = value{ind}; end
ind = find(strcmp(sfield, 'RecordTime'));
if ~isempty(ind), pat_info.RecordTime = value{ind}; end
ind = find(strcmp(sfield, 'Technician'));
if ~isempty(ind), pat_info.Technician = value{ind}; end
ind = find(strcmp(sfield, 'Status'));
if ~isempty(ind), pat_info.Status = value{ind}; end
ind = find(strcmp(sfield, 'RefPhysician'));
if ~isempty(ind), pat_info.RefPhysician = value{ind}; end
ind = find(strcmp(sfield, 'ClinicalData'));
if ~isempty(ind), pat_info.ClinicalData = value{ind}; end
ind = find(strcmp(sfield, 'Diagnosis'));
if ~isempty(ind), pat_info.Diagnosis = value{ind}; end
ind = find(strcmp(sfield, 'FinalDiagnosis'));
if ~isempty(ind), pat_info.FinalDiagnosis = value{ind}; end
ind = find(strcmp(sfield, 'Medication'));
if ~isempty(ind), pat_info.Medication = value{ind}; end
% keep pathname filename pat_info

%% reading .inf
path_filename = fullfile(pathname, [filename '.inf']);
if (exist(path_filename, 'file') == 2)
    fid = fopen(path_filename, 'r');
%     states_name = containers.Map;
    states_name = [];
    while ~feof(fid)
        npos = ftell(fid);
        sline = fgetl(fid);
        [sfield, sline] = strtok(sline);
        switch (sfield)
            case 'PLGNC'
                [temp1, temp2, n_electrodo] = strread(sline ,'%s%s%d');
                inf_info.PLGNC = n_electrodo;
            case 'PLGNS'
                [temp1, temp2, n_rafaga] = strread(sline ,'%s%s%d');
                inf_info.PLGNS = n_rafaga;
            case 'PLGSR(Hz)'
                [temp1, temp2, n_freq] = strread(sline ,'%s%s%f');
                inf_info.PLGSR = n_freq;
            case 'PLGMontage'
                [temp1, sline] = strtok(sline);
                [temp2, slist_elec] = strtok(sline);
                slist_elec = deblank(slist_elec);
                it_elec = 0;
                while (it_elec < n_electrodo)
                    if isempty(slist_elec)
                        slist_elec = deblank(fgetl(fid));
                    end
                    [temp1, temp2] = strread(slist_elec, '%s%s', 'delimiter', '- ');
                    inf_info.PLGREF = temp2(1,:);
                    slist_elec = [];
                    n_temp = size(temp1, 1);
                    selectrodo((it_elec+1):(it_elec+n_temp), :) = temp1;
                    it_elec = it_elec + n_temp;
                end
                inf_info.PLGMontage = strrep(selectrodo,'_','');
            case 'PLGAmp(McV)'
                [temp1, slist] = strtok(sline);
                [temp2, slist] = strtok(slist);
                slist = deblank(slist);
                itc = 0;
                while (itc < n_electrodo)
                    if isempty(slist)
                        slist = deblank(fgetl(fid));
                    end
                    temp = strread(slist, '%s', 'delimiter', ' ');
                    slist = [];
                    ntemp = size(temp, 1);
                    PLGAmp((itc+1):(itc+ntemp), :) = temp;
                    itc = itc + ntemp;
                end
                inf_info.PLGAmp = str2num(char(PLGAmp));
            case 'Gains'
                [temp1, slist] = strtok(sline);
                [temp2, slist] = strtok(slist);
                slist = deblank(slist);
                itc = 0;
                while (itc < n_electrodo)
                    if isempty(slist)
                        slist = deblank(fgetl(fid));
                    end
                    temp = strread(slist, '%s', 'delimiter', ' ');
                    slist = [];
                    ntemp = size(temp, 1);
                    Gains((itc+1):(itc+ntemp), :) = temp;
                    itc = itc + ntemp;
                end
                inf_info.Gains = str2num(char(Gains));
            case 'ValidEEG'
                [temp1, slist] = strtok(sline);
                [temp2, slist] = strtok(slist);
                slist = deblank(slist);
                itc = 0;
                while (itc < n_electrodo)
                    if isempty(slist)
                        slist = deblank(fgetl(fid));
                    end
                    temp = strread(slist, '%s', 'delimiter', ' ');
                    slist = [];
                    ntemp = size(temp, 1);
                    ValidEEG((itc+1):(itc+ntemp), :) = temp;
                    itc = itc + ntemp;
                end
                inf_info.ValidEEG = ValidEEG;
            case 'LCut(Hz)'
                [temp1, slist] = strtok(sline);
                [temp2, slist] = strtok(slist);
                slist = deblank(slist);
                itc = 0;
                while (itc < n_electrodo)
                    if isempty(slist)
                        slist = deblank(fgetl(fid));
                    end
                    temp = strread(slist, '%s', 'delimiter', ' ');
                    slist = [];
                    ntemp = size(temp, 1);
                    LCut((itc+1):(itc+ntemp), :) = temp;
                    itc = itc + ntemp;
                end
                inf_info.LCut = str2num(char(LCut));
            case 'HCut(Hz)'
                [temp1, slist] = strtok(sline);
                [temp2, slist] = strtok(slist);
                slist = deblank(slist);
                itc = 0;
                while (itc < n_electrodo)
                    if isempty(slist)
                        slist = deblank(fgetl(fid));
                    end
                    temp = strread(slist, '%s', 'delimiter', ' ');
                    slist = [];
                    ntemp = size(temp, 1);
                    HCut((itc+1):(itc+ntemp), :) = temp;
                    itc = itc + ntemp;
                end
                inf_info.HCut = str2num(char(HCut));
            otherwise
                if (length(sfield) == 7) && ~isempty(regexp(sfield, '.-MInfo', 'once'))
                    [temp1, temp2, value] = strread(sline ,'%s%s%s');
                    %sfield = ['f' strrep(sfield, '-', '')];
                    
                    %states_name(sfield(1)) = value;
                    states_name = [states_name ; {sfield(1) value{1} } ];
                    
                    %inf_info.(sfield) = value;
                elseif (length(sfield) == 7) && strcmp(sfield(2:end), '-MInfo')
                    npos2 = ftell(fid);
                    fseek(fid, npos, 'bof');
                    sfield = fread(fid, 1, 'uint8');
                    fseek(fid, npos2, 'bof');
                    [temp1, temp2, value] = strread(sline ,'%s%s%s');
                    %sfield = ['f' num2str(sfield) 'MInfo'];                    
                    %inf_info.(sfield) = value;
                     states_name = [states_name ; {num2str(sfield) value{1}} ];
                    %states_name(num2str(sfield)) = value;
                end
        end
    end
    fclose(fid);
else
    warning(['file ' path_filename ' doesn''t exist']);
end
% keep pathname filename pat_info inf_info

%% reading .plg
path_filename = fullfile(pathname, [filename '.plg']);
if (exist(path_filename, 'file') == 2)
    fid = fopen(path_filename, 'r');
    data = fread(fid, [inf_info.PLGNC inf_info.PLGNS], 'int16');
    fclose(fid);
    plg_info.data = data;
else
    warning(['file ' path_filename ' doesn''t exist']);
end
% keep pathname filename pat_info inf_info plg_info

%% reading .mrk
path_filename = fullfile(pathname, [filename '.mrk']);
if (exist(path_filename, 'file') == 2 & ~isempty(states_name))
    fid = fopen(path_filename, 'r');    
    nmrk_data = 0;
    while ~feof(fid)
        try
            code = fread(fid, 1, '*char');% char
            pos = fread(fid, 1, 'int32');
            if ~isempty( find(strcmp(states_name(:,1), code) ) )
                nmrk_data = nmrk_data + 1;
                mrk_code(nmrk_data) =  states_name(find(strcmp(states_name(:,1), code) ),2);
                mrk_pos(nmrk_data) = pos;                             
            end
            n_pos = ftell(fid);  
            kk = fread(fid, 1, 'char');
            if isempty(kk)
                break;
            else
                fseek(fid, n_pos, 'bof');
            end
        catch
            break;
        end;
    end
    fclose(fid);
    if exist('mrk_code','var')
        mrk_info.code = mrk_code(:);
        mrk_info.pos = mrk_pos(:);
        
    end
    mrk_info.n = nmrk_data;
else
    warning(['file ' path_filename ' doesn''t exist']);
end
% keep pathname filename pat_info inf_info plg_info mrk_info

%% reading .win
path_filename = fullfile(pathname, [filename '.win']);
if (exist(path_filename, 'file') == 2  & ~isempty(states_name))
    fid = fopen(path_filename, 'r');
    nwin_data = 0;
    while ~feof(fid)
        try
            code =  fread(fid, 1, '*char'); % char
            begin =  fread(fid, 1, 'int32');
            ender =  fread(fid, 1, 'int32');
            if ~isempty( find(strcmp(states_name(:,1), code) ) )
                nwin_data = nwin_data + 1;
                win_code(nwin_data) = states_name(find(strcmp(states_name(:,1), code) ),2);
                win_begin(nwin_data) = begin;
                win_end(nwin_data) = ender;
            end
            kk = [];
            while isempty(kk)
                n_pos = ftell(fid);
                kk = fread(fid, 1, 'char');
                if feof(fid)
                    n_pos = -1;
                    break;
                end
            end
            if (n_pos > 0)
                fseek(fid, n_pos, 'bof');
            end
        catch
            break;
        end;
    end
    fclose(fid);
    if exist('win_code','var')
        win_info.code = win_code(:);
        win_info.begin_arr = win_begin(:);
        win_info.end_arr = win_end(:);
       
    end
     win_info.n = nwin_data;
else
    warning(['file ' path_filename ' doesn''t exist']);
end
% keep pathname filename pat_info inf_info plg_info mrk_info win_info

%% reading .cdc
path_filename = fullfile(pathname, [filename '.cdc']);
if (exist(path_filename, 'file') == 2)
    fid = fopen(path_filename, 'r');
    cdc_data = fread(fid, [2, inf_info.PLGNC], 'float32')';
    fclose(fid);
    cdc_info.data = cdc_data;
else
    warning(['file ' path_filename ' doesn''t exist']);
end
% keep pathname filename pat_info inf_info plg_info mrk_info win_info cdc_info

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% post-reading processing

% Transforming EEG activities contained in .plg file with calibration value
% and DC value for each channel.
plg_info.data = (spdiags(cdc_info.data(:, 1), 0, inf_info.PLGNC, ...
         inf_info.PLGNC)*plg_info.data - repmat(cdc_info.data(:, 2), 1, inf_info.PLGNS))/10;
return;