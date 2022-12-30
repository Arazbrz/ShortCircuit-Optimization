clear
clc
addpath([cd '\Functions'])
addpath([cd '\Functions\graph_cal'])
%% Dataset Input
%%%%%    bus name  inverter  L_R   L_i                     base voltage R  base voltage I
MPC.bus=[1           2       10     2    1     0     50     1              0;
         2           0       10     2    0     0     50     1              0;
         3           0       10     2    0     0     50     1              0;
         4           0       10     2    0     0     50     1              0;
         5           1       10     2    20    1     50     1;
         6           1       10     2    20    1     50     1];
MPC.branch=[1 2 0.0575259116172393	0.0293244885684409 100 ;
            2 3 0.307595167324284	0.156667639990117 100;
            2 4 0.228356655660625	0.116299673811859 100;
            3 4 0.237777927519847	0.121103898534774 100;
            3 5 0.510994811437299	0.441115179103993 100;
            4 6 0.116798814042811	0.386084968641515 100;
    ];
% Impedance to suseptance
IMP=MPC.branch(:,4)+i*MPC.branch(:,5)
AD=1./IMP
MPC.branch(:,3)=real(AD)
MPC.branch(:,4)=imag(AD)
%
MPC.N=height(MPC.bus)
MPC.M=height(MPC.branch)
% Parameters
MPC.Imax=100
MPC.C=1000;
MPC.Vmin=0.9;
MPC.Vmax=1.1;
name=mfilename
MPC=seperatebus(MPC)
save(['MPC' name],'MPC');
