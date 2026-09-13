function Results = Run_SynchronousRotation(MotorEntity, I, delta, theta_e_step, z_vec_stator, z_vec_rotor)

p = MotorEntity.Configuration.Poles / 2;

% --- Mechanical span for one electrical period ---
theta_m_step  = theta_e_step / p;
theta_m_total = 360 / p;

% --- Build angle vector FIRST ---
theta_m_vec = 0:theta_m_step:theta_m_total;
nSteps      = numel(theta_m_vec);

% --- Correct allocation ---
Results.theta_m = zeros(nSteps,1);
Results.theta_e = zeros(nSteps,1);
Results.Torque  = zeros(nSteps,1);

Results.lambdaA = zeros(nSteps,1);
Results.lambdaB = zeros(nSteps,1);
Results.lambdaC = zeros(nSteps,1);

Results.id = zeros(nSteps,1);
Results.iq = zeros(nSteps,1);

% ---------- STATOR PROBE POINTS ----------
nPoints_st = numel(z_vec_stator);

Results.Bx_st   = zeros(nSteps, nPoints_st);
Results.By_st   = zeros(nSteps, nPoints_st);
Results.Babs_st = zeros(nSteps, nPoints_st);

% ---------- ROTOR PROBE POINTS ----------
nPoints_rot = numel(z_vec_rotor);

Results.Bx_rot   = zeros(nSteps, nPoints_rot);
Results.By_rot   = zeros(nSteps, nPoints_rot);
Results.Babs_rot = zeros(nSteps, nPoints_rot);

% --- Main loop ---
for k = 1:nSteps

    theta_m = theta_m_vec(k);
    theta_e = p * theta_m;

    % --- Rotate rotor ---
    if k > 1
        Rotate_Rotor(MotorEntity, theta_m_step);
    end

    % --- Rotate stator currents synchronously ---
    iq =  I*cosd(delta);
    id = -I*sind(delta);
    Set_DQCurrent(MotorEntity, id, iq, theta_e);

    % --- Solve FEMM ---
    mi_createmesh();
    mi_analyze();
    mi_loadsolution();

    % ---------- STATOR FLUX DENSITY ----------
    for ip = 1:nPoints_st
        x = real(z_vec_stator(ip));
        y = imag(z_vec_stator(ip));

        Bxy = mo_getb(x, y);

        Results.Bx_st(k,ip)   = Bxy(1);
        Results.By_st(k,ip)   = Bxy(2);
        Results.Babs_st(k,ip) = hypot(Bxy(1), Bxy(2));
    end

    % ---------- ROTOR FLUX DENSITY ----------
    for ip = 1:nPoints_rot
        x = real(z_vec_rotor(ip));
        y = imag(z_vec_rotor(ip));

        Bxy = mo_getb(x, y);

        Results.Bx_rot(k,ip)   = Bxy(1);
        Results.By_rot(k,ip)   = Bxy(2);
        Results.Babs_rot(k,ip) = hypot(Bxy(1), Bxy(2));
    end

    % --- Store results ---
    Results.id(k) = id;
    Results.iq(k) = iq;

    Results.theta_m(k) = theta_m;
    Results.theta_e(k) = theta_e;

    Results.Torque(k) = Calculate_Torque(MotorEntity);

    cpA = mo_getcircuitproperties('PhaseA');
    cpB = mo_getcircuitproperties('PhaseB');
    cpC = mo_getcircuitproperties('PhaseC');

    Results.lambdaA(k) = cpA(3);
    Results.lambdaB(k) = cpB(3);
    Results.lambdaC(k) = cpC(3);

end

end