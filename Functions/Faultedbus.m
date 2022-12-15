function MPC=Faultedbus(MPC,n)
% First argument = testcase, second argument= number of the faulty bus %

MPC.bus(n,2)=3;
MPC.bus(n,3)=0;
MPC=seperatebus(MPC);
end
