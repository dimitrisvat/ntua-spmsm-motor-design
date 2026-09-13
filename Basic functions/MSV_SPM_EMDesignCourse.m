% MSV (Machine State Vector) definition: basic design parameter structure
% 11/2018 M.Beniakar

% Define a struct, for example 'MotorEntity' or 'Motor' or whatever suits you
% Any equivalent variation of basic parameters is acceptable

AM = 03121093;
Z = mod(AM, 10);
Y = mod(floor(AM/10), 10);
X = mod(floor(AM/100), 10);

% X = 10;
% Y = -10;
% Z = 3;

%% Basic parameters
MotorEntity.Configuration.Poles                         = 6;
MotorEntity.Configuration.Phases                        = 3;
MotorEntity.Configuration.AirGap                        = 0.6 + Z*0.03;                         % air-gap length in mm
MotorEntity.Configuration.ActiveLength                  = 130;                                  % motor active length in mm
MotorEntity.Configuration.FillFactor                    = 0.7;                                  % stator slot fill factor 
MotorEntity.Configuration.NominalCurrentDensity         = 4;                                    % stator slot current density nominal in A/mm^2

%% Stator Configuration
MotorEntity.Configuration.Stator.OuterRadius            = 52;                                   % stator outer radius in mm - Rso
MotorEntity.Configuration.Stator.Spp                    = 2;                                    % number of slots per pole per phase
MotorEntity.Configuration.Stator.Yoke2toothNormalized   = 1.3;                                  % yoke takes * times times the tooth width 
MotorEntity.Configuration.Stator.Tooth2SlotPercentage   = 40;                                   % percentage of tooth width to slot pitch (usually defined on the stator inner radius)
MotorEntity.Configuration.Stator.ToothParallelization   = 100;                                  % 100% means parallel tooth by default
MotorEntity.Configuration.Stator.Edges                  = 1.25;                                 % radius of the smoothing of stator slots (for fillet definition)

MotorEntity.Configuration.Stator.ToothTips              = 60;                                   % percentage of tooth tips width to slot pitch
MotorEntity.Configuration.Stator.Tips2Tooth             = 20;                                   % percentage of tooth tips total height to tooth length (Ltooth = Rso-Rsi-yoke thickness)
MotorEntity.Configuration.Stator.Tips2Tips              = 40;                                   % percentage of tooth tips lower part height to total tooth tip height 

%% Winding Configuration
MotorEntity.Configuration.Winding.Layers                = 2;                                    % winding layers (for you it's 2)
MotorEntity.Configuration.Winding.Overlap               = 1;                                    % number of slots that winding is shift between layers

%% Rotor Configuration 
% Basic dimensions and materials
MotorEntity.Configuration.Rotor.Radius                  = 33;                                   % outer rotor radius including magnets - Rro
MotorEntity.Configuration.Rotor.InnerRadius             = 25;                                   % rotor inner radius that defines yoke - Rri
% Magnet dimensions
MotorEntity.Configuration.Rotor.MagnetDC                = 65 + X;                               % magnet arc/pole pitch in (%)  
MotorEntity.Configuration.Rotor.MagnetHeight            = 3 + Y*0.1;                            % height of the magnet (mm)

% Extra parameters
MotorEntity.Configuration.Stator.SlotOpeningWidth       = 1.5 + Z * 0.025;
MotorEntity.Configuration.Stator.SlotNum                = 36;
MotorEntity.Configuration.Stator.ToothWidth             = 3;
MotorEntity.Configuration.Stator.ToothLength            = 10;
MotorEntity.Configuration.Stator.Turns                  = 15;
MotorEntity.Configuration.SlotSplitOffset               = 0.471325;                              % Increace to make A1 bigger
MotorEntity.Configuration.NumAirGapLayers               = 5;
MotorEntity.Configuration.SlotArea                      = 1.8037e-05;


MotorEntity.Configuration.theta_offset                  = 69;                                   % In degrees, d-axis alignment angle %daxisalign leei 65.5
% Για 0 ροπη κοντα στο 74
MotorEntity.Configuration.theta_cog                     = -0.25;                                  % In degrees, offset for 0 cogging torque