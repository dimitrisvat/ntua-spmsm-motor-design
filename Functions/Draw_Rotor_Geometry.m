function [MotorEntity] = Draw_Rotor_Geometry(MotorEntity)
% Design the rotor of an SPM 
% To be completed by students

%% Get the basic dimensions
Rro             = MotorEntity.Configuration.Rotor.Radius;
Rri             = MotorEntity.Configuration.Rotor.InnerRadius;
Poles           = MotorEntity.Configuration.Poles;
Hm              = MotorEntity.Configuration.Rotor.MagnetHeight;
ang_pole        = 360/MotorEntity.Configuration.Poles;
ang_magnet      = ang_pole*MotorEntity.Configuration.Rotor.MagnetDC/100;
lg              = MotorEntity.Configuration.AirGap;
AirGapLayers    = MotorEntity.Configuration.NumAirGapLayers;


% Rotor points
RotorYokeInnerPoint1 = PT(Rri, 0);
RotorYokeInnerPoint2 = PT(Rri, ang_pole);
RotorYokeOutterPoint1 = PT(Rro, 0); 
RotorYokeOutterPoint2 = PT(Rro, ang_pole);

MaggnetInnerPoint1 = PT(Rro, (ang_pole-ang_magnet)/2);
MaggnetInnerPoint2 = PT(Rro, (ang_pole+ang_magnet)/2);
MaggnetOutterPoint1 = PT(Rro+Hm, (ang_pole-ang_magnet)/2);
MaggnetOutterPoint2 = PT(Rro+Hm, (ang_pole+ang_magnet)/2);

RotorMagnetsMaterialPoint1 = PT(Rro + Hm/2, ang_pole/2);
RotorMagnetsMaterialPoint2 = PT(Rro + Hm/2, ang_pole/2 + ang_pole);

RotorIronMaterialPoint = (Rri + (Rro - Rri)/2);
RotorShaftMaterialPoint = 0;

AirgapPoint = Rro + Hm;

%% Draw the geometry

% Create the yoke geometry
CreatePoint(RotorYokeInnerPoint1, '', MotorEntity.Solver.Groups.RotorIron);
CreatePoint(RotorYokeInnerPoint2, '', MotorEntity.Solver.Groups.RotorIron);
CreateArcSegment(RotorYokeInnerPoint1, RotorYokeInnerPoint2, ang_pole, 5, 5, 'A=0', MotorEntity.Solver.Groups.RotorIron); % Add the boundary condition

CreatePoint(RotorYokeOutterPoint1, '', MotorEntity.Solver.Groups.RotorIron);
CreatePoint(RotorYokeOutterPoint2, '', MotorEntity.Solver.Groups.RotorIron);
CreateArcSegment(RotorYokeOutterPoint1, RotorYokeOutterPoint2, ang_pole, 5, 5, '', MotorEntity.Solver.Groups.RotorIron);


% Create the magnet geometry
CreatePoint(MaggnetInnerPoint1, '', MotorEntity.Solver.Groups.RotorMagnets);
CreatePoint(MaggnetInnerPoint2, '', MotorEntity.Solver.Groups.RotorMagnets);

CreatePoint(MaggnetOutterPoint1, '', MotorEntity.Solver.Groups.RotorMagnets);
CreatePoint(MaggnetOutterPoint2, '', MotorEntity.Solver.Groups.RotorMagnets);
CreateArcSegment(MaggnetOutterPoint1, MaggnetOutterPoint2, ang_magnet, 5, 5, '', MotorEntity.Solver.Groups.RotorMagnets);

CreateSegment(MaggnetOutterPoint1, MaggnetInnerPoint1, '', MotorEntity.Solver.Meshsizes.RotorMagnets,0,0,MotorEntity.Solver.Groups.RotorMagnets)
CreateSegment(MaggnetOutterPoint2, MaggnetInnerPoint2, '', MotorEntity.Solver.Meshsizes.RotorMagnets,0,0,MotorEntity.Solver.Groups.RotorMagnets)

% Copy and rotate Rotor Iron
mi_selectgroup(MotorEntity.Solver.Groups.RotorIron);
mi_selectgroup(MotorEntity.Solver.Groups.RotorMagnets);
mi_copyrotate(0, 0, ang_pole, ang_pole - 1);

% Create additional airgap layers for improved accuracy
for i = 1:AirGapLayers
    newAirgapPoint = AirgapPoint + i * lg / AirGapLayers;
    CreatePoint(newAirgapPoint, '', MotorEntity.Solver.Groups.RotorAirgap);
    CreatePoint(-newAirgapPoint, '', MotorEntity.Solver.Groups.RotorAirgap);
    CreateArcSegment(newAirgapPoint, -newAirgapPoint, 180, 5, 5, '', MotorEntity.Solver.Groups.RotorAirgap);
    CreateArcSegment(-newAirgapPoint, newAirgapPoint, 180, 5, 5, '', MotorEntity.Solver.Groups.RotorAirgap);

    % Add the materials
    if i ~= 0
        CreateBlockLabel(newAirgapPoint - (newAirgapPoint - (AirgapPoint + (i-1)*lg / AirGapLayers))/2, 'Air', MotorEntity.Solver.Automesh, MotorEntity.Solver.Meshsizes.RotorAir, 0, 0, MotorEntity.Solver.Groups.RotorAirgap, 0);
    end
end

%% Add materials

% Add core material
CreateBlockLabel(RotorIronMaterialPoint,'Iron', MotorEntity.Solver.Automesh,MotorEntity.Solver.Meshsizes.RotorYoke,0,0,MotorEntity.Solver.Groups.RotorIron,0)

% Add shaft material
CreateBlockLabel(RotorShaftMaterialPoint,'<No Mesh>', MotorEntity.Solver.Automesh,MotorEntity.Solver.Meshsizes.RotorYoke,0,0,MotorEntity.Solver.Groups.RotorIron,0)

% Add magnet material
CreateBlockLabel(RotorMagnetsMaterialPoint1, 'Magnet', MotorEntity.Solver.Automesh, MotorEntity.Solver.Meshsizes.RotorMagnets, 0, ang_pole/2, MotorEntity.Solver.Groups.RotorMagnets, 0); % Add the magnet direction
CreateBlockLabel(RotorMagnetsMaterialPoint2, 'Magnet', MotorEntity.Solver.Automesh, MotorEntity.Solver.Meshsizes.RotorMagnets, 0, ang_pole/2 + ang_pole + 180, MotorEntity.Solver.Groups.RotorMagnets, 0); % Add the magnet direction

% Copy and rotate Rotor Magnets
mi_selectgroup(MotorEntity.Solver.Groups.RotorMagnets);
mi_copyrotate(0, 0, 2*ang_pole, Poles/2 - 1);


%% Create airgap points at a pole pitch for the fft on B.4
AirgapPoint1 = PT(Rro + Hm + lg*3/5, 0);
CreatePoint(AirgapPoint1, '', MotorEntity.Solver.Groups.RotorAir);

AirgapPoint2 = PT(Rro + Hm + lg*3/5, ang_pole);
CreatePoint(AirgapPoint2, '', MotorEntity.Solver.Groups.RotorAir);

end