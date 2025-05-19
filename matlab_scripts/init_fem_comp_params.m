function param = init_fem_comp_params(varargin)
% FEM parameters
% Arguments are passed in keyword-like fashion
% Currently supported keyword and default values:
% 'method', 'manipulation'

% Yanzhou Wang
% Jan 29 2025

%% Options
options = struct('method', 'manipulation');
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

%% Method
% method:  1 -> steering, 2 -> manipulation
methods = {'steering', 'manipulation'};
choice = (strcmp(options.method, 'manipulation')) + 1;
fprintf("Using %s for FEM params\n", methods{choice})

%% Params
% Needle constants
if choice == 1 % steering
    param.E = 2*1000; % 2GPa but in mm^2
else
    param.E = 20*1000; % 20GPa but in mm^2
end

OD = 0.82;
ID = 0;
param.I = pi/4*((OD/2)^4 - (ID/2)^4); % in mm^4
L = 100;
param.L = L;

% Plotting
param.neg_xlim = -L - 5;

% FEM constants
Nel = 60;
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
mu = [3.63e3; 3.63e2; 1.82e3; 3.63e3; 3.63e3; 3.63e3] * 10^-6; % Pa, but in mm^2; 1Pa = 1e-6 N/mm^2; 1kPa = 1e-3 N/mm^2
alpha = [8.74; 8.74; 3; 3; 5; 5];
gamma = 0*mu;
interval = {[0, 0.5]; [0.5, 1.5]; [1.5, 3]; [3, 5]; [5, 45]; [45, 60]};
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
if choice == 1 % steering
    param.bevel_mag = 0.5;
else
    param.bevel_mag = 0.25;
end

% Movable guide location
param.guide_lcn = -20; 

end