function  vers =  eegplugin_readPLG( fig, try_strings, catch_strings )

vers = 'qEEG1.0'; 

if nargin < 3
    error('eegplugin_fmrib requires 3 arguments');
end;

impmenu = findobj(fig, 'tag', 'import data'); 
submenu = uimenu( impmenu, 'label', 'Read PLG');

cmd = ['[EEG LASTCOM] = readplot_plg();'];
finalcmd = [try_strings.no_check cmd catch_strings.new_and_hist];

uimenu( submenu, 'label', 'Read PLG', 'callback', finalcmd);

end

