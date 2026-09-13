function [ia, ib, ic] = Inv_ClarkePark(id, iq, theta)
% Select rotor group and rotate by a defined angle
% 11/2018 M.Beniakar

% Inverse Park transform
% theta: electrical angle in degrees

i_alpha = id * cosd(theta) - iq * sind(theta);
i_beta  = id * sind(theta) + iq * cosd(theta);

% Inverse Clarke (balanced)

ia = i_alpha;
ib = -0.5*i_alpha + (sqrt(3)/2)*i_beta;
ic = -0.5*i_alpha - (sqrt(3)/2)*i_beta;

end

