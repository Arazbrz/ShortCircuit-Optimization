function MPC=Faultedbus(MPC,n)
MPC.bus(n,2)=3;
MPC.bus(n,3)=0;
MPC=seperatebus(MPC);
end
