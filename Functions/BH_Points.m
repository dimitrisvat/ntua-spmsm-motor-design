function [MotorEntity] = BH_Points(MotorEntity)

% 3. BH data
bhcurve = [ 0.,0.13,0.22,0.36,0.48,0.6,0.7,0.79,0.86,1.2,1.29,1.34,1.37,1.39,1.41,1.43,1.44,1.45,1.51,1.57,1.6,1.64,1.67,1.69,1.71,1.73,1.76,1.84,1.86,1.87,1.88,1.9,1.93;
    0,30,40,50,60,70,80,90,100,200,300,400,500,600,700,800,900,1000,2000,3000,4000,5000,6000,7000,8000,9000,10000,20000,30000,40000,50000,75000,100000]';

B_vals = bhcurve(:, 1);
H_vals = bhcurve(:, 2);

% 4. Create the graph
figure('Name', 'Σημεία Λειτουργίας στην Καμπύλη B-H', 'Color', 'w');

% Plot it with H on the x-axis and B on the y-axis
plot(H_vals, B_vals, '-', 'LineWidth', 2, 'DisplayName', 'B-H Curve'); 
hold on;

% 3. Create cases
    J_values = [4/2, 4, 4*1.5]; 
    titles = {'J=2', 'J=4', 'J=6'};
    colors = {'r', 'g', 'b'};

% 4. Loop cases
    for i = 1:length(J_values)
        fprintf('Processing Case: %s A/mm^2\n', num2str(J_values(i)));
        
        % Set current
        Set_CurrentDens(MotorEntity, J_values(i), 90);
        
        % Solve
        mi_createmesh();
        mi_analyze();
        mi_loadsolution(); 

        
        % Call the helper function
        [Bt, Ht, By, Hy] = BH_Helper(MotorEntity);
        
        % Plot
        plot(Ht, Bt, 'o', 'MarkerEdgeColor', colors{i}, 'MarkerFaceColor', colors{i}, ...
            'MarkerSize', 8, 'DisplayName', ['Tooth: ', titles{i}]);
        plot(Hy, By, 's', 'MarkerEdgeColor', colors{i}, 'MarkerFaceColor', colors{i}, ...
            'MarkerSize', 8, 'DisplayName', ['Yoke: ', titles{i}]);
    end

    xlabel('H (A/m)'); ylabel('B (T)');
    title('B-H operation of Tooth and Yoke points');
    legend('Location', 'SouthEast');

end

% Helper function for BH curve
function [Bmag_tooth, Hmag_tooth, Bmag_yoke, Hmag_yoke] = BH_Helper(MotorEntity)

Rro             = MotorEntity.Configuration.Rotor.Radius;
Hm              = MotorEntity.Configuration.Rotor.MagnetHeight;
lg              = MotorEntity.Configuration.AirGap;
Lt              = MotorEntity.Configuration.Stator.ToothLength;
ang_tooth       = 360/MotorEntity.Configuration.Stator.SlotNum;
Rso         = MotorEntity.Configuration.Stator.OuterRadius;
Rtip        = Rro + Hm + lg;
bso             = MotorEntity.Configuration.Stator.SlotOpeningWidth * 180 / (Rtip * pi);
theta_tip   = ang_tooth - bso;


ToothPoint = PT(Rro + Hm + lg + Lt/2, theta_tip/2 + 20) ;
YokePoint = PT(Rro + Hm + lg + Lt + (Rso - (Rro + Hm + lg + Lt))/2, theta_tip/2 + 20);
CreatePoint(ToothPoint, '', 0);
CreatePoint(YokePoint, '', 0);

x1= real(ToothPoint);
y1 = imag(ToothPoint);
val1 = mo_getpointvalues(x1,y1);
Bmag_tooth = sqrt(val1(2)^2 + val1(3)^2);
Hmag_tooth = sqrt(val1(6)^2 + val1(7)^2);

x2= real(YokePoint);
y2 = imag(YokePoint);
val2 = mo_getpointvalues(x2,y2);
Bmag_yoke = sqrt(val2(2)^2 + val2(3)^2);
Hmag_yoke = sqrt(val2(6)^2 + val2(7)^2);

end
