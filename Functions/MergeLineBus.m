function MPC=MergeLineBus(MPC)
addpath([cd 'Functions\graph_cal'])
bus_con=ConCell(MPC)
 for j=1:length(MPC.bus)
   for i=1:3
   MPC.busU{j,i}=MPC.bus(j,i);
   end
   MPC.busU{j,4}=bus_con{j};
 end
end