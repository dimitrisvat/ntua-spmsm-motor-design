function theta_m_align = AlignDAxis(MotorEntity, theta_step)

P     = MotorEntity.Configuration.Poles;
p     = P/2;

% --- Set all currents to zero ---
Set_DQCurrent(MotorEntity, 0, 0, 0);

theta_m_vec = 0:theta_step:(360/p);    
lamA = zeros(size(theta_m_vec));

for k = 1:numel(theta_m_vec)

Progress_print('AlignDAxis', k, numel(theta_m_vec));

    if k > 1
        Rotate_Rotor(MotorEntity, theta_step);
        mi_createmesh();
    end

    mi_analyze();
    mi_loadsolution();

    cp = mo_getcircuitproperties('PhaseA');
    lamA(k) = cp(3);    % flux linkage [Wb-turns]
    
end

% ---- Diagnostics ----
lam_min = min(lamA);
lam_max = max(lamA);

[~, i_max] = max(lamA);
[~, i_min] = min(lamA);

theta_max = theta_m_vec(i_max);
theta_min = theta_m_vec(i_min);

fprintf('Phase-A flux linkage:\n');
fprintf('  min = %.6e at theta_m = %.2f deg\n', lam_min, theta_min);
fprintf('  max = %.6e at theta_m = %.2f deg\n', lam_max, theta_max);

% Plot to see what is happening
figure;
plot(theta_m_vec, lamA, '-');
grid on;
xlabel('\theta_m [deg]');
ylabel('\lambda_A [Wb-turn]');
set(gca, 'FontSize', 16);
title('Phase-A Flux Linkage vs Rotor Mechanical Angle');

% ---- Choose alignment ----
% Convention: d-axis = maximum flux linkage
theta_m_align = theta_max;

fprintf('Chosen d-axis alignment at theta_m = %.2f deg mech\n', theta_m_align);

end
