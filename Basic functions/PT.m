function z = PT(radius, angle) 
% Function for Polar Transoformation: to convert (radius, angle) to a comple point
% 12/2025 D. Vatalas

z = radius .* (cosd(angle) + 1j*sind(angle));

end