function [hdr, data] = import_eeg_format(base_path,format)
if(isequal(format,'edf'))
    [hdr, data]= edfread(base_path);
end
if(isequal(format,'plg'))
    [pat_info, inf_info, plg_info, mrk_info, win_info, cdc_info, states_name] = plg2matlab(base_path);
    % creating output structure
    data = plg_info.data;
    
    hdr.pat_info = pat_info;
    hdr.inf_info = inf_info;
    hdr.mrk_info = mrk_info;
    hdr.win_info = win_info;
    hdr.cdc_info = cdc_info;
    hdr.states_name = states_name;
    hdr.label = inf_info.PLGMontage;
end
% cleanning lables
hdr.label = strrep(hdr.label,'REF','');

end
