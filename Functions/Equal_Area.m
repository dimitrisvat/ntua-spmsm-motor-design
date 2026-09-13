function [MotorEntity] = Equal_Area(MotorEntity)

x1 = real(MotorEntity.Layer1Point);
y1 = imag(MotorEntity.Layer1Point);
mo_selectblock(x1, y1);
A1 = mo_blockintegral(5)
mo_clearblock();

x2 = real(MotorEntity.Layer2Point);
y2 = imag(MotorEntity.Layer2Point);
mo_selectblock(x2, y2);
A2 = mo_blockintegral(5)
mo_clearblock();

if A1 < A2
    disp('Increace the offset!');
end

if A1 > A2
    disp('Decrease the offset!');
end

end