function T = Calculate_Torque(MotorEntity)
% Function for Polar Transoformation: to convert (radius, angle) to a comple point
% 12/2025 D. Vatalas

% Select rotor blocks by group
mo_groupselectblock(MotorEntity.Solver.Groups.RotorIron);
mo_groupselectblock(MotorEntity.Solver.Groups.RotorMagnets);

T = mo_blockintegral(22);   % torque (N·m)
mo_clearblock;

% fprintf('Torque = %.6f N*m\n', T);

end