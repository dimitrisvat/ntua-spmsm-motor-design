function CreateSegment(z1,z2,condition,elementsize,automesh,hide,group)
% Function to add segment and assign group and mesh size info
% 11/2018 M.Beniakar

x1=real(z1);
y1=imag(z1);
x2=real(z2);
y2=imag(z2);

% CreatePoint(z1,condition,group)
% CreatePoint(z2,condition,group)

mi_addsegment(x1,y1,x2,y2);
mi_selectsegment((x1+x2)/2,(y1+y2)/2);
mi_setsegmentprop(condition,elementsize,automesh,hide,group);
mi_clearselected;
end