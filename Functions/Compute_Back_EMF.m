function [theta_e, e_phase, lambda_phase] = Compute_Back_EMF(MotorEntity, rpm, theta_step_m, phaseName)

p = MotorEntity.Configuration.Poles / 2;   % pole pairs

% --- Zero currents (no-load back-EMF) ---
Set_CurrentDens(MotorEntity, 0, 0);

% --- Sweep one electrical period in mechanical degrees ---
theta_m = 0:theta_step_m:(360/p);          % [deg mech]
lambda_phase = zeros(size(theta_m));

for k = 1:numel(theta_m)

    Progress_print('Compute_Back_EMF', k, numel(theta_m));

    if k > 1
        Rotate_Rotor(MotorEntity, theta_step_m); % mechanical rotation
        mi_createmesh();
    end

    mi_analyze();
    mi_loadsolution();

    cp = mo_getcircuitproperties(phaseName);
    lambda_phase(k) = cp(3);               % [Wb-turns]
end

% --- Convert to electrical angle (radians) ---
theta_e = deg2rad(p * theta_m);            % [rad elec]

% --- Numerical derivative dλ/dθ_e ---
dtheta = mean(diff(theta_e));
dlam_dtheta = gradient(lambda_phase, dtheta);

% --- Electrical speed ---
omega_m = 2*pi*rpm/60;                     % [rad/s]
omega_e = p * omega_m;                     % [rad/s]

% --- Back-EMF ---
e_phase = omega_e * dlam_dtheta;           % [V]


% --- RMS Calculation ---
e_rms = sqrt(mean(e_phase.^2)); 

% Print in the command window
fprintf('RMS Back-EMF for %s: %.4f V\n', phaseName, e_rms);

% RMS calculation using the trapezoidal rule
Period = theta_e(end) - theta_e(1);
e_rms2 = sqrt( (1/Period) * trapz(theta_e, e_phase.^2) );


% Print in the command window
fprintf('RMS Back-EMF for %s: %.4f V with an integral\n', phaseName, e_rms2);

% --- Plots ---
figure('Name', sprintf('Back-EMF - %s', phaseName));
subplot(2,1,1);
plot(rad2deg(theta_e), lambda_phase, 'LineWidth', 1.5);
grid on;
xlabel('\theta_e [deg]');
ylabel(sprintf('\\lambda_{%s} [Wb-turn]', phaseName));
set(gca, 'FontSize', 16);
title(sprintf('Flux Linkage – %s', phaseName));

subplot(2,1,2);
plot(rad2deg(theta_e), e_phase, 'LineWidth', 1.5);
grid on;
xlabel('\theta_e [deg]');
ylabel(sprintf('e_{%s} [V]', phaseName));
set(gca, 'FontSize', 16);
title(sprintf('Back-EMF – %s (rpm = %.1f)', phaseName, rpm));

end
