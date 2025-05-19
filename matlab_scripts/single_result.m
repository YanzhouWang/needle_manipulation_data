% Function to plot the final result of a pair of (U0, X0) and (U, X),
% whether it being "Planning and Tracking" or "Steering and Manipulation"

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

% Yanzhou Wang
% May 19 2025

function single_result_draw(U0s, X0s, Us, Xs, params, series_names, tissue_names, varargin)
%% Options
% Keyword arguments and default values
options = struct('Xd', [], 'obs', []);
optionNames = fieldnames(options);

num_args = length(varargin);
if round(num_args/2)~=num_args/2
   error('EXAMPLE needs propertyName/propertyValue pairs')
end

for pair = reshape(varargin, 2, []) %# pair is {propName; propValue}
    input_name = pair{1}; %# make case insensitive

    if any(strcmp(input_name, optionNames))
        options.(input_name) = pair{2};
    else
        error('%s is not a recognized parameter name', input_name)
    end
end

%% Setup
fh = figure;
tiledlayout(2, 3);
X_LABEL = "Depth (mm)";
Nnodes = params.Nnodes;
target = options.Xd;
line_width = 1;
target_size = 1;
marker_size = 5;

%% Final shape
nexttile([1, 3])
hold on
plan_final_shape = [X0s(0*Nnodes + 1 : 1*Nnodes, end), ...
                    X0s(1*Nnodes + 1 : 2*Nnodes, end)];
exec_final_shape = [Xs(0*Nnodes + 1 : 1*Nnodes, end), ...
                    Xs(1*Nnodes + 1 : 2*Nnodes, end)];
plot(plan_final_shape(:, 1), plan_final_shape(:, 2), 'k:', ...
    'LineWidth', line_width, 'DisplayName', series_names{1});
plot(exec_final_shape(:, 1), exec_final_shape(:, 2), 'k-', ...
    'LineWidth', line_width, 'DisplayName', series_names{2});

[~, plan_G_element] = min(abs(plan_final_shape(:, 1) - params.guide_lcn));
[~, exec_G_element] = min(abs(exec_final_shape(:, 1) - params.guide_lcn));

plan_G_y = plan_final_shape(plan_G_element, 2);
exec_G_y = exec_final_shape(exec_G_element, 2);
plot(params.guide_lcn, plan_G_y, ...
    'k>', 'MarkerSize', marker_size,'DisplayName', [char(series_names{1}), ' G'])
plot(params.guide_lcn, exec_G_y, ...
    'k>', 'MarkerFaceColor', 'k', 'MarkerSize', marker_size, 'DisplayName', [char(series_names{2}), ' G'])
plot(target(1), target(2), 'k+', ...
    'MarkerSize', target_size, 'LineWidth', 3, 'DisplayName', 'Target');
axis tight
x_lim = xlim();

% Tissue patches
interval = params.interval;
num_inter = size(interval, 1);
tissue_colors_hex = {'E2B8AA', 'FFF2C2', 'F0EDEB', 'F4DEA9', 'C35F72', 'C6BEB5'};
tissue_colors_rbg = hex2rgb(tissue_colors_hex);
cmap = colormap(tissue_colors_rbg);
Py_Lims = get(gca, 'YLim');
Py_offset = 1;
Ps = [];
for j = 1:num_inter
    if isempty(tissue_names)
        display_name = ['Tissue ', num2str(j)];
    else
        display_name = tissue_names{j};
    end
    Px = [interval{j}(1), interval{j}(2), interval{j}(2), interval{j}(1)];
    Py = [Py_Lims(1) - Py_offset, Py_Lims(1) - Py_offset, Py_Lims(2) + Py_offset, Py_Lims(2) + Py_offset];
    Ps = [Ps, patch(Px, Py, cmap(j, :), 'FaceAlpha', 1, 'DisplayName', display_name)];
end
h = get(gca, 'Children');
set(gca, 'Children', [h(num_inter + 1:end); h(1:num_inter)])
xlim([x_lim(1) - 2, x_lim(2) + 2]);

% Obstacles
if ~isempty(options.obs)
    num_obs = size(options.obs, 1);
    % centers = zeros(num_obs, 2);
    % radii = zeros(num_obs, 1);
    clr = 'k';
    for i = 1:num_obs
        % centers(i, :) = options.obs(i).center';
        % radii(i) = options.obs(i).radius;
        c = options.obs(i).center';
        r = options.obs(i).radius;
        pos = [c - r, 2*r, 2*r];
        rectangle('Position', pos, 'Curvature', [1, 1], ...
            'FaceColor', clr, 'EdgeColor', 'none');        
    end
    plot(nan, nan, 'Marker', 'o', 'MarkerFaceColor', clr, ...
        'MarkerEdgeColor', 'none', 'LineStyle', 'none', 'MarkerSize', marker_size, ...
        'DisplayName', 'Obstacle')
end

legend('show', 'Location', 'bestoutside', "Interpreter", 'latex')
xlabel(X_LABEL, "Interpreter", "latex");
ylabel('Position (mm)', "Interpreter", "latex");
title('Final Needle Shape', 'Interpreter', 'latex')

