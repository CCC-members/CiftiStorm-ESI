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

MaQC_params = selected_data_set.manual_qc_params';


end

