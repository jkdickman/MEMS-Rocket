%Note, all methodology originated from Open rocket's implementation, and
%based on their thesis/source code

%assumptions: subsonic flight, trapezoidal fins , wind is negligble,assume
%only 4 components, nosecone, cylinderical body, canards, and fins
%relatively small angles of attack (FOR open rocket, line 253 of
%BarrowmanCalculator.java, 17.5 is defined for threshold of warning, altho 10 is prob best)



%potential sources of error: 
%1) position x is defined relative to what (aerodynamic pitch/Cp section) I assume nose cone but not sure?
%2) Some values (like Renolds num) need magnitude of velocity, make sure
%that is correctly implemented
%3) assumed wetted area of rocket body is Diamter *L? not sure but idk wut
%else to do
%4) some equaition implementation is different from open rocket code and my
%code (even tho i follow the equations they listed in their document). an
%example is multiplying pitch damping by 3, and not including N when
%calculating fin damping. Also signs of dampning are different....

%notes
%1) sin(AOA)/AOA will be indeterminate at AOA = 0. Thus, follow wut open
%rocket does, and check the AOA variable ( make its value 1 if AOA < 0.001)
%2) when user defines fin, probably best to define it using 4 points? 
    %yeah this is best, and also can derive all pertinent fin values (Like
    %MAC length, Mac radial position, etc. from that) 



%All inputs to the flight sim (non fin geometry related)
length = 3; 
mass = 4; 



run('finParameters.m')

% 
% flightSim = sim("FlightSim.slx");
% output1 = flightSim.yout{1}.Values.Data; %scuffed way to get the data, value in {} is port data
% disp(output1)



