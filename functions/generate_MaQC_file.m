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
    
    % Copying the template MaQC file to protocol report path
    MaQC_file = fullfile(protocol_report_path,[ProtocolName,'_MaQC.xlsx']);    
    MaQC_template_file = strcat('tools',filesep,'Template_MaQC.xlsx');
    copyfile( MaQC_template_file , MaQC_file);
      
    Subject_ID = subjects;
    MRI_Segmentation = cell(size(Subject_ID,1),1);
    Scalp_registration= cell(size(Subject_ID,1),1);
    Cortex_registration = cell(size(Subject_ID,1),1);
    OuterSkull_registration = cell(size(Subject_ID,1),1);
    InnerSkull_registration = cell(size(Subject_ID,1),1);
    Cortex = cell(size(Subject_ID,1),1);
    BEM_surfaces_registration = cell(size(Subject_ID,1),1);
    SPM_Scalp_Envelope = cell(size(Subject_ID,1),1);
    Sensor_Projection = cell(size(Subject_ID,1),1);
    Field_views = cell(size(Subject_ID,1),1);
 
    xlswrite(MaQC_file, {ProtocolName}, 'Report', 'D2');
    T = table(Subject_ID,MRI_Segmentation,Scalp_registration,Cortex_registration,OuterSkull_registration,...
        InnerSkull_registration,Cortex,BEM_surfaces_registration,...
        SPM_Scalp_Envelope,Sensor_Projection,Field_views,...
        'RowNames',subjects);       
    writetable(T,MaQC_file,'Sheet','Report','Range','B3');
end

end

