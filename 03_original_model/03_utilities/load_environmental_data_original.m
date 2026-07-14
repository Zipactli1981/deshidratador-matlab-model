function data = load_environmental_data_original(filename)
%LOAD_ENVIRONMENTAL_DATA_ORIGINAL Load environmental data by project-relative path.
%
% DATA-B-001 strict closure helper.
%
% Replaces fragile calls such as:
%   data = load('Mapeo4_temp100621.txt');
%
% with:
%   data = load_environmental_data_original('Mapeo4_temp100621.txt');
%
% Data are loaded from:
%   <projectRoot>/03_original_model/04_data_original/<filename>
%
% This does not alter the data content.

    if nargin < 1 || strlength(string(filename)) == 0
        error("DATA-MISSING: filename is required.");
    end

    projectRoot = get_project_root_original();
    dataDir = fullfile(projectRoot, '03_original_model', '04_data_original');
    dataFile = fullfile(dataDir, char(filename));

    if ~isfile(dataFile)
        error('DATA-MISSING: No se encontró el archivo ambiental requerido: %s', dataFile);
    end

    data = load(dataFile);
end
