function [theta_vec, T_vec] = Torque_vs_RotorAngle(MotorEntity, theta_min, theta_max, theta_step_deg)

pp = MotorEntity.Configuration.Poles/2;

% --- angles to evaluate ---
% theta_vec = 0:theta_step_deg:360/pp;
theta_vec = theta_min:theta_step_deg:theta_max;
T_vec = zeros(size(theta_vec));

for k = 1:numel(theta_vec)

    Progress_print('Torque_vs_RotorAngle', k, numel(theta_vec));

    % For k>1 rotate by incremental step (avoid accumulating floating error)
    if k > 1
        Rotate_Rotor(MotorEntity, theta_step_deg);   % rotates by +theta_step_deg
    end

    % Solve
    mi_createmesh();
    mi_analyze();
    mi_loadsolution();

    % Calculate torque
    T_vec(k) = Calculate_Torque(MotorEntity);
end

% --- plot ---
figure;
plot(theta_vec, T_vec, '-');
xlabel('Rotor mechanical angle \theta_m [deg]');
ylabel('Torque [N·m]');
set(gca, 'FontSize', 16);
title(sprintf('Torque vs Rotor angle'));
grid on;

end
