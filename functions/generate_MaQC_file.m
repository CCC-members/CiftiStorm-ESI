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
    MaQC_file = fullfile(protocol_report_path,[ProtocolName,'_MaQC3.xlsx']);    
    MaQC_template_file = strcat('tools',filesep,'Template_MaQC.xlsx');
    copyfile( MaQC_template_file , MaQC_file);
      
    Subject_ID = subjects;    
    T = table(Subject_ID,'RowNames',subjects);
    for p = 1 : size(MaQC_params,1)        
         param = string(MaQC_params(p));
         param = strrep(param,' ','_');
         colum = cell(size(Subject_ID,1),1);
         T = [T table(colum, 'VariableNames', {char(param)})];        
    end
    %% Deleting rows
%     subjects_count = size(Subject_ID,1);   
%     rows_count = selected_data_set.protocol_subjet_count; 
%     Excel = actxserver('Excel.Application');
%     Workbook = Excel.Workbooks.Open(MaQC_file);
%     sheet1=Excel.Worksheets.get('Item','Report');
%     for count = 1 : (rows_count - subjects_count)
%         sheet1.Rows.Item(4).Delete;
%     end
%     Workbook.Save;
%     Workbook.Close;
%     delete(Excel);
    
    %% 
    
    Excel = actxserver('Excel.Application');
    Workbook = Excel.Workbooks.Open(MaQC_file);
    NewSheet=Excel.Worksheets.get('Item','Report');
    for i = 2 : size(MaQC_params,1)
        NewSheet.Columns.Item(i).columnWidth = 50;
    end
    Excel.Workbook.Save;
    Excel.Workbook.Close;
    invoke(Excel, 'Quit');
    delete(Excel);
    
    xlswrite(MaQC_file, {ProtocolName}, 'Report', 'D7');     
    writetable(T,MaQC_file,'Sheet','Report','Range','B8');    

end

end

