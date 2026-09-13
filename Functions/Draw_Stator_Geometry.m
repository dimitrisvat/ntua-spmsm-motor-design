function [MotorEntity] = Draw_Stator_Geometry(MotorEntity)
% Design the stator of an SPM 

%% Get the basic dimensions
Rro         = MotorEntity.Configuration.Rotor.Radius;
Rri         = MotorEntity.Configuration.Rotor.InnerRadius;
Poles       = MotorEntity.Configuration.Poles;
Hm          = MotorEntity.Configuration.Rotor.MagnetHeight;
slots       = MotorEntity.Configuration.Stator.SlotNum;
ang_tooth   = 360/MotorEntity.Configuration.Stator.SlotNum;

% Stator
lg          = MotorEntity.Configuration.AirGap;
Rso         = MotorEntity.Configuration.Stator.OuterRadius;
rfil        = MotorEntity.Configuration.Stator.Edges;
Wt          = MotorEntity.Configuration.Stator.ToothWidth;
Lt          = MotorEntity.Configuration.Stator.ToothLength;
Rtip        = Rro + Hm + lg;
bso         = MotorEntity.Configuration.Stator.SlotOpeningWidth * 180 / (Rtip * pi);
theta_tip   = ang_tooth - bso;
%
MotorEntity.Configuration.Stator.theta_tip = theta_tip;
%
htp         = 1;
at          = 1;
bt          = 1;
Slot_split_offset   = MotorEntity.Configuration.SlotSplitOffset;

% Stator points
ToothTipInnerPoint1     = PT(Rro + Hm + lg, 0);
ToothTipInnerPoint2     = PT(Rro + Hm + lg, theta_tip);
ToothTipOutterPoint1    = PT(Rro + Hm + lg + htp, 0);
ToothTipOutterPoint2    = PT(Rro + Hm + lg + htp, theta_tip);

ToothInnerMidPoint      = PT(Rro + Hm + lg + htp + bt, theta_tip/2);
ToothOutterMidPoint     = PT(Rro + Hm + lg + Lt, theta_tip/2);

ToothOutterPoint1       = ToothOutterMidPoint + PT(Wt/2, theta_tip/2 + 90);
ToothOutterPoint2       = ToothOutterMidPoint + PT(Wt/2, theta_tip/2 - 90);

ToothInnerPoint1        = ToothInnerMidPoint + PT(Wt/2, theta_tip/2 + 90);
ToothInnerPoint2        = ToothInnerMidPoint + PT(Wt/2, theta_tip/2 - 90);

StatorYolkInnerPoint1   = PT(Rro + Hm + lg + Lt, theta_tip + bso/2);
StatorYolkInnerPoint2   = PT(Rro + Hm + lg + Lt, -bso/2);

StatorYolkOutterPoint1  = PT(Rso, theta_tip + bso/2);
StatorYolkOutterPoint2  = PT(Rso, -bso/2);

% Point for the finishing lower slot line
ToothInnerPoint3 = PT(ToothInnerPoint2, theta_tip + bso);

% Split the slot into 2
SlotMidPoint1 = PT((1-Slot_split_offset) * ToothOutterPoint1 + Slot_split_offset * ToothInnerPoint1, 0);
SlotMidPoint15 = PT((1-Slot_split_offset) * ToothOutterPoint2 + Slot_split_offset * ToothInnerPoint2, 0);
SlotMidPoint2 = PT(SlotMidPoint15, theta_tip + bso);

% Material points
StatorIronMaterialPoint = PT(Rso - (Rso - (Rro + Hm + lg + Lt))/2, 0);
StatorAirMaterialPoint = ToothTipOutterPoint2 - (ToothTipOutterPoint2 - ( PT(ToothTipOutterPoint1, theta_tip+bso) ))/2;

% Points for the circuit labels
MotorEntity.Layer1Point = PT(Rro + Hm + lg + 3*Lt/4, theta_tip + bso/2);
MotorEntity.Layer2Point = PT(Rro + Hm + lg + htp + Lt/4, theta_tip + bso/2);

%% Draw the geometry

% Draw the tooth tip geometry:
CreatePoint(ToothTipInnerPoint1, '', MotorEntity.Solver.Groups.StatorIron);
CreatePoint(ToothTipInnerPoint2, '', MotorEntity.Solver.Groups.StatorIron);
CreateArcSegment(ToothTipInnerPoint1, ToothTipInnerPoint2, theta_tip, 5, 5, '', MotorEntity.Solver.Groups.StatorIron);

CreatePoint(ToothTipOutterPoint1, '', MotorEntity.Solver.Groups.StatorIron);

CreatePoint(ToothTipOutterPoint2, '', MotorEntity.Solver.Groups.StatorIron);
CreateSegment(ToothTipInnerPoint1, ToothTipOutterPoint1, '', MotorEntity.Solver.Meshsizes.StatorTooth,0,0,MotorEntity.Solver.Groups.StatorIron)
CreateSegment(ToothTipInnerPoint2, ToothTipOutterPoint2, '', MotorEntity.Solver.Meshsizes.StatorTooth,0,0,MotorEntity.Solver.Groups.StatorIron)

