% Script to visualize targeting performance in em-only experiments.

% Yanzhou Wang
% May 19 2025

%% Loading
% Specifications need to match actual test performed

% ============= Plastisol ================
% TITLE = 'Plastisol Targeting Experiment';
% save_title = "plastisol";
% dir_prefix = 'data/plastisol/'; % gel phantom
% x_seq = 25:5:45; % plastisol phantom

% ========== Chicken Breast ==============
TITLE = 'Chicken Breast Targeting Experiment';
save_title = "chicken_breast";
dir_prefix = 'data/chicken_breast'; % chicken breast
x_seq = 25:5:50; % chicken breast

% ================ End ===================

y_seq = -5:5:5;
repeats = 10;
Nnodes = 51;

dir = [dir_prefix, '/'];

npos = length(x_seq)*length(y_seq);
% sequence of tip goals
goal_pos = zeros(npos, 2);
% sequence of tip goals in planning
plan_pos = zeros(npos, 2);
% means of repeated exec results at each goal
exec_means = zeros(npos, 2);
% stddev of repeated exec results at each goal
exec_sigmas = zeros(npos, 1);

pos_num = 0;
% iterate through every pos
allMeas = double.empty(0, 2);
for x_pos = x_seq
    for y_pos = y_seq
        pos_num = pos_num + 1;
        goal_pos(pos_num, 1) = x_pos;
        goal_pos(pos_num, 2) = y_pos;
        pos_str = [num2str(x_pos), '_', num2str(y_pos)];

        % plan
        filename_plan = [dir, 'plan_result_', pos_str, '_1.mat']; % just the first plan
        temp = load(filename_plan, 'X0s', 'U0s');
        X0s = temp.X0s;

        % record the pos of needle tip in the final planning step
        plan_pos(pos_num, :) = tip_pos(X0s, Nnodes);

        % exec
        measures = zeros(repeats, 2);
        for i = 1:repeats
            filename_exec = [dir, 'exec_result_', pos_str, '_', num2str(i), '.mat'];
            temp = load(filename_exec, 'Xs', 'Us');
            Xs = temp.Xs;
            measures(i, :) = tip_pos(Xs, Nnodes);
        end
        allMeas=[allMeas; measures];

        [exec_means(pos_num, :), exec_sigmas(pos_num)] = calc_means_sigmas(measures);
    end
end

res = [exec_means, exec_sigmas];

%% Reporting
exec_means = res(:, 1:2); % mean position
exec_sigmas = res(:, 3); % error stddev

exec_means_err = exec_means - goal_pos; % err pos
avg_err = 0;
avg_std = 0;
for i = 1:npos
    avg_err = avg_err + norm(exec_means_err(i, :));
    avg_std = avg_std + exec_sigmas(1);
end
avg_err = avg_err/npos;
avg_std = avg_std/npos;

fprintf('Avg error: %.2fmm | Avg std: %.2fmm\n', avg_err, avg_std)


%% Plotting
fh = figure;
alpha = 1;
colors = gray(1);

hold on
color = [colors, alpha];
scatter(allMeas(:, 1),allMeas(:, 2),'k.','SizeData',30, 'DisplayName', 'Tip')

displayname = sprintf('$$r = 1$$');

scatter_circles(...
    goal_pos(:, 1:2)', ...
    pi*ones(size(goal_pos,1),1), [1, 2], fh, color, displayname);

% Settings
axis equal tight
axis on
grid on
box off
set(gca, 'TickLength', [0 0]);

hold on
plot([x_seq(1)-2, x_seq(end)+2], [y_seq(1)-2, y_seq(1)-2], 'w-', 'LineWidth', 1); % Cover the X-axis
plot([x_seq(1)-2, x_seq(1)-2], [y_seq(1)-2, y_seq(end)+2], 'w-', 'LineWidth', 1); % Cover the Y-axis

X_lim = xlim;
Y_lim = ylim;
r = (X_lim(2) - X_lim(1))/(Y_lim(2) - Y_lim(1)); % get axis width/height

pos = get(gcf, 'Position');
width = pos(3);
height = pos(4);
set(gcf, 'Position', [pos(1), pos(2), height*r, height]); % set figure width/height

xlabel('Depth (mm)');
ylabel('Lateral Position (mm)');
title(TITLE, 'Interpreter', 'latex')
hold off
legend('off', 'Location', 'bestoutside', 'Interpreter', 'latex')

fontsize(fh, 8, 'points');
fontname(fh, 'Times New Roman');
set(gca, 'YTick', y_seq, 'XTick', x_seq)
set(gcf, 'Color', 'w')
set(gca,'GridAlpha',1)
ax.XAxis.TickLength = [0 0];

%% Saving
fig_pos = get(gcf, 'Position'); % [left, bottom, width, height]
w = fig_pos(3); h = fig_pos(4);

% paperw = 3.5; paperh = paperw*h/w; % Using 3.5in width
paperh = 2; paperw = paperh*w/h; % using 2in height

set(fh,'PaperUnits','inches')
set(gcf, 'PaperPosition', [0, 0, paperw, paperh]);  % [left, bottom, width, height]

print(gcf, sprintf('em_error_%s.png', save_title), '-dpng', '-r600')

%% Helper functions

% measurement on FEM
function meas = tip_pos(Xs, Nnodes)
% returns final position of needle tip, 1*2
x = Xs(Nnodes, end);
y = Xs(2*Nnodes, end);
meas = [x, y];
end

% calculate means and stds
function [means, sigmas] = calc_means_sigmas(t)
[samples,~] = size(t);
means = squeeze(mean(t));
sigmas = sqrt(sum((t(:, :) - means(:)').^2, 'all')/(samples + 1));
end


function scatter_circles(means, sigmas, dims, fh, color, displayname)
% dims: index of 2 dimensions of the plane to be plotted.
% [2, 3] means YZ plane.
% scatter(means(dims(1),:), means(dims(2),:), [], color ,'+');

figure(fh)
hold on
% plot circles
for pos = 1:length(sigmas)
    area = sigmas(pos);
    r = sqrt(area/pi);
    center = [means(dims(1), pos), means(dims(2), pos)];
    rectangle('Position',[center - r, 2*r, 2*r],'Curvature',[1, 1], ...
        'EdgeColor', color(1:3), 'FaceColor', 'none');
end
scatter(NaN, NaN, 'Marker', 'o', ...
    'MarkerEdgeColor', color(1:3), 'MarkerEdgeAlpha', floor(1.5*color(4)), ...
    'MarkerFaceColor', 'none', 'MarkerFaceAlpha', color(4), ...
    'DisplayName', displayname);
hold off
end