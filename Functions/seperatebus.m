function MPC=seperatebus(MPC) % seperating
MPC.GFM=find(MPC.bus(:,2)==2);
MPC.GFL=find(MPC.bus(:,2)==1);
MPC.NL=find(MPC.bus(:,2)==0);
MPC.F=find(MPC.bus(:,2)==3);
MPC.ALL=MPC.bus(:,1);
MPC.INV=union(MPC.GFL,MPC.GFM);
