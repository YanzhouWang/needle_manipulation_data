function param = load_experiment_param(tissue)
% Function to return tissue/experiment-specific fem param set to expedite
% result visualization

% This specific set is used in RAL_2025

% Yanzhou Wang
% May 19 2025

param = [];

%% 2-layer plastisol
if strcmp(tissue, "plastisol")  
    disp('Returning param set: Plastisol')

    param.E = 200*1000; % 200GPa but in mm^2
    OD = 1.024;
    ID = 0;
    param.I = pi/4*((OD/2)^4 - (ID/2)^4); % in mm^4
    L = 100;
    param.L = L;

    % Plotting
    param.neg_xlim = -L - 5;

    % FEM constants
    Nel = 50;
    Nen = 4;

    param.Nel = Nel;
    param.Nnodes = Nel + 1;
    param.Nen = Nen;
    LM = zeros(Nen, Nel);
    for e = 1:Nel
        LM(:, e) = (2*e - 1) : (2*e + 2);
    end
    param.LM = LM;

    % Tissue constants
    mu = [1.82e3; 3.63e2] * 10^-6; % Pa, but in mm^2; 1Pa = 1e-6 N/mm^2; 1kPa = 1e-3 N/mm^2
    alpha = [8.74; 8.74];
    gamma = 0*mu;
    interval = {[0, 13]; [13, 60]};
    ti = 20*ones(size(mu));

    param.mu = mu;
    param.alpha = alpha;
    param.gamma = gamma;
    param.interval = interval;
    param.ti = ti;

    % Load-stepping
    param.max_inner_iter = uint8(5); % maximum number of iterations for Newton's method
    param.max_outer_iter = uint8(5); % maximum number of iterations for load stepping
    param.tol = 1e-2;

    % Constraint interval
    param.contact_interval = 1;

    % Bevel constraint used to modify new contraint point location
    param.bevel_mag = 0.15;

    % Movable guide location
    param.guide_lcn = -40;

%% 1-layer chicken breast    
elseif strcmp(tissue, "chicken")
    disp('Returning param set: Chicken Breast')

    param.E = 200*1000; % 200GPa but in mm^2
    OD = 1.024;
    ID = 0;
    param.I = pi/4*((OD/2)^4 - (ID/2)^4); % in mm^4
    L = 100;
    param.L = L;

    % Plotting
    param.neg_xlim = -L - 5;

    % FEM constants
    Nel = 50;
    Nen = 4;

    param.Nel = Nel;
    param.Nnodes = Nel + 1;
    param.Nen = Nen;
    LM = zeros(Nen, Nel);
    for e = 1:Nel
        LM(:, e) = (2*e - 1) : (2*e + 2);
    end
    param.LM = LM;

    % Tissue constants
    mu = [3.63e2] * 10^-6; % Pa, but in mm^2; 1Pa = 1e-6 N/mm^2; 1kPa = 1e-3 N/mm^2
    alpha = [8.74];
    gamma = 0*mu;
    interval = {[0, 60]};
    ti = 20*ones(size(mu));

    param.mu = mu;
    param.alpha = alpha;
    param.gamma = gamma;
    param.interval = interval;
    param.ti = ti;

    % Load-stepping
    param.max_inner_iter = uint8(5); % maximum number of iterations for Newton's method
    param.max_outer_iter = uint8(5); % maximum number of iterations for load stepping
    param.tol = 1e-2;

    % Constraint interval
    param.contact_interval = 1;

    % Bevel constraint used to modify new contraint point location
    param.bevel_mag = 0.15;

    % Movable guide location
    param.guide_lcn = -20;

%% Default
else
    disp('Returning param set: NONE')
    warning('No param set loaded')
end