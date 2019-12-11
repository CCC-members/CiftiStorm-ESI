function [hdr, data] = import_eeg_format(eeg_file,format)
if(isequal(format,'edf'))
   [hdr, data]= edfread(eeg_file);
end

end

