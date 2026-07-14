function rootDir = setup_v05_paths()
%SETUP_V05_PATHS Configure the controlled v0.5/v0.6/v0.7/v0.8 MATLAB path.
%
% This script intentionally avoids genpath(rootDir), because that could add:
%   - 99_legacy_do_not_run
%   - 00_original_zip_no_tocar
%   - historical conflicting scripts
%
% DATA-B-001:
%   03_original_model/04_data_original is explicitly added.
%   v0.8 also includes opt_tunel_mod2_v06_data_controlled.m, which loads
%   environmental data through load_environmental_data_original().
%
% Usage:
%   rootDir = setup_v05_paths();

    rootDir = fileparts(fileparts(fileparts(mfilename("fullpath"))));

    restoredefaultpath;
    rehash toolboxcache;

    addpath(fullfile(rootDir,'02_src_limpio','wrappers'));
    addpath(fullfile(rootDir,'03_original_model','01_active_original'));
    addpath(fullfile(rootDir,'03_original_model','02_psychrometrics'));
    addpath(fullfile(rootDir,'03_original_model','03_utilities'));
    addpath(fullfile(rootDir,'03_original_model','04_data_original'));

    addpath(fullfile(rootDir,'02_src_limpio','validation'));
    addpath(fullfile(rootDir,'02_src_limpio','config'));
    addpath(fullfile(rootDir,'02_src_limpio','cost'));
    addpath(fullfile(rootDir,'02_src_limpio','audit'));
    addpath(fullfile(rootDir,'02_src_limpio','main'));
    addpath(fullfile(rootDir,'02_src_limpio','results'));
    addpath(fullfile(rootDir,'02_src_limpio','ga'));

    rehash toolboxcache;
end
