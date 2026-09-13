function [MotorEntity] = Create_Winding(MotorEntity)
% Winding configuration for the PMSM
Rro         = MotorEntity.Configuration.Rotor.Radius;
Hm          = MotorEntity.Configuration.Rotor.MagnetHeight;
lg          = MotorEntity.Configuration.AirGap;
ang_tooth   = 360/MotorEntity.Configuration.Stator.SlotNum;
Poles       = MotorEntity.Configuration.Poles;
slots       = MotorEntity.Configuration.Stator.SlotNum;
Rtip        = Rro + Hm + lg;
bso         = MotorEntity.Configuration.Stator.SlotOpeningWidth * 180 / (Rtip * pi);
theta_tip   = ang_tooth - bso;

N           = MotorEntity.Configuration.Stator.Turns; % use negative turns for NA, NB and NC.
ff          = MotorEntity.Configuration.FillFactor;

phase_step = slots / Poles;

% Calculate the current for the circuits (without field factor)
% I = J * A * ff / N * 1e6;

%% Create the points for the labels

% Phase labels for the 1st layer (outter layer)     

% A phase
PhaseALabelPoint1 = MotorEntity.Layer1Point;
PhaseALabelPoint2 = PT(MotorEntity.Layer1Point, -(theta_tip + bso));
PhaseNALabelPoint1 = PT(MotorEntity.Layer1Point, -phase_step*(theta_tip + bso));
PhaseNALabelPoint2 = PT(MotorEntity.Layer1Point, -(phase_step+1)*(theta_tip + bso));

% B phase
PhaseNBLabelPoint1 = PT(MotorEntity.Layer1Point, -2*(theta_tip + bso));
PhaseNBLabelPoint2 = PT(MotorEntity.Layer1Point, -3*(theta_tip + bso));
PhaseBLabelPoint1 = PT(MotorEntity.Layer1Point, -(phase_step+2)*(theta_tip + bso));
PhaseBLabelPoint2 = PT(MotorEntity.Layer1Point, -(phase_step+3)*(theta_tip + bso));

% C phase
PhaseCLabelPoint1 = PT(MotorEntity.Layer1Point, -4*(theta_tip + bso));
PhaseCLabelPoint2 = PT(MotorEntity.Layer1Point, -5*(theta_tip + bso));
PhaseNCLabelPoint1 = PT(MotorEntity.Layer1Point, -(phase_step+4)*(theta_tip + bso));
PhaseNCLabelPoint2 = PT(MotorEntity.Layer1Point, -(phase_step+5)*(theta_tip + bso));

% Phase labels for the 2nd layer (inner layer)

% A phase
PhaseALabelPoint3 = MotorEntity.Layer2Point;
PhaseALabelPoint4 = PT(MotorEntity.Layer2Point, +(theta_tip + bso));
PhaseNALabelPoint3 = PT(MotorEntity.Layer2Point, -phase_step*(theta_tip + bso));
PhaseNALabelPoint4 = PT(MotorEntity.Layer2Point, -(phase_step-1)*(theta_tip + bso));

% B phase
PhaseNBLabelPoint3 = PT(MotorEntity.Layer2Point, -2*(theta_tip + bso));
PhaseNBLabelPoint4 = PT(MotorEntity.Layer2Point, -(theta_tip + bso));
PhaseBLabelPoint3 = PT(MotorEntity.Layer2Point, -(phase_step+2)*(theta_tip + bso));
PhaseBLabelPoint4 = PT(MotorEntity.Layer2Point, -(phase_step+1)*(theta_tip + bso));

% C phase
PhaseCLabelPoint3 = PT(MotorEntity.Layer2Point, -4*(theta_tip + bso));
PhaseCLabelPoint4 = PT(MotorEntity.Layer2Point, -3*(theta_tip + bso));
PhaseNCLabelPoint3 = PT(MotorEntity.Layer2Point, -(phase_step+4)*(theta_tip + bso));
PhaseNCLabelPoint4 = PT(MotorEntity.Layer2Point, -(phase_step+3)*(theta_tip + bso));

%% Add all the circuits 