%% Target, Tip, and Tissue Patches
nexttile
hold on

plan_tip_states = [X0s(1*Nnodes, :); X0s(2*Nnodes, :)];
exec_tip_states = [Xs(1*Nnodes, :); Xs(2*Nnodes, :)];

y_offset = 1;
x_offset = 4;
y_max = max([plan_tip_states(2, :), exec_tip_states(2, :)]);
y_min = min([plan_tip_states(2, :), exec_tip_states(2, :)]);
x_max = max([plan_tip_states(1, :), exec_tip_states(1, :)]);
x_min = min([plan_tip_states(1, :), exec_tip_states(1, :)]);
ylim([y_min - y_offset, y_max + y_offset]);
xlim([x_min, x_max + x_offset]);

plot(plan_tip_states(1, :), smooth(plan_tip_states(2, :)), ...
    'k:', 'LineWidth', line_width, 'DisplayName', series_names{1});
plot(exec_tip_states(1, :), smooth(exec_tip_states(2, :)), ...
    'k-', 'LineWidth', line_width, 'DisplayName', series_names{2});
plot(target(1), target(2), 'k+', ...
    'MarkerSize', target_size, 'LineWidth', 3, 'DisplayName', 'Target');

% Tissue patches
interval = params.interval;
num_inter = size(interval, 1);

Py_Lims = get(gca, 'YLim');
Py_offset = 0;
Ps = [];
for j = 1:num_inter
    Px = [interval{j}(1), interval{j}(2), interval{j}(2), interval{j}(1)];
    Py = [Py_Lims(1) - Py_offset, Py_Lims(1) - Py_offset, Py_Lims(2) + Py_offset, Py_Lims(2) + Py_offset];
    Ps = [Ps, patch(Px, Py, cmap(j, :), 'FaceAlpha', 1, 'HandleVisibility', 'off')];
end
h = get(gca, 'Children');
set(gca, 'Children', h(:))
hold off
xlabel(X_LABEL, "Interpreter", "latex");
ylabel("Position (mm)", "Interpreter", "latex");
title('Needle Tip Path', 'Interpreter', 'latex')

%% Controls | Guide Position
nexttile
hold on
plan_xs = X0s(0*Nnodes + 1 : 1*Nnodes, :);
plan_ys = X0s(1*Nnodes + 1 : 2*Nnodes, :);
[~, guide_elem] = min(abs(plan_xs - params.guide_lcn), [], 1);
plan_guide_pos = zeros(1, size(plan_ys, 2));
for i = 1:size(plan_ys, 2)
    plan_guide_pos(i) = plan_ys(guide_elem(i), i);
end

exec_xs = Xs(0*Nnodes + 1 : 1*Nnodes, :);
exec_ys = Xs(1*Nnodes + 1 : 2*Nnodes, :);
[~, guide_elem] = min(abs(exec_xs - params.guide_lcn), [], 1);
exec_guide_pos = zeros(1, size(exec_ys, 2));
for i = 1:size(exec_ys, 2)
    exec_guide_pos(i) = exec_ys(guide_elem(i), i);
end

plot(plan_tip_states(1, 1:end), smooth(plan_guide_pos), 'k:', ...
    'LineWidth', line_width, 'DisplayName', series_names{1})
plot(exec_tip_states(1, 1:end), smooth(exec_guide_pos), 'k-', ...
    'LineWidth', line_width, 'DisplayName', series_names{2})

hold off
xlim([x_min, x_max + x_offset]);
xlabel(X_LABEL, "Interpreter", "latex");
ylabel("Position (mm)", "Interpreter", "latex")
title('Needle Guide Path', 'Interpreter', 'latex')

%% Bevel direction
nexttile
hold on
stairs(plan_tip_states(1, :), X0s(end - 1, :), 'k:', ...
    'LineWidth', line_width, 'DisplayName', series_names{1});
stairs(exec_tip_states(1, :), Xs(end - 1, :), 'k-', ...
    'LineWidth', line_width, 'DisplayName', series_names{2});
ylim([-1.2, 1.2])
xlim([x_min, x_max + x_offset]);
set(gca, 'ytick', [-1, 1])
hold off
xlabel(X_LABEL, "Interpreter", "latex")
ylabel("Bevel Direction", "Interpreter", "latex")
title('Needle Bevel Direction', 'Interpreter', 'latex')

%% Page Setup
set(gcf, 'Color', 'w')
fontsize(fh, 8, 'points')
fontname(fh, 'Times New Roman');

w = 1800; h = 500;
fig_pos = get(gcf, 'Position');
set(fh, 'Position', [fig_pos(1), fig_pos(2), w, h]);
paperw = 7.16; paperh = paperw*h/w;
set(fh, 'PaperUnits', 'inches')
set(fh, 'PaperPosition', [0, 0, paperw, paperh])

% export
print(gcf, 'single_result.png', '-dpng', '-r600')
end

function rgb = hex2rgb(hex_cell)
n = length(hex_cell);
rgb = zeros(n, 3);
for i = 1:n
    hex = hex_cell{i};
   rgb(i, :) = reshape(sscanf(hex.','%2x'),3,[]).'/255;
end
end