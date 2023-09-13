function [ ores ] = f_same_side_point( cor1,cor2,cor3,cor4)
% This function will be used by main function

%   Given two points of coordinate  cor1 and cor2  
%   which these form a line in the plane XY we want 
%   to know if cor4 are in the same side that the 
%   point  cor3 in reference to the line cor1 cor2

%  Return 1 if its true
%  Return 0 if its false

x11=cor1(1,1);
x12=cor2(1,1);
y11=cor1(1,2);
y12=cor2(1,2);

m1=(y11-y12)/(x11-x12);

%% Punto de referencia
x2=cor3(1,1);
y2=cor3(1,2);

%% Punto de verifivacion

x3=cor4(1,1);
y3=cor4(1,2);


 b1=y11-x11*m1;
 
m2=m1;
m3=m1;

b2=y2-m2*x2;
b3=y3-m3*x3;
rr=0;

if b1>=b2
    if b1>=b3
        rr=1;
    end
end

if b1<=b2
    if b1<=b3
        rr=1;
    end
end

ores=rr;

end

