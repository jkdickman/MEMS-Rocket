%does the integration to calculate wetted area, planform area, and volume
%(esp for ogives)


%basically a cone at this point, so use cone's equations
if (param < 0.001)
 noseConeVolume = (1/3)*noseConeHeight*(bodyDiameter/2)^2*pi; %assuming cone for now
 noseConeWettedArea = pi*sqrt( (bodyDiameter/2)^2 + noseConeHeight^2)*bodyDiameter/2;
 noseConePlanformArea = (1/2)*bodyDiameter* noseConeHeight; %assume for trangle for sim test 1
end

[noseConeWettedArea, noseConePlanformArea, ~, noseConeVolume, ~] = integrate(noseConeHeight, bodyDiameter/2, param, noseConeThickness); 



%based on integrate function, line 324 of symmetricComponent.java
function [wetArea, planformArea, volume, fullVolume, cgAxial] = integrate(length,baseRadius, param, thickness)
%setting intial values, these will be integrated
    wetArea = 0; %this will mulitply value by pi
    planformArea = 0;
    volume = 0; 
    fullVolume = 0; 
    cgx = 0; 
    
    
    divisions = 100; %larger, the more precise. Riemann sum stuff basically
    deltaLength = length/divisions; % we are iterating over length of nosecone (finding areas and volumes at dif heights of nosecone)

    r1 = 0; 
    for i = 1:divisions
        r2 = getInstantenousRadius(deltaLength*i, length, baseRadius, param); 
        hyp = hypot(r2-r1, deltaLength);
    
        dV = 0; 
        dFullV = pi/3* deltaLength * (r1*r1+r1*r2+r2*r2); 
    
        %assume nosecone not filled (has some finite wall thickness
        height = thickness*hyp/deltaLength; 
         if r1< height || r2 < height
             dV = dFullV;
             inner = 0;  %used for inertia

         else 
             dV = max(pi*deltaLength*height*(r1+r2-height), 0);
             inner = max(outer-height, 0); %used for ineria
         end 
    
         fullVolume = fullVolume + dFullV; 
         volume = volume + dV; 
         cgx = cgx + (deltaLength*i + deltaLength/2) *dV; 
    
         wetArea = wetArea + hyp*(r1+r2); 
         planformArea = planformArea + deltaLength*(r1+r2); 

         %inertia, from Symmetric component 433
         outer = (r1+r2)/2; 
         rotationalInertia = dV *(outer.^2 + inner.^2)/2;
         longitudinalInertia = dV*((1/4*(outer.^2+inner.^2) + 1/12*(deltaLength.^2))+ (deltaLength*(i-1/2)).^2 );
         %my understanding of equation above, follows form 1/4R^2 + 1/12L^2
         %for cylinder, and the last term uses parallel axis theorem to
         %shift to base of nosecone. All values are multiplied by mass at
         %the end

         %not totally done yet (need to adjust to Cg). 

    
         r1 = r2;
    
    end 
    
        wetArea = wetArea * pi; 
        cgAxial = cgx/volume; 



end 




%based on getradius ,method, line 853 of Transition.java file in open
%rocket. Doesn't need length, radius, or param input, only x position
%(relative to nosecone)
function radius = getInstantenousRadius(x, length, baseRadius, param)  
   

    R = sqrt(  (length^2+baseRadius^2) * ( ((2-param)*length)^2 + (param*baseRadius)^2 ) / (4*(param*baseRadius)^2 ) );
    L = length/param; 
    y0 = sqrt(R*R-L*L); 
    radius = sqrt(R*R - (L-x)*(L-x)) - y0; 

    
end