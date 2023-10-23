%Like optimizeThreeLink_FixedConstants.m but without the frequency
%constraint
clear all;
%Make sure MatLab knows where sysplotter is and relevant folders have been
%added to the path
initializeWorkspace;

%Load swimmer model
rossred = [234 14 30]/255;
load('SimPrep_ThreeLink.mat');
s = fitConnectionAndMetric(s);

%Set power constraints
powers = linspace(.25,2.5,13);

%Prep storage for optimal gait results for each power
optSpeeds = zeros(1,numel(powers));
optFreqs = zeros(1,numel(powers));
optPowers = powers;

%Define passive joint properties and gait boundaries
k = s.physics.k;
b = s.physics.b;
funs = s.funs;
lb = [0,-.3,-.3,1];
ub = [2,.3,.3,2.5];

%For every power constraint
for i = 1:numel(powers)

    %Set max power and define reward function
    maxPower = powers(i);
    optFun = @(x) getDisp(x,maxPower,lb,ub,k,b,funs);

    options = optimset('Display','off','MaxFunEvals',150);

    %Search for optimal gait with set power limit
    x0 = [.1,0,0,1.5];
    tic;
    disp(i/numel(powers));
    [optimalVals,optimalSpeed] = fminsearch(optFun,x0,options);
    toc

    %Store best result
    optSpeeds(i) = abs(optimalSpeed);
    optFreqs(i) = optimalVals(4);
    optPowers(i) = maxPower;

end

%Save results
save('DataFiles/PowerRestrictionOptimalGaits.mat');

%Define reward function for optimization
function val = getDisp(x,maxPower,lb,ub,k,b,funs)

    %Parameterize gait
    w = x(4);
    T = 1/w;
    y0 = [0,x(1),0,0,0,x(2),x(3),0,0,w*2*pi]';

    %If gait exceeds bounds, set reward to zero
    if any(x<lb) || any(x>ub)
        val = 0;
        return;
    end

    %Simulate the candidate gait
    p = makeGait(y0);
    [displ,cost,angles,~] = simulate2DPassiveSwimmer(p,T,funs,k,b,0,1);

    %If power exceeds bounds, set reward to zero
    if cost/T > maxPower
        val = 0;
        return;
    end

    %Reward is gait speed
    val = -abs(displ/T);

end
    

    