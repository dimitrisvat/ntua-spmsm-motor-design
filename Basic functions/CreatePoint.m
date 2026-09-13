function CreatePoint(z,prop,group)
% Function to add apoint with defined properties
% 11/2018 M.Beniakar

x=real(z);
y=imag(z);

mi_addnode(x,y);
mi_selectnode(x,y);
mi_setnodeprop(prop,group);
mi_clearselected;

end