% Create the 3 circuits
mi_addcircprop('PhaseA', 0, 1);
mi_addcircprop('PhaseB', 0, 1);
mi_addcircprop('PhaseC', 0, 1);
 
% Create the labels for the 1st layer
CreateBlockLabel(PhaseALabelPoint1, 'PhaseA', 1, 0, 'PhaseA', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseA, N);
CreateBlockLabel(PhaseALabelPoint2, 'PhaseA', 1, 0, 'PhaseA', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseA, N);
CreateBlockLabel(PhaseNALabelPoint1, 'Phase-A', 1, 0, 'PhaseA', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseNA, -N);
CreateBlockLabel(PhaseNALabelPoint2, 'Phase-A', 1, 0, 'PhaseA', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseNA, -N);

CreateBlockLabel(PhaseBLabelPoint1, 'PhaseB', 1, 0, 'PhaseB', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseB, N);
CreateBlockLabel(PhaseBLabelPoint2, 'PhaseB', 1, 0, 'PhaseB', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseB, N);
CreateBlockLabel(PhaseNBLabelPoint1, 'Phase-B', 1, 0, 'PhaseB', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseNB, -N);
CreateBlockLabel(PhaseNBLabelPoint2, 'Phase-B', 1, 0, 'PhaseB', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseNB, -N);

CreateBlockLabel(PhaseCLabelPoint1, 'PhaseC', 1, 0, 'PhaseC', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseC, N);
CreateBlockLabel(PhaseCLabelPoint2, 'PhaseC', 1, 0, 'PhaseC', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseC, N);
CreateBlockLabel(PhaseNCLabelPoint1, 'Phase-C', 1, 0, 'PhaseC', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseNC, -N);
CreateBlockLabel(PhaseNCLabelPoint2, 'Phase-C', 1, 0, 'PhaseC', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseNC, -N);

% Create the labels for the 2nd layer
CreateBlockLabel(PhaseALabelPoint3, 'PhaseA', 1, 0, 'PhaseA', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseA, N);
CreateBlockLabel(PhaseALabelPoint4, 'PhaseA', 1, 0, 'PhaseA', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseA, N);
CreateBlockLabel(PhaseNALabelPoint3, 'Phase-A', 1, 0, 'PhaseA', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseNA, -N);
CreateBlockLabel(PhaseNALabelPoint4, 'Phase-A', 1, 0, 'PhaseA', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseNA, -N);

CreateBlockLabel(PhaseBLabelPoint3, 'PhaseB', 1, 0, 'PhaseB', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseB, N);
CreateBlockLabel(PhaseBLabelPoint4, 'PhaseB', 1, 0, 'PhaseB', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseB, N);
CreateBlockLabel(PhaseNBLabelPoint3, 'Phase-B', 1, 0, 'PhaseB', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseNB, -N);
CreateBlockLabel(PhaseNBLabelPoint4, 'Phase-B', 1, 0, 'PhaseB', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseNB, -N);

CreateBlockLabel(PhaseCLabelPoint3, 'PhaseC', 1, 0, 'PhaseC', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseC, N);
CreateBlockLabel(PhaseCLabelPoint4, 'PhaseC', 1, 0, 'PhaseC', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseC, N);
CreateBlockLabel(PhaseNCLabelPoint3, 'Phase-C', 1, 0, 'PhaseC', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseNC, -N);
CreateBlockLabel(PhaseNCLabelPoint4, 'Phase-C', 1, 0, 'PhaseC', 0, MotorEntity.Solver.Groups.StatorWindings.PhaseNC, -N);

% Copy and rotate stator air
mi_selectgroup(MotorEntity.Solver.Groups.StatorWindings.PhaseA);
mi_selectgroup(MotorEntity.Solver.Groups.StatorWindings.PhaseNA);
mi_selectgroup(MotorEntity.Solver.Groups.StatorWindings.PhaseB);
mi_selectgroup(MotorEntity.Solver.Groups.StatorWindings.PhaseNB);
mi_selectgroup(MotorEntity.Solver.Groups.StatorWindings.PhaseC);
mi_selectgroup(MotorEntity.Solver.Groups.StatorWindings.PhaseNC);
mi_copyrotate(0, 0, 2*phase_step*(theta_tip + bso),  slots - 1);



end