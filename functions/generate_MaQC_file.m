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
    
    MRI_Segmentation = logical.empty(length(subjects));
    Scalp_registration= logical.empty(length(subjects));
    Cortex_registration = logical.empty(length(subjects));
    OuterSkull_registration = logical.empty(length(subjects));
    InnerSkull_registration = logical.empty(length(subjects));
    Cortex = logical.empty(length(subjects));
    BEM_surfaces_registration = logical.empty(length(subjects));
    SPM_Scalp_Envelope = logical.empty(length(subjects));
    Sensor_Projection = logical.empty(length(subjects));
    Field_views = logical.empty(length(subjects));
        
    T = table(MRI_Segmentation,Scalp_registration,Cortex_registration,OuterSkull_registration,...
        InnerSkull_registration,Cortex,BEM_surfaces_registration,...
        SPM_Scalp_Envelope,Sensor_Projection,Field_views,...
        'RowNames',subjects);
   
    writetable(T,file_name,'Sheet','Report')
end

end

