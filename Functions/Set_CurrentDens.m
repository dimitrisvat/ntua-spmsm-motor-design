function [ia, ib, ic] = Set_CurrentDens(MotorEntity, J, theta)

N      = MotorEntity.Configuration.Stator.Turns;
theta0 = MotorEntity.Configuration.theta_offset;
A = MotorEntity.Configuration.SlotArea;
% Calculate the current for the circuits based on J

% Average area of both slots
I = J .* A / N .* 1e6;

ia = I * sqrt(2) * cosd(theta);
ib = I * sqrt(2) * cosd(theta - 120);
ic = I * sqrt(2) * cosd(theta + 120);

% Change the current
mi_modifycircprop('PhaseA', 1, ia);
mi_modifycircprop('PhaseB', 1, ib);
mi_modifycircprop('PhaseC', 1, ic);

end