%Inputs: provide 4 points which dictate fin geometry. Assuming Trapezoidal
%Geoemtry

%terminology note: root implies base of the fin, or along the rocket body,
%while tail is the opposite end. Front implies closer to nosecone, while
%back implies closer to base

%Inputs
P_frontRoot = [0;10];
P_backRoot = [0;5];
P_frontTrail = [2;6];
P_backTrail =[2;4];

%General calculations
finRootChord = abs(P_frontRoot(2)-P_backRoot(2));
finTailChord = abs(P_frontTrail(2)-P_backTrail(2));
finX_t = P_frontRoot(2) - P_frontTrail(2); 
finSpan = abs(P_frontTrail(1)- P_frontRoot(1)); 
finArea = (finRootChord+finTailChord)*finSpan/2; %pretty sure this is also planform area


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

%calculate MAC effective Leading Edge location f(x) = X_le(x)*c(x) 
leadingEdgePosition = @(x) leadingEdgeCoefficients(1)*x; %relative to top if leading edge (the P_frontRoot point)
finMACLeadingEdgeLocationFunction = @(x) leadingEdgePosition(x).*chordLength(x); 

%IMPORTANT note, this value is negative, but should be positive realtive to
%nosecone (since further from nosecone)
finMACLeadingEdgeLocation = integral(finMACLeadingEdgeLocationFunction, 0, finSpan)/finArea;
 




plotFin (P_frontRoot, P_backRoot, P_frontTrail, P_backTrail, P_halfChordRoot, P_halfChordTrail,finMACLength, finMACSpanwisePosition, finMACLeadingEdgeLocation);


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
    plot([finMACSpanwisePosition,finMACSpanwisePosition], [finMACLeadingEdgeLocation+P_frontRoot(2),finMACLeadingEdgeLocation+P_frontRoot(2)-finMACLength])
    grid on
 
end 


