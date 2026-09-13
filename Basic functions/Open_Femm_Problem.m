function [MotorEntity] = Open_Femm_Problem(MotorEntity)
% Opens a magnetics problem in femm and applies basic solver settings
% 11/2018 M.Beniakar

openfemm(1);
newdocument(0);
mi_probdef(0,'millimeters','planar',MotorEntity.Solver.Precision, MotorEntity.Configuration.ActiveLength ,MotorEntity.Solver.MinAngle);

end