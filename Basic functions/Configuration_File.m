function [MotorEntity] = Configuration_File(MotorEntity)
% Defines basic solver settings, group numbering and mesh sizes
% 11/2018 M.Beniakar

% General parameters
MotorEntity.Solver.Precision                        = 1e-8;          % Solver precision, default: 1e-8
MotorEntity.Solver.MinAngle                         = 15;            % Minimum mesh triangle angle, default: 15

%% Group numbering - choose yor own
% Stator groups
MotorEntity.Solver.Groups.StatorAir                 = 40;            % between tooth tips
MotorEntity.Solver.Groups.StatorIron                = 41;
MotorEntity.Solver.Groups.StatorAirgap              = 400;           % air-gap should be split to at least 2 halves (between stator and rotor) - 4 is better

% Winding phases
MotorEntity.Solver.Groups.StatorWindings.PhaseA     = 401;
MotorEntity.Solver.Groups.StatorWindings.PhaseNA    = 402;
MotorEntity.Solver.Groups.StatorWindings.PhaseB     = 403;
MotorEntity.Solver.Groups.StatorWindings.PhaseNB    = 404;
MotorEntity.Solver.Groups.StatorWindings.PhaseC     = 405;
MotorEntity.Solver.Groups.StatorWindings.PhaseNC    = 406;

% rotor
MotorEntity.Solver.Groups.RotorAir                  = 50;            % Between magnets
MotorEntity.Solver.Groups.RotorIron                 = 51;
MotorEntity.Solver.Groups.RotorMagnets              = 53;
MotorEntity.Solver.Groups.RotorAirgap               = 500;           % Rotor side air-gap(s)

%% Mesh sizes
% Number are indicative - choose your own
MotorEntity.Solver.Meshsizes.StatorAir              = 5;
MotorEntity.Solver.Meshsizes.StatorYoke             = 2;
MotorEntity.Solver.Meshsizes.StatorTooth            = 2;
MotorEntity.Solver.Meshsizes.Windings               = 5;
MotorEntity.Solver.Meshsizes.RotorAir               = 5;
MotorEntity.Solver.Meshsizes.RotorYoke              = 5;
MotorEntity.Solver.Meshsizes.RotorMagnets           = 5;
MotorEntity.Solver.Meshsizes.Airgap                 = 1; 

MotorEntity.Configuration.TorqueStep                = 20;

% ***** For shaft use 'No mesh' *****
MotorEntity.Solver.Automesh = 1; % 1 is for automesh 0 is for no automesh
end

