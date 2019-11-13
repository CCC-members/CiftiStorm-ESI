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
    
    MRI_Segmentation = 1:length(subjects);
    Scalp_registration= 1:length(subjects);
    Cortex_registration = 1:length(subjects);
    OuterSkull_registration = 1:length(subjects);
    InnerSkull_registration = 1:length(subjects);
    Cortex = 1:length(subjects);
    BEM_surfaces_registration = 1:length(subjects);
    SPM_Scalp_Envelope = 1:length(subjects);
    Sensor_Projection = 1:length(subjects);
    Field_views = 1:length(subjects);
        
    T = table(MRI_Segmentation,Scalp_registration,Cortex_registration,OuterSkull_registration,...
        InnerSkull_registration,Cortex,BEM_surfaces_registration,...
        SPM_Scalp_Envelope,Sensor_Projection,Field_views,...
        'RowNames',subjects);
   
    writetable(T,file_name,'Sheet','Report')
end

end

