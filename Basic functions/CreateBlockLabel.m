function CreateBlockLabel(z,material,automesh,meshsize,circuit,magdir,group,turn)
% Function to add material and assign group and mesh size info
% 11/2018 M.Beniakar

x=real(z);
y=imag(z);

mi_addblocklabel(x,y);
mi_selectlabel(x,y);
mi_setblockprop(material,automesh,meshsize,circuit,magdir,group,turn);
mi_clearselected;

end