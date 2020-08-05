function [hdr, data] = import_eeg_format(eeg_file,format)
if(isequal(format,'edf'))
   [hdr, data]= edfread(eeg_file);
end
if(isequal(format,'mat'))
   load(eeg_file);
   data = result.data;
   hdr.label  = {result.chanlocs.labels};
   hdr.label  = strrep(hdr.label,'Cz','E129');
end


end

