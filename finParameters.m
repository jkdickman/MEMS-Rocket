%Inputs: provide 4 points which dictate fin geometry. Assuming Trapezoidal
%Geoemtry

%terminology note: root implies base of the fin, or along the rocket body,
%while tail is the opposite end. Front implies closer to nosecone, while
%back implies closer to base



%Inputs
  % P_frontRoot = [0;208/1000];
  % P_backRoot = [0;0/1000];
  % P_frontTrail = [140/1000;68/1000];
  % P_backTrail =[140/1000;0/1000];
  % 
    %default open rocket fin setup
  % P_frontRoot = [0;10/100];
  % P_backRoot = [0;5/100];
  % P_frontTrail = [3/100;7.5/100];
  % P_backTrail =[3/100;2.5/100];
  % 
  %  P_frontRoot = [0;15/100];
  % P_backRoot = [0;5/100];
  % P_frontTrail = [10/100;8/100];
  % P_backTrail =[10/100;3/100];


  %x axis is span, y axis is height
  P_frontRoot = [0;4.9/100];
  P_backRoot = [0;.4/100];
  P_frontTrail = [2/100;2.4/100];
  P_backTrail =[2/100;.4/100];
  backOffset = -0.4/100; % difference between rocket base and back root. (if back root further back than base, positive)


%General setup values
% bodyLength = 0.4; 
% noseConeHeight = .15; 
% bodyDiameter = 5/100; 
% finLeadingEdgeCGxlength = (45-42/5)/100; 

finLeadingEdgeCGxlength = (45-42/5)/100;  %idt this matters

%General calculations
finRootChord = abs(P_frontRoot(2)-P_backRoot(2));
finTailChord = abs(P_frontTrail(2)-P_backTrail(2));
finX_t = P_frontRoot(2) - P_frontTrail(2); 
finSpan = abs(P_frontTrail(1)- P_frontRoot(1)); 
finArea = (finRootChord+finTailChord)*finSpan/2; %pretty sure this is also planform area
% finAerodynamicLength = P_frontRoot(2) - P_backTrail(2); %used in fin friction drag calc, i believe should be full fin length
finCentroidAxial = finSpan/3 * ( (finRootChord + 2*finTailChord)/(finRootChord + finTailChord) ) - backOffset; 

frontSweepAngleRefVector1 = [1;0];
frontSweepAngleRefVector2 = P_frontTrail-P_frontRoot;
finFrontSweepAngle = acos(dot(frontSweepAngleRefVector1, frontSweepAngleRefVector2) / (norm(frontSweepAngleRefVector1) * norm(frontSweepAngleRefVector2)));


%Chord related calculations
P_halfChordRoot = (P_frontRoot+P_backRoot)/2;
P_halfChordTrail = (P_frontTrail+P_backTrail)/2;

midChordAngleRefVector1 = [1;0];
midChordAngleRefVector2 = P_halfChordTrail-P_halfChordRoot;
finMidChordSweepAngle = acos(dot(midChordAngleRefVector1, midChordAngleRefVector2) / (norm(midChordAngleRefVector1) * norm(midChordAngleRefVector2)));



%Mean Aerodynamic Chord (MAC) Calculations. Based on Open Rocket equations
%3.30-3.32. Simplifications of these expressions for trapezoids can be found
%here: https://www.pmac-rc.org/Files/MAC.pdf

%define chord length as function of span (or x position)
leadingEdgeCoefficients = polyfit( [P_frontRoot(1), P_frontTrail(1)],[P_frontRoot(2), P_frontTrail(2)], 1);
trailingEdgeCoefficients = polyfit( [P_backRoot(1), P_backTrail(1)],[P_backRoot(2), P_backTrail(2)], 1);
chordLength  = @(x) ( leadingEdgeCoefficients(1)-trailingEdgeCoefficients(1) )*x + (leadingEdgeCoefficients(2)-trailingEdgeCoefficients(2) );


%calculate MAClength f(x)= c^2(x)
chordLengthFunction = @(x) (chordLength(x)).^2;
finMACLength = integral(chordLengthFunction, 0, finSpan)/finArea;

%calculate MacSpanwise position f(x) = x*c(x)
chordLengthFunction = @(x) (chordLength(x)).*x;
finMACSpanwisePosition = integral(chordLengthFunction, 0, finSpan)/finArea;
radialMACPosition = finMACSpanwisePosition + bodyDiameter/2; 


%calculate MAC effective Leading Edge location f(x) = X_le(x)*c(x) 
leadingEdgePosition = @(x) leadingEdgeCoefficients(1)*x; %relative to top if leading edge (the P_frontRoot point)
finMACLeadingEdgeLocationFunction = @(x) leadingEdgePosition(x).*chordLength(x); 

%IMPORTANT note, this value is negative, but should be positive realtive to
%nosecone (since further from nosecone), hence the abs() function
%iirc, distance from top root point of fin to intersection of MAC and
%leading edge
finMACLeadingEdgeLocation = abs( integral(finMACLeadingEdgeLocationFunction, 0, finSpan)/finArea ) ;
axialDistanceMACCGx = abs(finMACLeadingEdgeLocation) + finLeadingEdgeCGxlength;

%Distance from MAC middle to nosecone
finLeadingEdgeNoseConeDistance = bodyLength + noseConeHeight - finRootChord + backOffset; %distance from leading edge to noseCone, used for fin CP, (same thing as finMACNoseconeAxialDistance) 
finMACNoseconeAxialDistance = finLeadingEdgeNoseConeDistance + finMACLeadingEdgeLocation+ 1/2*finMACLength ; %line 225 FinSetCalc.java Openrocket, detemrines fin pitch damping


   % plotFin (P_frontRoot, P_backRoot, P_frontTrail, P_backTrail, P_halfChordRoot, P_halfChordTrail,finMACLength, finMACSpanwisePosition, finMACLeadingEdgeLocation);


function [] = plotFin (P_frontRoot, P_backRoot, P_frontTrail, P_backTrail, P_halfChordRoot, P_halfChordTrail, finMACLength, finMACSpanwisePosition, finMACLeadingEdgeLocation)

    hold on
    plot([P_frontRoot(1),P_backRoot(1), P_backTrail(1),  P_frontTrail(1),P_frontRoot(1)] , [P_frontRoot(2), P_backRoot(2),P_backTrail(2), P_frontTrail(2),P_frontRoot(2)] );
  
    %mid Chord Plotting
    plot( [P_halfChordRoot(1),P_halfChordTrail(1)], [P_halfChordRoot(2),P_halfChordTrail(2)])

    %quarter Chord Plotting
    plot( [P_frontRoot(1), P_frontTrail(1)], [P_frontRoot(2)- (P_frontRoot(2)-P_backRoot(2))/4, P_frontTrail(2)-(P_frontTrail(2)-P_backTrail(2))/4]) 

    %plots cross sections for MAC Span purposes
    % plot( [P_frontRoot(1),P_backTrail(1)], [P_frontRoot(2) + (P_frontTrail(2)-P_backTrail(2)),P_backTrail(2)- (P_frontRoot(2)-P_backRoot(2))])
    % plot( [P_backRoot(1),P_frontTrail(1)], [P_backRoot(2) - (P_frontTrail(2)-P_backTrail(2)),P_frontTrail(2)+ (P_frontRoot(2)-P_backRoot(2))])

    %MAC plotting
    plot([finMACSpanwisePosition,finMACSpanwisePosition], [-finMACLeadingEdgeLocation+P_frontRoot(2),-finMACLeadingEdgeLocation+P_frontRoot(2)-finMACLength])
    grid on
    axis equal
 
end 



