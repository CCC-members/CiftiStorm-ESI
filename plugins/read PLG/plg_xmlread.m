function plg_info = plg_xmlread(plgfname)
[pp nn ee] = fileparts(plgfname);
fname = [pp filesep nn '.xnf'];
if ~exist(fname, 'file')
    plg_info = [];
    return
end

plg_info = xml_read(fname);
