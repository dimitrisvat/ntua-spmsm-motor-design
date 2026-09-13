function [id, iq] = ClarkePark(ia, ib, ic, theta)
% Select rotor group and rotate by a defined angle
% 11/2018 M.Beniakar

% Balanced Clarke transform (power invariant)
ic = - ia - ib;

% maybe check if the system is unbalanced ?
if ic ~= - ia - ib
    disp('System may be imbalanced');
end

% Balance Clarke transform
ic = - ia - ib;

i_alpha = (2/3) * ( ia - 0.5*ib - 0.5*ic );
i_beta  = (2/3) * ( (sqrt(3)/2) * ( ib - ic ) );

% Park transform
% theta: electrical angle in degrees

id =  i_alpha * cosd(theta) + i_beta * sind(theta);
iq = -i_alpha * sind(theta) + i_beta * cosd(theta);

end

