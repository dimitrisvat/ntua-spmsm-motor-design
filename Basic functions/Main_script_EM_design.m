%% 1. Initialize workspace
clear;
clc;
close all;
 
USER = getenv('USERNAME');   % "dimit" or "Dimitris
baseUserDir = fullfile('C:\Users', USER);

dir_Database = fullfile( ...
    baseUserDir, ...
    'OneDrive - Εθνικό Μετσόβιο Πολυτεχνείο', ...
    'Desktop', 'NTUA', 'Ροή Ζ', 'Κατασκευή Ηλεκτρικών Μηχανών');

dir_FEMM = fullfile(baseUserDir, 'Documents', 'femm');

cd(dir_Database);
addpath(genpath(dir_Database));

% Add femm m-files to Matlab path
addpath('C:\femm42\mfiles');

%% 2. Define a simplified parametric vector for the geometry 

% Run MSV - basic design parameter definition
MSV_SPM_EMDesignCourse;
% Call Config file
[MotorEntity] = Configuration_File(MotorEntity);
    
%% 3. FEMM drawing - To be completed by students

% a. Open FEMM problem and define material properties and BCs
[MotorEntity] = Open_Femm_Problem(MotorEntity);
[MotorEntity] = Add_Materials_and_BCs(MotorEntity);

% b. Create stator 
[MotorEntity] = Draw_Stator_Geometry(MotorEntity);

% c. Create rotor
[MotorEntity] = Draw_Rotor_Geometry(MotorEntity);

% d. Create winding
[MotorEntity] = Create_Winding(MotorEntity);

% e. Rotate the rotor to minimise cogging torque
Rotate_Rotor(MotorEntity, MotorEntity.Configuration.theta_cog);
Rotate_Rotor(MotorEntity, MotorEntity.Configuration.theta_offset);

%% 4. Analysis 

% Zoom out
mi_zoomout();
mi_zoomout();
mi_zoomout();

% Analyze
mi_saveas(fullfile(dir_FEMM, 'PMSM.fem'));
mi_createmesh();
mi_analyze();
mi_loadsolution(); 

%% Check the equality of the 2 slots
[MotorEntity] = Equal_Area(MotorEntity);

%% 5. Align D-Axis

AlignDAxis(MotorEntity, 1);

% Plot the cogging torque with 0 current:
% Set_CurrentDens(MotorEntity, 0, 0);
% Torque_vs_RotorAngle(MotorEntity, 65, 75, 0.25);

%% B.1

% T-δ with 2 different ways: 
% Rotating stator current and rotating rotor with stable current

RotateStatorCurrent(MotorEntity, 4, 10);

% Set_CurrentDens(MotorEntity, 4, 0);
% Torque_vs_ElecAngle(MotorEntity, 0.5);

%% B.2
% Note that this will affect all the other questions

% a.
% Set_CurrentDens(MotorEntity, 0, 0);

% b.
% Set_CurrentDens(MotorEntity, 4, 0);

% c. 
% Set_CurrentDens(MotorEntity, 4, 90);

% d. 
Set_CurrentDens(MotorEntity, 4, 180);  

% mi_saveas('C:\\Users\\dimit\\Documents\\femm\\PMSM.fem');
mi_saveas(fullfile(dir_FEMM, 'PMSM.fem'));
mi_createmesh();
mi_analyze();
mi_loadsolution(); 

mo_showdensityplot(1, 0, 1.95, 0, 'bmag');

%% B.3

% Torque, flux linkage and back emf

Ta = Calculate_Torque(MotorEntity)

cpa = mo_getcircuitproperties('PhaseA');
lambdaA = cpa(3);   % [Wb-turns]
cpb = mo_getcircuitproperties('PhaseB');
lambdaB = cpb(3);   % [Wb-turns]
cpc = mo_getcircuitproperties('PhaseC');
lambdaC = cpc(3);   % [Wb-turns]

lambda_rms = lambdaA /sqrt(2)
back_emf_rms = lambda_rms * 50 * 2 * pi

