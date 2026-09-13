function [MotorEntity] = Add_Materials_and_BCs(MotorEntity)
% Definition of material properties and boundary conditions
% 11/2018 M.Beniakar

% PM material parameters
mx=1.045;
my=1.045;
Hc=979000;
sigma=0.694;

% Add materials 
mi_addmaterial('Air', 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0);
mi_addmaterial('PhaseA', 1, 1, 0, 0, 58, 0, 0, 1, 0, 0, 0);
mi_addmaterial('Phase-A', 1, 1, 0, 0, 58, 0, 0, 1, 0, 0, 0);
mi_addmaterial('PhaseB', 1, 1, 0, 0, 58, 0, 0, 1, 0, 0, 0);
mi_addmaterial('Phase-B', 1, 1, 0, 0, 58, 0, 0, 1, 0, 0, 0);
mi_addmaterial('PhaseC', 1, 1, 0, 0, 58, 0, 0, 1, 0, 0, 0);
mi_addmaterial('Phase-C', 1, 1, 0, 0, 58, 0, 0, 1, 0, 0, 0);
mi_addmaterial('Iron', 2100, 2100, 0, 0, 0, 0, 0, 1, 0, 0, 0);
% Replace with given B-H curve
bhcurve = [ 0.,0.13,0.22,0.36,0.48,0.6,0.7,0.79,0.86,1.2,1.29,1.34,1.37,1.39,1.41,1.43,1.44,1.45,1.51,1.57,1.6,1.64,1.67,1.69,1.71,1.73,1.76,1.84,1.86,1.87,1.88,1.9,1.93;
    0,30,40,50,60,70,80,90,100,200,300,400,500,600,700,800,900,1000,2000,3000,4000,5000,6000,7000,8000,9000,10000,20000,30000,40000,50000,75000,100000]';
mi_addbhpoints('Iron', bhcurve);
mi_addmaterial('Magnet', mx, my, Hc, 0, sigma, 0, 0, 0, 0, 0, 0);

% Add boundary conditions 
% 'A=0' will be applied on stator outer and rotor inner boundary
mi_addboundprop('A=0',0,0,0,0,0,0,0,0,0);

end