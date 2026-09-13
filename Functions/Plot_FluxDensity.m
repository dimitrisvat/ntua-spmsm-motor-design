function [MotorEntity] = Plot_FluxDensity(MotorEntity)

USER = getenv('USERNAME');   % "dimit" or "Dimitri
baseUserDir = fullfile('C:\Users', USER);
dir_FEMM = fullfile(baseUserDir, 'Documents', 'femm');

Rro             = MotorEntity.Configuration.Rotor.Radius;
Hm              = MotorEntity.Configuration.Rotor.MagnetHeight;
lg              = MotorEntity.Configuration.AirGap;
ang_pole        = 360/MotorEntity.Configuration.Poles;

mo_clearblock();

AirgapPoint1 = PT(Rro + Hm + lg*3/5, 0);
AirgapPoint2 = PT(Rro + Hm + lg*3/5, ang_pole);

x1 = real(AirgapPoint1);
y1 = imag(AirgapPoint1);
mo_selectpoint(x1,y1);
 
x2 = real(AirgapPoint2);
y2 = imag(AirgapPoint2);
mo_selectpoint(x2,y2);
mo_makeplot(2, 100000, fullfile(dir_FEMM, 'FluxDensity.txt'),0);

% Data from femm .txt output file
% b=load('C:\Users\dimit\Documents\femm\FluxDensity.txt');
b=load(fullfile(dir_FEMM, 'FluxDensity.txt'));
% Creation of the B signal for one period.
% Inversion and shift of the initial signal by a pole pitch
l1=b(:,1);
bp=b(:,2);
bn=-bp;
%i=length(bn):-1:1;
%bn=bn(i);
lf=l1(length(l1));
step=l1(2)-l1(1);
l2=[lf+step:step:lf+step*(length(l1))]';

bnew=[bp;bn];
lnew=[l1;l2];

figure;
plot(lnew,bnew);
grid;
xlabel('Length (mm)');
ylabel('B on air-gap (T)');
%xlim([0 150]);
% fft implementation and illustration
f_b=(2/(length(lnew)))*abs(fft(bnew));
f_b=f_b(2:length(f_b)/2);
figure;
bar(f_b);
xlabel('Harmonic order');
ylabel('Bn - Harmonic content amplitudes (T)');
xlim([0 50]);


end