% Compute_Back_EMF(MotorEntity, 1000, 2.5, 'PhaseA');
% Compute_Back_EMF(MotorEntity, 1000, 5, 'PhaseB');
% Compute_Back_EMF(MotorEntity, 1000, 5, 'PhaseC');


%% B.4
Plot_FluxDensity(MotorEntity); 

%% B.5 
clc;

[ia, ib, ic] = Set_CurrentDens(MotorEntity, 4, 0);

% mi_saveas('C:\\Users\\dimit\\Documents\\femm\\PMSM.fem');
mi_saveas(fullfile(dir_FEMM, 'PMSM.fem'));
mi_createmesh();
mi_analyze();
mi_loadsolution(); 

cpa = mo_getcircuitproperties('PhaseA');
lambdaA = cpa(3);   % [Wb-turns]
cpb = mo_getcircuitproperties('PhaseB');
lambdaB = cpb(3);  % [Wb-turns]
cpc = mo_getcircuitproperties('PhaseC');
lambdaC = cpc(3);   % [Wb-turns]

[lambdad, lambdaq] = ClarkePark(lambdaA, lambdaB, lambdaC, 0)
[id, iq] = ClarkePark(ia, ib, ic, 0);

% Estimated psim from previous sim
psim = 0.4121;

Ld = (lambdad-psim)/id * 1000 %mH
Lq =  (lambdaq)/iq * 1000 % mH

%% B.6

% a.
Set_CurrentDens(MotorEntity, 4/2, 90);

% b.
% Set_CurrentDens(MotorEntity, 4, 90);

% c.
% Set_CurrentDens(MotorEntity, 4*1.5, 90);

mi_saveas(fullfile(dir_FEMM, 'PMSM.fem'));
mi_createmesh();
mi_analyze();
mi_loadsolution(); 
% mo_showdensityplot(1, 0, 1.95, 0, 'bmag');

% Set density plot manualy beacuse you can't set correct min/max.

%% B.7

BH_Points(MotorEntity);

%% G - Synchronous rotation

nI               = 1;  % total points in I_vec
nD               = 1;  % total points in theta_vec
nStator_Points   = 0;   % number of probe points along the stator
nRotor_Points    = 0;   % number of probe points along the stator
theta_e_step     = 0.5;  % deg elec

A = 1.7974e-05;
N = 15;
Jmax = 4;
Imax = Jmax .* A / N .* 1e6;

I_vec     = linspace(0, Imax, nI);        
delta_vec = linspace(0, 90, nD);

ang_tooth   = 360 / MotorEntity.Configuration.Stator.SlotNum;
theta_tip   = MotorEntity.Configuration.Stator.theta_tip;
Rro         = MotorEntity.Configuration.Rotor.Radius;
Hm          = MotorEntity.Configuration.Rotor.MagnetHeight;
lg          = MotorEntity.Configuration.AirGap;
Rso         = MotorEntity.Configuration.Stator.OuterRadius;
Rri         = MotorEntity.Configuration.Rotor.InnerRadius;

r_min_stator = Rro + Hm + lg;
r_max_stator = Rso;
theta_probe = theta_tip/2 + ang_tooth;

r_vec_stator = linspace(r_min_stator, r_max_stator, nStator_Points);
z_vec_stator = PT(r_vec_stator, theta_probe);

r_min_rotor = Rri;
r_max_rotor = Rro;
theta_probe = theta_tip/2 + ang_tooth;

r_vec_rotor = linspace(r_min_rotor, r_max_rotor, nRotor_Points);
z_vec_rotor = PT(r_vec_rotor, theta_probe);

% Analyze
mi_saveas(fullfile(dir_FEMM, 'PMSM.fem'));
mi_createmesh();
mi_analyze();
mi_loadsolution(); 

%%
for iI = 1:length(I_vec)
    for iD = 1:length(delta_vec)

        Progress_print('Synchronous rotation', (iI-1)*numel(I_vec) + iD, numel(I_vec)*numel(delta_vec));
        Results{iI,iD} = Run_SynchronousRotation(MotorEntity, I_vec(iI), delta_vec(iD), theta_e_step, z_vec_stator, z_vec_rotor);

    end
end

save('SynchronousRotation_data2.mat','Results');