% Draw the tooth geometry:
CreatePoint(ToothInnerPoint1, '', MotorEntity.Solver.Groups.StatorIron);
CreatePoint(ToothInnerPoint2, '', MotorEntity.Solver.Groups.StatorIron);
CreatePoint(ToothOutterPoint1, '', MotorEntity.Solver.Groups.StatorIron);
CreatePoint(ToothOutterPoint2, '', MotorEntity.Solver.Groups.StatorIron);

CreateSegment(ToothInnerPoint1, ToothOutterPoint1, '', MotorEntity.Solver.Meshsizes.StatorTooth,0,0,MotorEntity.Solver.Groups.StatorIron);
CreateSegment(ToothInnerPoint2, ToothOutterPoint2, '', MotorEntity.Solver.Meshsizes.StatorTooth,0,0,MotorEntity.Solver.Groups.StatorIron);

CreateSegment(ToothInnerPoint1, ToothTipOutterPoint2, '', MotorEntity.Solver.Meshsizes.StatorTooth,0,0,MotorEntity.Solver.Groups.StatorIron);
CreateSegment(ToothInnerPoint2, ToothTipOutterPoint1, '', MotorEntity.Solver.Meshsizes.StatorTooth,0,0,MotorEntity.Solver.Groups.StatorIron);

CreateSegment(ToothInnerPoint1, ToothOutterPoint1, '', MotorEntity.Solver.Meshsizes.StatorTooth,0,0,MotorEntity.Solver.Groups.StatorIron);
CreateSegment(ToothInnerPoint2, ToothOutterPoint2, '', MotorEntity.Solver.Meshsizes.StatorTooth,0,0,MotorEntity.Solver.Groups.StatorIron);

% Check if the Wt = 3
% CreateSegment(ToothInnerPoint1, ToothInnerPoint2, '', MotorEntity.Solver.Meshsizes.StatorTooth,0,0,MotorEntity.Solver.Groups.StatorIron);
% CreateSegment(ToothOutterPoint1, ToothOutterPoint2, '', MotorEntity.Solver.Meshsizes.StatorTooth,0,0,MotorEntity.Solver.Groups.StatorIron);

% Draw the slot geometry:
CreatePoint(StatorYolkInnerPoint1, '', MotorEntity.Solver.Groups.StatorIron);
CreatePoint(StatorYolkInnerPoint2, '', MotorEntity.Solver.Groups.StatorIron);
CreateArcSegment(StatorYolkInnerPoint1, ToothOutterPoint1, theta_tip/2, 5, 5, '', MotorEntity.Solver.Groups.StatorIron);
CreateArcSegment(StatorYolkInnerPoint2, ToothOutterPoint2, theta_tip/2, 5, 5, '', MotorEntity.Solver.Groups.StatorIron);

% Slot split
CreatePoint(SlotMidPoint1, '', MotorEntity.Solver.Groups.StatorIron);
CreatePoint(SlotMidPoint2, '', MotorEntity.Solver.Groups.StatorIron);
CreateSegment(SlotMidPoint1, SlotMidPoint2, '', MotorEntity.Solver.Meshsizes.StatorTooth,0,0,MotorEntity.Solver.Groups.StatorIron);

% Slot end
CreatePoint (ToothInnerPoint3, '', MotorEntity.Solver.Groups.StatorIron);
CreateSegment(ToothInnerPoint1, ToothInnerPoint3, '', MotorEntity.Solver.Meshsizes.StatorTooth,0,0,MotorEntity.Solver.Groups.StatorIron);

% Draw the yolk geometry
CreatePoint(StatorYolkOutterPoint1, '', MotorEntity.Solver.Groups.StatorIron);
CreatePoint(StatorYolkOutterPoint2, '', MotorEntity.Solver.Groups.StatorIron);
CreateArcSegment(StatorYolkOutterPoint2, StatorYolkOutterPoint1, theta_tip + bso, 5, 5, 'A=0', MotorEntity.Solver.Groups.StatorIron); % Add the boundary condition

% Create slot fillet
CreateFillet(ToothOutterPoint1, rfil);
CreateFillet(ToothOutterPoint2, rfil);

% Copy and rotate stator iron
mi_selectgroup(MotorEntity.Solver.Groups.StatorIron);
mi_copyrotate(0, 0, theta_tip + bso,  slots - 1);

%% Add materials

% Add iron material
CreateBlockLabel(StatorIronMaterialPoint, 'Iron', MotorEntity.Solver.Automesh, MotorEntity.Solver.Meshsizes.StatorYoke, 0, 0, MotorEntity.Solver.Groups.StatorIron, 0);

% Add air material in the slot 
CreateBlockLabel(StatorAirMaterialPoint, 'Air', MotorEntity.Solver.Automesh, MotorEntity.Solver.Meshsizes.StatorAir, 0, 0, MotorEntity.Solver.Groups.StatorAir, 0);

% Copy and rotate stator air
mi_selectgroup(MotorEntity.Solver.Groups.StatorAir);
mi_copyrotate(0, 0, theta_tip + bso,  slots - 1);

end