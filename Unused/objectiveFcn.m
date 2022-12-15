function f = objectiveFcn(optimInput)
% Example:
% Minimize Rosenbrock's function
% f = 100*(y - x^2)^2 + (1 - x)^2

% Edit the lines below with your calculation
s = optimInput.busvar(1:length(optimInput.bus),1);
i = optimInput.busvar(1:length(optimInput.bus),2);
sl =optimInput.branchvar(:,1)
f=sum((1-s).*(optimInput.C+i-optimInput.bus(:,4)))+optimInput.C*sum(1-sl)
end