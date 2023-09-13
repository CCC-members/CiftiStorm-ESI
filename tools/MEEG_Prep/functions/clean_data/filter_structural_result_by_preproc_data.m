function [Cdata_s, HeadModels] = filter_structural_result_by_preproc_data(labels, Cdata, HeadModels)
    for h=1:length(HeadModels)
        HeadModel = HeadModels(h);        
        disp ("-->> Removing Channels  by preprocessed EEG");
        [Cdata_r,Ke] = remove_channels_by_preproc_data(labels,Cdata,HeadModel.Gain);
        disp ("-->> Sorting Channels and LeadField by preprocessed EEG");
        [Cdata_s,Ke] = sort_channels_by_preproc_data(labels,Cdata_r,Ke);
        HeadModels(h).Gain = Ke;
    end
end

