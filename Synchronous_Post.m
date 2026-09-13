%% Load the stored data
clear;
close all;
clc;
load('SynchronousRotation_data4.mat','Results');

%% Synchronous rotation

nI               = 10;  % total points in I_vec
nD               = 10;  % total points in theta_vec
nStator_Points   = 0;   % number of probe points along the stator
nRotor_Points    = 0;   % number of probe points along the stator

[NI_res, ND_res] = size(Results);

A = 1.7974e-05;
N = 15;
Jmax = 4;
Imax = Jmax .* A / N .* 1e6;
p = 3;

I_vec     = linspace(0, Imax, nI);        
delta_vec = linspace(0, 90, nD);
theta_e_step = 3; % deg elec

NI = numel(I_vec);
ND = numel(delta_vec);

Tmean   = zeros(NI,ND);
Tripple = zeros(NI,ND);
Psi_rms = zeros(NI,ND);
E_rms   = zeros(NI,ND);

rpm_nom = 1000;
omega_e_nom = 2*pi*p*rpm_nom/60;

%% G.1 – Store Values

for iI = 1:NI
    for iD = 1:ND
         R = Results{iI,iD};

        Tmean(iI,iD)   = mean(R.Torque);
        Tripple(iI,iD) = max(R.Torque) - min(R.Torque);

        PsiA_rms(iI,iD) = rms(R.lambdaA);
        PsiB_rms(iI,iD) = rms(R.lambdaB);
        PsiC_rms(iI,iD) = rms(R.lambdaC);

        theta_e_rad = R.theta_e * pi/180;          % electrical angle [rad]

        dPsi_dthetaA = gradient(R.lambdaA, theta_e_rad);
        dPsi_dthetaB = gradient(R.lambdaB, theta_e_rad);
        dPsi_dthetaC = gradient(R.lambdaC, theta_e_rad);

        eA_inst = omega_e_nom * dPsi_dthetaA;
        eB_inst = omega_e_nom * dPsi_dthetaB;
        eC_inst = omega_e_nom * dPsi_dthetaC;


        EA_rms_map_nom(iI,iD) = rms(eA_inst);
        EB_rms_map_nom(iI,iD) = rms(eB_inst);
        EC_rms_map_nom(iI,iD) = rms(eC_inst);

    end
end

% save('PostProcessedData.mat','Tmean','Tripple','PsiA_rms', 'PsiB_rms', 'PsiC_rms','I_vec','delta_vec');

%% ------------------ INTERPOLATION (PROMOTE TO MAIN MAPS, NDGRID SAFE) ------------------

interpolation_factor = 10;

% ---- Define COARSE grid explicitly from map sizes ----
I_vec_coarse     = linspace(I_vec(1), I_vec(end), size(Tmean,1));
delta_vec_coarse = linspace(delta_vec(1), delta_vec(end), size(Tmean,2));

% ---- Fine vectors ----
I_vec_fine     = linspace(I_vec_coarse(1), I_vec_coarse(end), ...
                          interpolation_factor * numel(I_vec_coarse));
delta_vec_fine = linspace(delta_vec_coarse(1), delta_vec_coarse(end), ...
                          interpolation_factor * numel(delta_vec_coarse));

% ---- NDGRID grids (THIS IS THE KEY) ----
[Ig_c, Dg_c] = ndgrid(I_vec_coarse, delta_vec_coarse);
[Ig_f, Dg_f] = ndgrid(I_vec_fine,   delta_vec_fine);

% ---- Interpolants (NDGRID format) ----
F_T    = griddedInterpolant(Ig_c, Dg_c, Tmean,          'linear', 'none');
F_PsiA = griddedInterpolant(Ig_c, Dg_c, PsiA_rms,       'linear', 'none');
F_PsiB = griddedInterpolant(Ig_c, Dg_c, PsiB_rms,       'linear', 'none');
F_PsiC = griddedInterpolant(Ig_c, Dg_c, PsiC_rms,       'linear', 'none');
F_EA   = griddedInterpolant(Ig_c, Dg_c, EA_rms_map_nom, 'linear', 'none');
F_EB   = griddedInterpolant(Ig_c, Dg_c, EB_rms_map_nom, 'linear', 'none');
F_EC   = griddedInterpolant(Ig_c, Dg_c, EC_rms_map_nom, 'linear', 'none');

