%Note, all methodology originated from Open rocket's implementation, and
%based on their thesis/source code

%assumptions: subsonic flight, trapezoidal fins, wind is negligble,assume
%only 4 components, nosecone, cylinderical body, canards, and fins



%potential sources of error: 
%1) position x is defined relative to what (aerodynamic pitch/Cp section) I assume nose cone but not sure?


%notes
%1) sin(AOA)/AOA will be indeterminate at AOA = 0. Thus, follow wut open
%rocket does, and check the AOA variable ( make its value 1 if AOA < 0.001)
%2) when user defines fin, probably best to define it using 4 points? 



%All inputs to the flight sim
%maybe also create a plot of the diagram of a rocket
length = 3; 
mass = 4; 

flightSim = sim("FlightSim.slx");
output1 = flightSim.yout{1}.Values.Data; %scuffed way to get the data, value in {} is port data
disp(output1)