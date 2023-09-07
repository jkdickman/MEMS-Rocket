
%Body inertia
bodyLongitudinalInertia = bodyMass*( ((bodyDiameter/2).^2)/4 + ((bodyLength).^2)/12);
bodyRotationalInertia = bodyMass*(((bodyDiameter/2).^2)/2); 

%Motor inertia: calcualtes the casing and grain separately

%Motor Inertia: Casing
    %Shape is hollow sphere, equations here: https://amesweb.info/inertia/hollow-cylinder-moment-of-inertia.aspx
    motorOuterRadius = motorDiameter/2; 
    motorInnerRadius = motorOuterRadius - casingThickness; 
    % 
    casingLongitudinalInertia = motorCasingMass/12*(3*(motorOuterRadius.^2+motorInnerRadius.^2)+motorLength.^2); 
    casingRotationalInertia = motorCasingMass/2*(motorOuterRadius.^2+motorInnerRadius.^2);

%motor Inertia: grain
    %shape is just a cylinder
    %implementation in simulink, since it changes as mass is lost

%fins
    %based on open rocket implmenetation, finSet.java line 786

    %longitudinal inertia
    length = P_frontRoot(2) - min(P_backRoot(2),P_backTrail(2));
    length2 = length * finArea/finSpan;
    span2 = finSpan * finArea/length; 
    inertia = (span2 + 2*length2)/24; 

    finLongitudinalInertia = inertia + 1/2*(sqrt(span2)/2 + bodyDiameter/2).^2; 
    finLongitudinalInertia = finLongitudinalInertia * singleFinMass * finCount; 

    %Rotational Inertia
    finRotationalInertia = span2/12 + (sqrt(span2)/2 + bodyDiameter/2).^2;
    finRotationalInertia = finRotationalInertia* singleFinMass * finCount;

    rocketRotationalInertia = bodyRotationalInertia + casingRotationalInertia + finRotationalInertia + noseConeLongitudinalInertia;
    %can't do the same for rocket longitudinal inertia, since that needs to
    %be adjusted to Cg

    dIdt = zeros(3); %stand along variable for dIdt for now, FIXME
    
