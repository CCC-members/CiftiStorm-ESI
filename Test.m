function Main(varargin)


if(isequal(nargin,2))
    idnode = varargin{1};
    count_node = varargin{2};
    if(~isnumeric(idnode) || ~isnumeric(count_node))
        fprintf(2,"\n ->> Error: The selected node and count of nodes have to be numbers \n");
        return;
    end
else
    idnode = 1;
    count_node = 1;
end
disp(strcat("-->> Working in node: ",num2str(idnode)));


subjects = dir(base_path);
subjects(ismember( {subjects.name}, {'.', '..'})) = [];  %remove . and ..
subjects_process_error = [];
subjects_processed =[];

sub_count = fix(length(subjects)/count_node);
start_ind = idnode * sub_count - sub_count + 1;
end_ind = idnode * sub_count;
if(start_ind>length(subjects))
    return;
end
if(end_ind>length(subjects) || idnode == count_node)
    end_ind = length(subjects);
end
subjects = subjects([start_ind:end_ind]);


end