% Script to draw a single pair of (U0, X0) and (U, X) results.

% Yanzhou Wang
% May 19 2025

% Example:
% ============= Plastisol ================
% load("./data/plastisol/plan_result_30_-5_8.mat")
% load("./data/plastisol/exec_result_30_-5_8.mat")
% param = load_experiment_param("plastisol");
% series_names = {"Planning", "Tracking"};
% tissue_names = {"Layer 1", "Layer 2"};
% single_result_draw(U0s, X0s, Us, Xs, param, series_names, tissue_names, 'Xd', [30; -5]);

% ========== Chicken Breast ==============
load("./data/chicken_breast/plan_result_40_-5_8.mat")
load("./data/chicken_breast/exec_result_40_-5_8.mat")
param = load_experiment_param("chicken");
series_names = {"Planning", "Tracking"};
tissue_names = "Chicken Breast";
single_result_draw(U0s, X0s, Us, Xs, param, series_names, tissue_names, 'Xd', [40; -5]);

% ================ End ===================
