clear classes
clear all
clc
addpath([cd '\Functions'])
addpath([cd '\Functions\graph_cal'])
addpath([cd '\Test Cases'])
%% Load Case
load('Test Cases\MPCSixbus.mat')
%% add fault
MPC=Faultedbus(MPC,3)
%% Optimization
M=MPC.M; %number of line
N=MPC.N; %number of bus
% yalmip('clear')
s = sdpvar(N,1);
sline = sdpvar(M,1);
V_R = sdpvar(N,1);
V_I = sdpvar(N,1);
I_R = sdpvar(N,1);
I_I = sdpvar(N,1);


% Define constraints 


%% Start YALMIP
bus_con=ConCell(MPC);
% ALL bus
 for i=1:N
 Constraints = [ 0 <= s(i) <= 1];
 Conect=cell2mat(bus_con(i));
 GR=0;GI=0;BR=0;BI=0;
 for j=1:length(Conect)
 GR=(V_R(i)-V_R(Conect(j)))'*Gfind(i,Conect(j),MPC)+GR;
 GI=(V_I(i)-V_I(Conect(j)))'*Gfind(i,Conect(j),MPC)+GI;
 BR=(V_R(i)-V_R(Conect(j)))'*Bfind(i,Conect(j),MPC)+BR;
 BI=(V_I(i)-V_I(Conect(j)))'*Bfind(i,Conect(j),MPC)+BI;
 end
 Constraints = [Constraints, I_R(i)==GR+BI,I_I(i)==BR-GI];
 end
 %% Needs to be linearized
 %for i=1:M
 %    a=MPC.branch(i,1);
 %    b=MPC.branch(i,2);
 %    Constraints=[Constraints,MPC.branch(i,5)>=(v_R(a)-v_R(b))'*Gfind(a,b,MPC)+(v_I(a)-v_I(b))'*Gfind(a,b,MPC)+(v_R(a)-v_R(b))'*Bfind(a,b,MPC)-(v_I(a)-v_I(b))'*Bfind(a,b,MPC)]
 %    Constraints = [Constraints, 0 <= sline(i) <= 1];
 %end
%%
for i=MPC.GFM
     Constraints = [Constraints, s(i)*V_R(i)==MPC.bus(i,5), s(i)*V_I(i)==MPC.bus(i,6)];
     Constraints = [Constraints, MPC.Imax >= s(i)*sqrt((I_R(i))^2+(I_I(i))^2)];
end
%for i=MPC.GFL
%     Constraints = [Constraints, s(i,1)*I_R(i,1)==MPC.bus(i,5), s(i,1)*I_I(i,1)==MPC.bus(i,6)];
%     Constraints = [Constraints, MPC.Vmin <= s(i,1)*sqrt((V_R)^2+(V_I)^2), MPC.Vmax >= s(i,1)*sqrt((V_R(i,1))^2+(V_I(i,1))^2)]; 
%end
i=MPC.INV
F=[(1-s(i))'*(MPC.C+I_R(i)+I_I(i))]
options = sdpsettings('solver','bmibnb');
sol = optimize(Constraints,F,options);
% for i=NL
%     Constraints = [Constraints, s(i,1)==1, MPC.Vmin <= sqrt((V_R)^2+(V_I)^2), MPC.Vmax >= sqrt((V_R(i,1))^2+(V_I(i,1))^2)];
% end
% for i=F
%     Constraints = [Constraints, s(i,1)==1, V_I(i,1)==0, V_R(i,1)==0, sqrt((I_I(i,1)+I_R(i,1))^2)>=MPC.bus(i,7)];
% end
%  %sl <= 1, 0 <= sl

