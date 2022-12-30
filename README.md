# S90-Optimization
 
Folders: 

- Anything in Functions Folder need be imoprted to Main.m - 
- Unused folder is unused for now -
- Test Cases Folder include different test cases, currently we only have the 6 bus model -
- Only the MPC XX .mat file from "Test Cases" is loaded in Main.m -
- XX.m file in "Test Cases is used to make and modify corresponding XX.mat test case" -
- In Main.m first Functions are imported, then Case is imported then Fault is added to the case (choose the faulty bus in the corresponding function) -
- More info on Yalmip: https://yalmip.github.io/tutorial/basics/-
- MPC is the variable for the whole test case -
- Constraints is the variable for the whole constraints -

# To Do List

-* Read YALMIP*-
-* Install Git*-
-* check sections from vraiable to objective*-
-* check document*-
- Capacity Constraint needs to be linearized-
- Find the minimum fault current location -
- Possible approach: define the minimum fault location as a new bus = n' buses -
- If two types exist in one bus => split into two bus with a line with zero impedance-
--------------------------------------------------------------------------------------
#Questions
-* You have not updated the document file, since the KCL for faulted bus is not implemented.