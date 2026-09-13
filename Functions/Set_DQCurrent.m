function [MotorEntity] = Set_DQCurrent(MotorEntity, id, iq, theta)
% Calculate the current based on d-q system

theta0 = MotorEntity.Configuration.theta_offset;

[ia, ib, ic] = Inv_ClarkePark(id, iq, theta);

% Change the current
mi_modifycircprop('PhaseA', 1, ia);
mi_modifycircprop('PhaseB', 1, ib);
mi_modifycircprop('PhaseC', 1, ic);

end