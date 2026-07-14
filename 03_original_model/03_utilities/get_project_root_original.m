function projectRoot = get_project_root_original()
%GET_PROJECT_ROOT_ORIGINAL Return project root from original utilities folder.
%
% This utility is intentionally placed in:
%   03_original_model/03_utilities/
%
% It assumes the v0.6 package structure:
%   <projectRoot>/03_original_model/03_utilities/get_project_root_original.m

    thisFile = mfilename("fullpath");
    utilitiesDir = fileparts(thisFile);
    originalModelDir = fileparts(utilitiesDir);
    projectRoot = fileparts(originalModelDir);
end