% ---- Interpolate & PROMOTE ----
Tmean          = F_T(Ig_f, Dg_f);
PsiA_rms       = F_PsiA(Ig_f, Dg_f);
PsiB_rms       = F_PsiB(Ig_f, Dg_f);
PsiC_rms       = F_PsiC(Ig_f, Dg_f);

EA_rms_map_nom = F_EA(Ig_f, Dg_f);
EB_rms_map_nom = F_EB(Ig_f, Dg_f);
EC_rms_map_nom = F_EC(Ig_f, Dg_f);

% ---- Replace vectors ----
I_vec     = I_vec_fine;
delta_vec = delta_vec_fine;

% ---- Conservative voltage map ----
Emax_map = max(cat(3, EA_rms_map_nom, EB_rms_map_nom, EC_rms_map_nom), [], 3);

%% G.2 – Maps

[Dg,Ig] = meshgrid(delta_vec, I_vec);

figure;
contourf(Dg, Ig, Tmean, 30, 'LineStyle', 'none');  % 30 levels
hold on
contour(Dg, Ig, Tmean, 30, 'k');                   % many lines
colorbar
xlabel('\delta [deg]'); ylabel('I [A]');
title('Torque map (contours)');
grid on
saveas(gcf, fullfile(fullfile(pwd, 'FiguresC'), 'Tmean_countour.png'));

figure;
surf(Dg,Ig,Tmean); shading interp;
hold on;
contour3(Dg,Ig,Tmean,30,'k','LineWidth',0.8);   % 30 contour levels
hold off;
xlabel('\delta [deg]'); ylabel('I [A]'); zlabel('Torque [Nm]');
title('Torque map'); grid on
colorbar
ylim([0 Imax]);
xlim([0, 90]);
view(25,30);
saveas(gcf, fullfile(fullfile(pwd, 'FiguresC'), 'Tmean.png'));


figure; surf(Dg,Ig,PsiA_rms); shading interp
xlabel('\delta [deg]'); ylabel('I [A]'); zlabel('\Psi_{rms} [Wb]');
title('Flux linkage for Phase A map'); grid on
ylim([0 Imax]);
xlim([0, 90]);
view(130,30);
saveas(gcf, fullfile(fullfile(pwd, 'FiguresC'), 'Psia.png'));


figure; surf(Dg,Ig,EA_rms_map_nom); shading interp
xlabel('\delta [deg]'); ylabel('I [A]'); zlabel('E_{rms} [V]');
title('Induced voltage map for Phase A (1000 rpm)'); grid on
ylim([0 Imax]);
xlim([0, 90]);
view(130,30);
saveas(gcf, fullfile(fullfile(pwd, 'FiguresC'), 'Ea1.png'));


figure; surf(Dg,Ig,EA_rms_map_nom * 2); shading interp
xlabel('\delta [deg]'); ylabel('I [A]'); zlabel('E_{rms} [V]');
title('Induced voltage map for Phase A (2000 rpm)'); grid on
ylim([0 Imax]); 
xlim([0, 90]);
view(130,30);
saveas(gcf, fullfile(fullfile(pwd, 'FiguresC'), 'Ea2.png'));


figure; surf(Dg,Ig,EA_rms_map_nom / 2); shading interp
xlabel('\delta [deg]'); ylabel('I [A]'); zlabel('E_{rms} [V]');
title('Induced voltage map for Phase A (500 rpm)'); grid on
ylim([0 Imax]);
xlim([0, 90]);
view(130,30);
saveas(gcf, fullfile(fullfile(pwd, 'FiguresC'), 'Ea3.png'));


%% G.3 – MTPA calculation (from torque map)

NI = numel(I_vec);

T_MTPA     = zeros(NI,1);
delta_MTPA = zeros(NI,1);

for iI = 1:NI
    [T_MTPA(iI), idx] = max(Tmean(iI,:));   % max torque for this I
    delta_MTPA(iI)   = delta_vec(idx);      % corresponding delta
