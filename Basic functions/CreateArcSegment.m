 function CreateArcSegment(z1,z2,angle,maxseg,maxsegdeg,condition,group)
% Function to add arc segment and assign group and mesh size info
% 11/2018 M.Beniakar

x1=real(z1);
y1=imag(z1);
x2=real(z2);
y2=imag(z2);

% CreatePoint(z1,condition,group)
% CreatePoint(z2,condition,group)

mi_addarc(x1,y1,x2,y2,angle,maxseg);
znew=z1*exp(1i*pi/180*angle/2);
mi_selectarcsegment(real(znew),imag(znew));
mi_setarcsegmentprop(maxsegdeg,condition,0,group);
mi_clearselected;

end