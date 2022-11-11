function [c,ceq] = constraintFcn(optimInput)
% Example:
% Constrain a solution to the region
% x^2 + y^2 <= 5
% x^2 + y^2 >= 2
% y = x^3

% Edit the lines below with your calculation
% Note, if no inequality constraints, specify c = []
% Note, if no equality constraints, specify ceq = []
x = optimInput(1);
y = optimInput(2);
c(1) = x^2 + y^2 - 5;
c(2) = 2 - x^2 - y^2;
ceq = y - x^3;
end