end

[Dg,Ig] = meshgrid(delta_vec, I_vec);

figure
surf(Dg,Ig,Tmean); shading interp
hold on
contour3(Dg,Ig,Tmean,30,'k','LineWidth',0.6)

plot3(delta_MTPA, I_vec, T_MTPA, ...
      'r-o','LineWidth',2,'MarkerFaceColor','r')

xlabel('\delta [deg]')
ylabel('I [A]')
zlabel('Torque [Nm]')
title('Torque map with MTPA trajectory')
grid on
colorbar
view(45,30)
ylim([0 Imax]);
xlim([0, 90]);
hold off
saveas(gcf, fullfile(fullfile(pwd, 'FiguresC'), 'MTPA_path.png'));

figure
plot(I_vec, delta_MTPA,'LineWidth',2)
xlabel('I [A]')
ylabel('\delta_{MTPA} [deg]')
title('MTPA angle vs current')
xlim([0, Imax]);
grid on
saveas(gcf, fullfile(fullfile(pwd, 'FiguresC'), 'I-delta_MTPA.png'));

figure
plot(I_vec, T_MTPA,'LineWidth',2)
xlabel('I [A]')
ylabel('T_{max} [Nm]')
title('Maximum torque vs current (MTPA)')
xlim([0, Imax]);
grid on
saveas(gcf, fullfile(fullfile(pwd, 'FiguresC'), 'I-T_MTPA.png'));

%% G.4 – Voltage-limited MTPA

rpm_lim   = 2000;     % mechanical rpm
E_max_rms = 195;     % voltage limit [V rms]

NI = numel(I_vec);
ND = numel(delta_vec);

[Dg,Ig] = meshgrid(delta_vec, I_vec);

% --- Voltage map scaled to this speed ---
Emax_map_rpm = Emax_map * rpm_lim / rpm_nom;

% --- Voltage-limited MTPA extraction ---
T_MTPA_V     = nan(NI,1);
delta_MTPA_V = nan(NI,1);

for iI = 1:NI
    validIdx = Emax_map_rpm(iI,:) <= E_max_rms;

    if any(validIdx)
        [T_MTPA_V(iI), loc] = max(Tmean(iI,validIdx));
        validDeltas        = delta_vec(validIdx);
        delta_MTPA_V(iI)   = validDeltas(loc);
    end
end

% --- Plot: torque map with voltage-limited MTPA trajectory ---
figure
surf(Dg,Ig,Tmean); shading interp
hold on
contour3(Dg,Ig,Tmean,30,'k','LineWidth',0.5)

valid = ~isnan(delta_MTPA_V) & ~isnan(T_MTPA_V);
plot3(delta_MTPA_V(valid), I_vec(valid), T_MTPA_V(valid), ...
      'r-o','LineWidth',2,'MarkerFaceColor','r')

xlabel('\delta [deg]')
ylabel('I [A]')
zlabel('Mean Torque [Nm]')
title(sprintf('Voltage-limited MTPA for %d rpm', rpm_lim))
grid on
colorbar
view(45,30)
hold off
saveas(gcf, fullfile(fullfile(pwd, 'FiguresC'), 'MTPA_path_V2.png'));

% --- Plot: voltage limit boundary on (I, delta) plane (classic MATLAB blue) ---
figure
contour(Ig, Dg, Emax_map_rpm, [E_max_rms E_max_rms], 'LineWidth', 2)
ylabel('\delta_{MTPA} [deg]')
xlabel('I [A]')
title(sprintf('MTPA with voltage limit boundary (E_{rms}=%.1f V) for %d rpm', E_max_rms, rpm_lim))
grid on
ylim([0 90]);
xlim([0, Imax]);
saveas(gcf, fullfile(fullfile(pwd, 'FiguresC'), 'V2_limit.png'));

% --- Plot: feasible torque region under the voltage constraint ---
Feasible = Emax_map_rpm <= E_max_rms;

