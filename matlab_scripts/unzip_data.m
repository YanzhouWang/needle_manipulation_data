function unzip_data()
% Function to unzip 'experiment_results.zip' to 'data' folder

% Yanzhou Wang
% May 19 2025

archive = '../experiment_results.zip';
data_folder = 'data';
if ~exist(data_folder, 'dir')
    mkdir(data_folder)
end
unzip(archive, data_folder);