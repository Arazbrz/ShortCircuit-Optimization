clear classes
clear all
clc
%% Load Functions 
addpath([cd '\Functions']) % add different functions
addpath([cd '\Functions\graph_cal'])
addpath([cd '\Test Cases'])
%% Load Case 
load('Test Cases\MPCSixbus.mat') % Load case
%% add fault 
MPC=Faultedbus(MPC,3) % add fualt to certain bus (second argument)
%% Test case preprocess
M=MPC.M; % extract number of lines from test case
N=MPC.N; % extract number of buses from test case
bus_con=ConCell(MPC); % My internal function to define bus connections
% bus_con(i)=cell


yalmip('clear')
%% Define variables 
% for syntax and more info YALMIP website
% The variables should match the variables in the document
s = sdpvar(N,1);
sb = sdpvar(M,1);
V_R = sdpvar(N,1);
V_I = sdpvar(N,1);
I_R = sdpvar(N,1);
I_I = sdpvar(N,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Define constraints 
% each constraint is valid for certain buses or branches
% we extract these sets of buses and branches from MPC
% we write a for code for that set to avoid adding multiple similar
% constraits

%% ALL bus including power flow, binaries for bus
 for i=1:N
 Constraints = [ 0 <= s(i) <= 1]; % CONSTRAINT binary


 Conect=cell2mat(bus_con(i)); % convert cell to variable  
 GR=0;GI=0;BR=0;BI=0; 
 for j=1:length(Conect) %%%% check
 GR=(V_R(i)-V_R(Conect(j)))'*Gfind(i,Conect(j),MPC)+GR; % sum of power flows to a certain bus G -real
 GI=(V_I(i)-V_I(Conect(j)))'*Gfind(i,Conect(j),MPC)+GI; % sum of power flows to a certain bus G - imag
 BR=(V_R(i)-V_R(Conect(j)))'*Bfind(i,Conect(j),MPC)+BR; % sum of power flows to a certain bus B - real
 BI=(V_I(i)-V_I(Conect(j)))'*Bfind(i,Conect(j),MPC)+BI; % sum of power flows to a certain bus B - imag
 end

 Constraints = [Constraints, I_R(i)==GR+BI,I_I(i)==BR-GI]; % CONSTRAINT load flow
 end

%% All lines including capacity constraints (not now)
 %for i=1:M
 %    a=MPC.branch(i,1);
 %    b=MPC.branch(i,2);
 %    Constraints=[Constraints,MPC.branch(i,5)>=(v_R(a)-v_R(b))'*Gfind(a,b,MPC)+(v_I(a)-v_I(b))'*Gfind(a,b,MPC)+(v_R(a)-v_R(b))'*Bfind(a,b,MPC)-(v_I(a)-v_I(b))'*Bfind(a,b,MPC)]
 %    Constraints = [Constraints, 0 <= sb(i) <= 1];
 %end
%% For GFM
for i=MPC.GFM
     Constraints = [Constraints, s(i)*V_R(i)==MPC.bus(i,5), s(i)*V_I(i)==MPC.bus(i,6)];
     Constraints = [Constraints, MPC.Imax >= s(i)*sqrt((I_R(i))^2+(I_I(i))^2)];
end
%% For GFL
%for i=MPC.GFL
%     Constraints = [Constraints, s(i,1)*I_R(i,1)==MPC.bus(i,5), s(i,1)*I_I(i,1)==MPC.bus(i,6)];
%     Constraints = [Constraints, MPC.Vmin <= s(i,1)*sqrt((V_R)^2+(V_I)^2), MPC.Vmax >= s(i,1)*sqrt((V_R(i,1))^2+(V_I(i,1))^2)]; 
%end
%% for i=NL 
% for load
%     Constraints = [Constraints, s(i,1)==1, MPC.Vmin <= sqrt((V_R)^2+(V_I)^2), MPC.Vmax >= sqrt((V_R(i,1))^2+(V_I(i,1))^2)];
% end
%% for i=F 
% for fualt
%     Constraints = [Constraints, s(i,1)==1, V_I(i,1)==0, V_R(i,1)==0, sqrt((I_I(i,1)+I_R(i,1))^2)>=MPC.bus(i,7)];
% end
%  %sl <= 1, 0 <= sl
%% Objective
% For Inverters=GFM+GFL (Objective Function)
for i=MPC.INV
F=F+(1-s(i))'*(MPC.C+I_R(i)+I_I(i));
end


%% Solve
options = sdpsettings('solver','bmibnb'); % set optimization functions
sol = optimize(Constraints,F,options);

