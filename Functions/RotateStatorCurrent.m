function [theta_vec, T_vec] = RotateStatorCurrent(MotorEntity, J, theta_step)

theta_vec = 0:theta_step:360;    
T_vec     = zeros(size(theta_vec));

for k = 1:numel(theta_vec)

    Progress_print('RotateStatorCurrent', k, numel(theta_vec));

    theta_e = theta_vec(k);

    % Use DQ
    A =  1.7974e-05;
    N =15;
    I = J .* A / N .* 1e6;
    Set_DQCurrent(MotorEntity, I, 0, theta_e);
    
    % --- Solve FEMM ---
    mi_analyze();
    mi_loadsolution();

    % --- Compute torque ---
    T_vec(k) = Calculate_Torque(MotorEntity);

end

% --- Plot ---
figure;
plot(theta_vec, T_vec, '-', 'DisplayName','Torque'); hold on;
xlabel('Electrical angle \theta_e [deg]');
ylabel('Torque T [N·m]');
set(gca, 'FontSize', 16);
title(sprintf('Torque vs Electrical Angle'));
xlim([0 360]);
legend;
grid on;

end
