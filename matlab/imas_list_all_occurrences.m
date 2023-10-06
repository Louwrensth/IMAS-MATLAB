% imas_list_all_occurrences (idx, ids_name, node_path)
%
%  List all non-empty occurrences of IDSname in the dataset, and optionnally return the content of a descriptive node path in MATLAB External Interfaces 
%
% Args:
%   idx  : database index, returned by imas_open/imas_create.
%   ids_name  : name of the IDS
%   node_path  : DD path of a string node 
%
% Returns:
%   list of occurrences if the data entry (idx)
%   list of the contents of the node_path for each occurrence found if node_path is specified, otherwise returns an empty list
