function [ores] = f_check_inside_triangle( cor1,cor2,cor3,cor4)



% Given tree points of coordinate  cor1 cor2 and cor3  
%  This function return 1 if cor4 there is inside the triangle   
%  created by cor1 cor2 and cor3 in plane   
%     

%  return 1 if cor4 inside tringle cor1,cor2,cor3  
%  return 0 if cor4 outside tringle cor1,cor2,cor3
%---------------------------------------------------

% sample 
% P1=[4 4];
% P2=[7 13];
% P3=[15,8];
%  PP=[12 4];
%  KK=[10,10];
% check if PP inside P1,P2,P3...

%  vcheck= f_check_inside_triangle( P1,P2,P3,PP)
%   return 0 .....
  
%  vcheck= f_check_inside_triangle( P1,P2,P3,KK)
%   return 1 .....


 

% ---------
% Author: Aldo Tamariz
% e-mail: aldotb@gmail.com
% created the 09/27/2018
 
P1=cor1;
P2=cor2;
P3=cor3;

xx=(P1(1,1)+P2(1,1)+P3(1,1))/3;
yy=(P1(1,2)+P2(1,2)+P3(1,2))/3;
Pxy=[xx yy];
ores=0;
v1 = f_same_side_point( P1,P2,Pxy,cor4);
v2 = f_same_side_point( P2,P3,Pxy,cor4);
v3 = f_same_side_point( P3,P1,Pxy,cor4);

if v1
    if v2
        if v3
             ores=1;
        end
    end
end


end