figure
surf(Dg,Ig,Feasible .* Tmean); shading interp
xlabel('\delta [deg]')
ylabel('I [A]')
zlabel('Mean Torque [Nm]')
title(sprintf('Feasible torque region (E_{rms} %.1f V) for %d rpm', E_max_rms, rpm_lim))
grid on
colorbar
ylim([0 Imax]);
xlim([0, 90]);
view(35,30)
saveas(gcf, fullfile(fullfile(pwd, 'FiguresC'), 'FeasibleTorque_V2.png'));


% --- Plot: Voltage-limited MTPA torque vs current ---

valid = ~isnan(T_MTPA_V);   % currents where voltage constraint is feasible

figure
plot(I_vec(valid), T_MTPA_V(valid), 'LineWidth', 2)   % default MATLAB blue
xlabel('I [A]')
ylabel('T_{MTPA,V} [Nm]')
title(sprintf('Voltage-limited MTPA: Torque vs Current for %d rpm', rpm_lim))
xlim([0 Imax])
grid on
saveas(gcf, fullfile(fullfile(pwd, 'FiguresC'), 'I-T_MTPA_V2.png'));

%% G.5 – Magnetic flux density at probe points

% --- Operating point selection ---
% iI = round(NI/2);   % e.g. middle current
% iD = round(ND/2);   % e.g. middle angle
% R = Results{iI,iD};

% --- |B| vs electrical angle (for each probe point) ---
% figure
% hold on
% for ip = 1:nPoints
%     plot(R.theta_e, R.Babs(:,ip), 'LineWidth',2)
% end
% xlabel('\theta_e [deg]')
% ylabel('|B| [T]')
% title(sprintf('|B| vs angle (I=%.2f A, \\delta=%.1f°)', ...
%               I_vec(iI), delta_vec(iD)))
% grid on
% legend(arrayfun(@(i) sprintf('Point %d',i), 1:nPoints, ...
%        'UniformOutput',false))
% hold off

% --- Locus of the B vector (Bx–By) ---
% figure
% hold on
% for ip = 1:nPoints
%     plot(R.Bx(:,ip), R.By(:,ip), 'LineWidth',2)
% end
% axis equal
% xlabel('B_x [T]')
% ylabel('B_y [T]')
% title(sprintf('B vector locus (I=%.2f A, \\delta=%.1f°)', ...
%               I_vec(iI), delta_vec(iD)))
% grid on
% legend(arrayfun(@(i) sprintf('Point %d',i), 1:nPoints, ...
%        'UniformOutput',false))
% hold off

%% G.6 – T, flux, e vs theta (for Jn and >Jn)

iI = round(NI_res/2);
iD = round(ND_res/2);
R  = Results{iI,iD};

theta = R.theta_e;   % [deg]

% ------------------ FLUX LINKAGES (ALL PHASES) ------------------
figure
plot(theta, R.lambdaA, 'LineWidth', 1.2); hold on
plot(theta, R.lambdaB, 'LineWidth', 1.2)
plot(theta, R.lambdaC, 'LineWidth', 1.2)
grid on
xlim([0 360])
xlabel('\theta_e [deg]')
ylabel('\psi [Wb]')
title('Flux linkages')
legend('\psi_A','\psi_B','\psi_C')


%------------------ BACK EMFs (ALL PHASES) ------------------
E_A = omega_e_nom * gradient(R.lambdaA, theta*pi/180);
E_B = omega_e_nom * gradient(R.lambdaB, theta*pi/180);
E_C = omega_e_nom * gradient(R.lambdaC, theta*pi/180);

figure
plot(theta, E_A, 'LineWidth', 1.2); hold on
plot(theta, E_B, 'LineWidth', 1.2)
plot(theta, E_C, 'LineWidth', 1.2)
grid on
xlim([0 360])
xlabel('\theta_e [deg]')
ylabel('e [V]')
title('Back-EMFs')
legend('e_A','e_B','e_C')


% ------------------ TORQUE RIPPLE ------------------
figure
plot(theta, R.Torque, 'LineWidth', 1.2)
grid on
xlim([0 360])
xlabel('\theta_e [deg]')
ylabel('T [Nm]')
title('Torque ripple')


