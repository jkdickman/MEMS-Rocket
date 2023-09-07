 clear; clc

%Note, all methodology originated from Open rocket's implementation, and
%based on their thesis/source code

%assumptions: subsonic flight (<.8/.9), trapezoidal fins , wind is negligble,assume
%only 4 components, nosecone (ogive or conical), cylinderical body, canards, and fins (only 3
%or 4)
%relatively small angles of attack (FOR open rocket, line 253 of
%BarrowmanCalculator.java, 17.5 is defined for threshold of warning, altho 10 is prob best)

%Current test motor is: AEROTECH 29MM HP SU DMS MOTOR - G8ST-P
% https://www.apogeerockets.com/Rocket-Motors/AeroTech-Motors/29mm-Motors-Single-Use/Aerotech-29mm-HP-SU-DMS-Motor-G8ST-P
%Motor Thrust Curve: https://www.thrustcurve.org/simfiles/60159fcfb94d0e00040a8435/


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


%--------------------------SIM INPUTS -----------------------


% Sim test 1: relatively low mach number, this doesn't test 
% 1) inindividual CP interpolation form .5-2, 
%2) the AOA = 0 case (testing the switch statements)
%3) straight drag to axial drag conversion
%) test different fin numbers (roll angle affects pitch in the less than 3
%case)
%) 

%atmopshere inputs
    airKinematicViscosity= 1.48*10^-5; 
    airDensity =1.2250 ; 

 %Motor Inputs
     initialMotorCG = 45/100; %relative to Nosecone, along axial direction
     initialMotorMass = 0.2; 

 %Motor inputs for G8
    motorInitialPropMass = 83/1000;
    motorInitialTotalMass = 154/1000; 
    motorCasingMass = motorInitialTotalMass - motorInitialPropMass; 
    motorTotalImpulse = 129.9; 

    motorLength = 156/1000; 
    motorCg = [motorLength/2, 0,0];
    motorDiameter = 29/1000; 
    casingThickness = 3/1000; %arbitrary num rn, used for inertia

    %assumes Cg is along middle of rocket, and halfway up the motor (from base), 
    % same for empty motor (this second assumption is sus)



%Full rocket inputs
    rocketLength = (20+6)/100; %nosecone+body+fin(length of fin that extends past base of body)
    rocketNonMotorCg = [rocketLength - 15.3/100, 0, 0]; %arbitrary value for now, from base of rocket
    rocketVector = [rocketLength, 0, 0]; %used to represent rocket as vector in space
    pitchCenterX = 0;  %radial position of Center of gravity (i think), prob not but in open rocket its always 0

    
 %rocket body inputs
    bodyLength = 20/100; 
    bodyDiameter = 2/100;
    refArea = bodyDiameter^2*pi/4;
    bodyPlanformArea = bodyDiameter*bodyLength; 
    bodyRoughness = 60*10^-6;%based on Table 3.2 Open Rocket
    bodyMass = 12/1000; %arbitrary right now

  
%nosecone
    noseConeHeight = 6/100; 
    param = 1; 
    noseConeThickness = 0.2/100; 
    noseConeMass = 5/1000; 

    %defined a variable with numeric inputs.  
    % 1 -7 correspond with the shapes Figure 3.11 Open rocket doc)
    % 8 means there is a join angle, which is provided separately 
    % (assumed 0 if no joint angle). 
    noseConeType = 8; 
    noseConeJoinAngle = pi/2 - atan(noseConeHeight/(bodyDiameter/2));

%fin geometry
    run('finParameters.m'); %input 4 points which define trapezoidal fin

%fin (non geometry)
    finThickness = 0.15/100; 

    %finProfileType is a string with 1 of 3 values. 1 for "Round", 2 for "Airfoil", or 3 for "Square".   
    finProfileType = 3; 
    finCount = 4; 
    finCantAngle = deg2rad(0); 
    singleFinMass = 1/1000; 
    totalFinMass = singleFinMass * finCount; 


%center of Gravity
    rocketNonMotorMass = noseConeMass + bodyMass + totalFinMass; % in KG
    rocketInitialCg = (rocketNonMotorMass*rocketNonMotorCg + motorInitialTotalMass*motorCg)/ (rocketNonMotorMass+motorInitialTotalMass);
    rocketFinalCg = (rocketNonMotorMass*rocketNonMotorCg + motorCasingMass*motorCg)/ (rocketNonMotorMass+motorCasingMass);

%noseCone 2.0:  values for wet Area, planform Area, volume, and inertia
    noseConeParameters(); 

%inertia
    InertiaParameters(); 

    

%Launch Lug
    launchLugLength = 0; 
    launchLugOuterDiameter = 0; 
    launchLugInnerDiameter = 0; 

    
%Variables of state
    machNum = 0;
    rocketVelocityMag = machNum*340.17;  %340 more accurate at t=20 C

    AOA = deg2rad(0); 
    pitchRate =0;   %rate of change of AOA
    yawAngle =  0; 
    yawRate = 0; 
    % rollAngle = 0; 
    windAngle = 0; 
    rollRate = 0; 
    cYaw =0;  %one of those idk variables 

% Sets parameters for blocks in Flight Sum

    % %Aerodyamics block
    set_param('FlightSim/Forces and Rotations/AerodynamicsBlock', 'S', num2str(refArea)); %sets ref aera 
    set_param('FlightSim/Forces and Rotations/AerodynamicsBlock', 'b', num2str(bodyDiameter)); %Sets ref span
    set_param('FlightSim/Forces and Rotations/AerodynamicsBlock', 'cbar', num2str(bodyDiameter)); %Sets ref Length

    %CG Estimate Block
    CGpath = 'FlightSim/Forces and Rotations/CG Calculations/Body Frame CG/Estimate Center of Gravity'; 
     set_param(CGpath, 'fmass', num2str(motorInitialTotalMass+rocketNonMotorMass));
     set_param(CGpath, 'emass', num2str(motorCasingMass+rocketNonMotorMass));


     set_param(CGpath, 'fcg', mat2str(rocketInitialCg'));
     set_param(CGpath, 'ecg', mat2str(rocketFinalCg'));

    % val = get_param('FlightSim/Forces and Rotations/CG Calculations/Estimate Center of Gravity', 'DataTypeOverride_Compiled');
    % disp(val)

     %Quaternion Block
     quaternionPath = 'FlightSim/Forces and Rotations/6DOF (Quaternion)';

     % sets initial rocket CG value (since this value is not origin)
     set_param(quaternionPath, 'xme_0', mat2str(rocketInitialCg));

    % val = get_param('FlightSim/Forces and Rotations/6DOF (Quaternion)', 'DialogParameters');
    % disp(val)


