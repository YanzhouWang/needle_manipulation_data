% Script to demonstrate planning for manipulation and pseudo-kinematic
% models. The figure is used in the manuscript.

% Yanzhou Wang
% Jan 29 2025

%% Load plan and plot
close all
steering_plan = load('steering_plan.mat');
manipulation_plan = load('manipulation_plan.mat');
series_names = {'Steering', 'Manipulation'};
tissue_names = [];
obs = steering_plan.obs;

target = steering_plan.target;
plan_params = init_fem_comp_params();

single_result_draw(...
    steering_plan.U0s, ...
    steering_plan.X0s, ...
    manipulation_plan.U0s, ...
    manipulation_plan.X0s, plan_params, series_names, tissue_names, ...
    'Xd', target, 'obs', obs);

print(gcf, 'two_plans.png', '-dpng', '-r600')
