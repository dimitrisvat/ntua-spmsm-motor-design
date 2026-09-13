function [MotorEntity] = Rotate_Rotor(MotorEntity,theta)
% Select rotor group and rotate by a defined angle
% 11/2018 M.Beniakar

mi_selectgroup(MotorEntity.Solver.Groups.RotorMagnets);
mi_selectgroup(MotorEntity.Solver.Groups.RotorIron);
% mi_selectgroup(MotorEntity.Solver.Groups.RotorAir);
mi_moverotate(0,0,theta);
mi_clearselected;

end

