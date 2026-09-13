function [MotorEntity] = Torque_vs_theta(MotorEntity, theta_step)

P     = MotorEntity.Configuration.Poles;
p     = P/2;

Set_DQCurrent(MotorEntity, 0, 20, 0);

theta_m_vec = 0:theta_step:(360/p);    
T_vec = zeros(size(theta_m_vec));
    
for k = 1:numel(theta_m_vec)

    Progress_print('Torque_vs_theta', k, numel(theta_m_vec), -1);


    if k > 1
        Rotate_Rotor(MotorEntity, theta_step);
        mi_createmesh();
    end

    mi_analyze();
    mi_loadsolution();

    T_vec(k) = Calculate_Torque(MotorEntity);

end

% Plot to see what is happening
figure;
plot(theta_m_vec, T_vec, '-o');
grid on;
xlabel('\theta_m [deg]');
ylabel('Torque [Nm]');
title('Torque vs Angle');

end