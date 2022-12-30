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
v_R = sdpvar(N,1);
v_I = sdpvar(N,1);
i_R = sdpvar(N,1);  %line currents Real
i_I = sdpvar(N,1);  %line currents Imag
I_Rload = sdpvar(length(MPC.NL),1);% mpc.bus(i,3)
I_Iload = sdpvar(length(MPC.NL),1); %mpc.bus(i,4)
i_RINV = sdpvar (length(MPC.INV),1);
i_IINV = sdpvar (length(MPC.INV),1);
i_RFault = sdpvar(length(MPC.F),1);
i_IFault = sdpvar(length(MPC.F),1);

%% Define constraints 
% each constraint is valid for certain buses or branches
% we extract these sets of buses and branches from MPC
% we write a for code for that set to avoid adding multiple similar
% constraits

%% ALL bus including power flow, binaries for bus
 for i=1:N
    Constraints = [ 0 <= s(i) <= 1]; % CONSTRAINT binary
    %Conect=cell2mat(bus_con(i)); % convert cell to variable. done.  
    Conect=bus_con{i,1};
    GR=0;GI=0;BR=0;BI=0; 
    for j=1:length(Conect) %%%% check
        GR=(v_R(i)-v_R(Conect(j)))'*Gfind(i,Conect(j),MPC)+GR; % sum of power flows to a certain bus G -real
        GI=(v_I(i)-v_I(Conect(j)))'*Gfind(i,Conect(j),MPC)+GI; % sum of power flows to a certain bus G - imag
        BR=(v_R(i)-v_R(Conect(j)))'*Bfind(i,Conect(j),MPC)+BR; % sum of power flows to a certain bus B - real
        BI=(v_I(i)-v_I(Conect(j)))'*Bfind(i,Conect(j),MPC)+BI; % sum of power flows to a certain bus B - imag
    end
 i_R(i)==GR+BI;
 i_I(i)==BR-GI;
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
     Constraints = [Constraints, i_R(i) + i_RINV(i) == 0 ,i_I(i) + i_IINV(i) == 0]
     Constraints = [Constraints, s(i)*v_R(i)==MPC.bus(i,8), s(i)*v_I(i)==MPC.bus(i,9)]; %This has to be checked .9<s*v_r<1.1
     Constraints = [Constraints, MPC.Imax >= s(i)*sqrt((i_R(i))^2+(i_I(i))^2)];
end

%% For GFL
for i=MPC.GFL
      Constraints = [Constraints, i_R(i)+i_RINV(i) == 0 ,i_I(i)+i_IINV(i) == 0]
      Constraints = [Constraints, s(i)*i_R(i)==MPC.bus(i,5), s(i)*i_I(i)==MPC.bus(i,6)]; %%
      Constraints = [Constraints, MPC.Vmin <= s(i)*sqrt((v_R(i))^2+(v_I(i))^2) <= MPC.Vmax]; 
%
end

%% for i=NL 
 for i=MPC.NL
      Constraints = [Constraints, i_R(i) + I_RLoad(i) == 0, i_I(i) + I_ILoad(i) == 0 ]
      Constraints = [Constraints, s(i)==1, MPC.Vmin <= sqrt((v_R(i))^2+(v_I(i))^2) <= MPC.Vmax ]; %%%Check%%%
 end
 
%% for i=F (F-NL, F-GFM, F-GFL)
Imaxinv=0
if  MPC.F == 1 || MPC.F == 3 || MPC.F == 5
  Imaxinv = Itreshinv; %corect the parameter Itreshinv and Imaxinv
else Imaxinv=0;   
end
 for i=MPC.F
      Constraints = [Constraints, i_RFault(i) + i_R(i) + Imaxinv == 0, i_IFault(i) + i_I(i) + Imaxinv == 0] % IR_fault=v_R/Rfault, II_fualt=v_i/
      Constraints = [Constraints, s(i)==1, v_I(i)==0, v_R(i)==0, sqrt((i_I(i)+i_R(i))^2) >= MPC.bus(i,7)] %%%Check%%%
      Constraints = [Constraints,  sqrt((i_RFault(i)+i_IFault(i))^2) >= Xtresh ] %Corect the parameter name Xtresh
 end
%  %sl <= 1, 0 <= sl

%% Objective
 For Inverters=GFM+GFL (Objective Function)
for i=MPC.INV
F=F+(1-s(i))'*(MPC.C+i_R(i)+i_I(i)); %defevtive
end



%% Solve
options = sdpsettings('solver','bmibnb'); % set optimization functions
sol = optimize(Constraints,F,options);

