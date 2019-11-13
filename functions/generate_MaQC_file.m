function generate_MaQC_file()


% Geting correct protocol
ProtocolInfo = bst_get('ProtocolInfo');
ProtocolName = ProtocolInfo.Comment;

% Subjects list for current protocol
sSubjects = bst_get('ProtocolSubjects');
subjects = {sSubjects.Subject.Name}';

app_properties = jsondecode(fileread(strcat('app',filesep,'app_properties.json')));
app_protocols = jsondecode(fileread(strcat('app',filesep,'app_protocols.json')));
selected_data_set = app_protocols.(strcat('x',app_properties.selected_data_set.value));

MaQC_params = selected_data_set.manual_qc_params;

if(selected_data_set.report_output_path == "local")
    report_output_path = pwd;
else
    report_output_path = selected_data_set.report_output_path ;
end
protocol_report_path = fullfile(report_output_path,'Reports',ProtocolName);
if(isfolder(protocol_report_path))
    file_name = fullfile(protocol_report_path,[ProtocolName,'_MaQC.xlsx']);
    
    for i = 1 : length(MaQC_params)
        
    end
    Age = [38;43;38;40;49];
    Height = [71;69;64;67;64];
    Weight = [176;163;131;133;119];
    BloodPressure = [124 93; 109 77; 125 83; 117 75; 122 80];
    
    T = table(Age,Height,Weight,BloodPressure,...
        'RowNames',subjects);
    
    v1 = {'Protocol Name';ProtocolName};
    t = table(v1,v2,v3)
    v2 = MaQC_params;
    v3 = subjects;
    writetable(T,file_name,'Sheet','Report')
end

end