%% G.7 – Torque ripple, FFT on flux and e (for Jn and >Jn)


% --- Select operating point (example: nominal current & delta) ---
iI = round(NI_res/2);
iD = round(ND_res/2);
R  = Results{iI,iD};


% ---------- Torque ripple metrics ----------
T_mean   = mean(R.Torque);
T_pp     = max(R.Torque) - min(R.Torque);
T_ripple = 100 * T_pp / abs(T_mean);   % [%]

fprintf('Torque metrics @ I=%.2f A, delta=%.1f deg:\n', ...
        I_vec(iI), delta_vec(iD));
fprintf('  Mean torque      = %.3f Nm\n', T_mean);
fprintf('  Peak-to-peak     = %.3f Nm\n', T_pp);
fprintf('  Torque ripple    = %.2f %%\n', T_ripple);

% ---------- Electrical angle & speed ----------
theta_e_rad = R.theta_e(:) * pi/180;   % rad
rpm_lim = 1000;
omega_e     = 2*pi * rpm_lim/60 * p;   % electrical rad/s (use same rpm as elsewhere)

% ---------- Flux linkage harmonic content ----------
psi = R.lambdaA(:);
psi_ac = psi - mean(psi);

PsiFFT = fft(psi_ac);
N = numel(PsiFFT);
h = (0:N-1);   % harmonic order

% ---------- Back-EMF harmonic content (TRUE, from dλ/dt) ----------
dPsi_dtheta = gradient(psi, theta_e_rad);
e_inst = omega_e * dPsi_dtheta;
e_ac   = e_inst - mean(e_inst);

EFFT = fft(e_ac);

% ---------- Plot harmonic spectra ----------
hmax = 20;   % number of harmonics to show

figure
subplot(2,1,1)
stem(h(1:hmax), abs(PsiFFT(1:hmax))/N, 'filled')
xlabel('Harmonic order')
ylabel('|Ψ_h|')
title('Flux linkage harmonic content (Phase A)')
grid on

subplot(2,1,2)
stem(h(1:hmax), abs(EFFT(1:hmax))/N, 'filled')
xlabel('Harmonic order')
ylabel('|E_h|')
title('Back-EMF harmonic content (TRUE, from dλ/dt)')
grid on


% Avrage torque ripple
Tripple_I = mean(Tripple, 2);   % [NI x 1]
figure
plot(I_vec, Tripple_I, 'LineWidth', 2)
xlabel('I [A]')
ylabel('Average torque ripple [Nm]')
title('Average torque ripple vs current')
grid on

%% ===================== G.8 – Torque–Speed curve (MTPA & MTPV) =====================

% -------- Speed sweep --------
rpm_vec = linspace(500, 1000, 30);    % mechanical rpm sweep
E_max_rms = 95;                       % voltage limit [V rms]

NI = numel(I_vec);
ND = numel(delta_vec);

T_MTPA_rpm  = zeros(size(rpm_vec));
T_MTPV_rpm  = zeros(size(rpm_vec));

for ir = 1:numel(rpm_vec)

    rpm = rpm_vec(ir);
    omega_e = 2*pi * rpm/60 * p;
 

    % ===================== MTPA torque (current-limited) =====================
    % highest-current MTPA torque (independent of speed)
    T_MTPA_rpm(ir) = max(Tmean(end,:));

    % ===================== MTPV torque (voltage-limited) =====================
    % among ALL feasible (I,delta), find maximum torque
    Feasible = Emax_map * ir / 1000 <= E_max_rms;

    if any(Feasible(:))
        T_MTPV_rpm(ir) = max(Tmean(Feasible));
    else
        T_MTPV_rpm(ir) = 0;
    end

end

% -------------------- Plot T–rpm curve --------------------
figure
plot(rpm_vec, T_MTPA_rpm, 'k','LineWidth',2); hold on
plot(rpm_vec, T_MTPV_rpm, 'r','LineWidth',2);

xlabel('Speed [rpm]')
ylabel('Torque [Nm]')
title('Torque–Speed characteristic (MTPA & MTPV)')
legend('MTPA (current-limited)','MTPV (voltage-limited)','Location','best')
grid on
