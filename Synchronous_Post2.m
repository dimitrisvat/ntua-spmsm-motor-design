%% ===================== POST-PROCESSING: B FIELD EVOLUTION =====================

clear; close all; clc;
load('SynchronousRotation_data4.mat','Results');

% ------------------ Select operating point ------------------
% (since I and delta are fixed in this study, Results is likely 1x1)
iI = 1;
iD = 1;

R = Results{iI,iD};

theta_e = R.theta_e;   % [deg]

%% ===================== STATOR PROBE POINTS =====================

if isfield(R,'Bx_st')

    nPoints_st = size(R.Bx_st,2);

    % --- |B| vs electrical angle ---
    figure
    hold on
    for ip = 1:nPoints_st
        plot(theta_e, R.Babs_st(:,ip),'LineWidth',1.8)
    end
    grid on
    xlabel('\theta_e [deg]')
    ylabel('|B| [T]')
    title('Stator probe points: |B| vs \theta_e')
    legend(arrayfun(@(i) sprintf('Point %d',i),1:nPoints_st,'UniformOutput',false))
    xlim([0 360])
    saveas(gcf, fullfile(fullfile(pwd, 'FiguresC2'), 'Babs_stator.png'));

    % --- Geometric locus Bx–By ---
    figure
    hold on
    for ip = 1:nPoints_st
        plot(R.Bx_st(:,ip), R.By_st(:,ip),'LineWidth',2)
    end
    axis equal
    grid on
    xlabel('B_x [T]')
    ylabel('B_y [T]')
    title('Stator probe points: geometric locus of B')
    legend(arrayfun(@(i) sprintf('Point %d',i),1:nPoints_st,'UniformOutput',false))
    saveas(gcf, fullfile(fullfile(pwd, 'FiguresC2'), 'Bxy_stator.png'));

end

%% ===================== ROTOR PROBE POINTS =====================

if isfield(R,'Bx_rot')

    nPoints_rot = size(R.Bx_rot,2);

    % --- |B| vs electrical angle ---
    figure
    hold on
    for ip = 1:nPoints_rot
        plot(theta_e, R.Babs_rot(:,ip),'LineWidth',1.8)
    end
    grid on
    xlabel('\theta_e [deg]')
    xlim([0 360])
    ylabel('|B| [T]')
    title('Rotor probe points: |B| vs \theta_e')
    legend(arrayfun(@(i) sprintf('Point %d',i),1:nPoints_rot,'UniformOutput',false))
    saveas(gcf, fullfile(fullfile(pwd, 'FiguresC2'), 'Babs_rotor.png'));

    % --- Geometric locus Bx–By ---
    figure
    hold on
    for ip = 1:nPoints_rot
        plot(R.Bx_rot(:,ip), R.By_rot(:,ip),'LineWidth',2)
    end
    axis equal
    grid on
    xlabel('B_x [T]')
    ylabel('B_y [T]')
    title('Rotor probe points: geometric locus of B')
    legend(arrayfun(@(i) sprintf('Point %d',i),1:nPoints_rot,'UniformOutput',false))
    saveas(gcf, fullfile(fullfile(pwd, 'FiguresC2'), 'Bxy_rotor.png'));

end

%%
theta = R.theta_e(:);          % [deg]
theta_rad = theta * pi/180;    % [rad]

rpm = 1000;
p   = 3;
omega_e = 2*pi*rpm/60*p;

%% ===================== FLUX LINKAGES =====================
figure
plot(theta, R.lambdaA,'LineWidth',1.5); hold on
plot(theta, R.lambdaB,'LineWidth',1.5)
plot(theta, R.lambdaC,'LineWidth',1.5)
grid on
xlim([0 max(theta)])
xlabel('\theta_e [deg]')
ylabel('\Psi [Wb]')
title('Flux linkages')
legend('\Psi_A','\Psi_B','\Psi_C')
saveas(gcf, fullfile(fullfile(pwd, 'FiguresC2'), 'Flux_linkage.png'));


%% ===================== BACK-EMF (TRUE, from dλ/dt) =====================
E_A = omega_e * gradient(R.lambdaA, theta_rad);
E_B = omega_e * gradient(R.lambdaB, theta_rad);
E_C = omega_e * gradient(R.lambdaC, theta_rad);

figure
plot(theta, E_A,'LineWidth',1.5); hold on
plot(theta, E_B,'LineWidth',1.5)
plot(theta, E_C,'LineWidth',1.5)
grid on
xlim([0 max(theta)])
xlabel('\theta_e [deg]')
ylabel('E [V]')
title('Back-EMFs')
legend('E_A','E_B','E_C')
saveas(gcf, fullfile(fullfile(pwd, 'FiguresC2'), 'Back-emf.png'));


%% ===================== TORQUE RIPPLE =====================
Tmean = mean(R.Torque);
T_ripple = R.Torque - Tmean;

figure
plot(theta, T_ripple,'LineWidth',1.5)
grid on
xlim([0 max(theta)])
xlabel('\theta_e [deg]')
ylabel('T [Nm]')
title('Torque ripple')
saveas(gcf, fullfile(fullfile(pwd, 'FiguresC2'), 'Torque_ripple2.png'));

% Torque ripple metrics
T_mean = mean(R.Torque);
T_pp   = max(R.Torque) - min(R.Torque);
T_rip  = 100 * T_pp / abs(T_mean);

fprintf('\nTorque metrics:\n');
fprintf('  Mean torque   = %.3f Nm\n', T_mean);
fprintf('  Peak-to-peak  = %.3f Nm\n', T_pp);
fprintf('  Ripple        = %.2f %%\n', T_rip);

%% ===================== FFT: FLUX & BACK-EMF (BAR STYLE) =====================

% -------- Flux FFT --------
psi = R.lambdaA(:);
psi_ac = psi - mean(psi);

PsiFFT = fft(psi_ac);
N = numel(PsiFFT);
PsiMag = abs(PsiFFT)/N;

% -------- Back-EMF FFT --------
dPsi_dtheta = gradient(psi, theta_rad);
e_inst = omega_e * dPsi_dtheta;
e_ac = e_inst - mean(e_inst);

EFFT = fft(e_ac);
EMag = abs(EFFT)/N;

% -------- Harmonic axis --------
hmax = 50;
h = 0:hmax-1;

%% ===================== PLOT FFT =====================

figure
bar(h, PsiMag(1:hmax), 'EdgeColor','none')
grid on
xlabel('Harmonic order')
ylabel('\Psi amplitude')
title('Flux linkage harmonic content (Phase A)')
xlim([0 hmax])
saveas(gcf, fullfile(fullfile(pwd, 'FiguresC2'), 'Psi_fft.png'));

figure
bar(h, EMag(1:hmax), 'EdgeColor','none')
grid on
xlabel('Harmonic order')
ylabel('E [V]')
title('Back-EMF harmonic content')
xlim([0 hmax])
saveas(gcf, fullfile(fullfile(pwd, 'FiguresC2'), 'Back-emf_fft.png'));

