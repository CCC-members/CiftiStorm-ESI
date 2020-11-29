function [Cdata_s, HeadModels] = filter_structural_result_by_preproc_data(labels, Cdata, HeadModels)
    for h=1:length(HeadModels)
        HeadModel = HeadModels(h);
        disp ("-->> Removing Channels  by preprocessed EEG");
        [Cdata_r,Ke] = remove_channels_and_leadfield_from_layout(labels,Cdata,HeadModel.Ke);
        disp ("-->> Sorting Channels and LeadField by preprocessed EEG");
        [Cdata_s,Ke] = sort_channels_and_leadfield_by_labels(labels,Cdata_r,Ke);
        HeadModels(h).Ke = Ke;
    end
end

