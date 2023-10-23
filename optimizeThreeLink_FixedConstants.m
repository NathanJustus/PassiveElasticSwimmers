%Generate surface of optimal gaits across various input power limits and
%gait frequencies.  This takes a long time to run
clear all;
%Make sure MatLab knows where sysplotter is and relevant folders have been
%added to the path
initializeWorkspace;

%Define red color for plotting
rossred = [234 14 30]/255;
%Load plotting prep data
load('SimPrep_ThreeLink.mat');
s = fitConnectionAndMetric(s);

%Define space of power limits and gait frequencies
powers = linspace(.25,2.5,13);
freqs = linspace(1,2.5,13);

%Make storage for results
[FREQS,POWERS] = meshgrid(freqs,powers);
SPEEDS_lowstart = zeros(size(FREQS));
SPEEDS_highstart = zeros(size(FREQS));
NONLINS_lowstart = zeros(size(FREQS));
NONLINS_highstart = zeros(size(FREQS));
GAITS_lowstart = cell(size(FREQS));
GAITS_highstart = cell(size(FREQS));

%Set definition of passive behavior and gait limits
k = s.physics.k;
b = s.physics.b;
funs = s.funs;
lb = [0,-.3,-.3];
ub = [2,.3,.3];

%Sweep space of frequency and power constraints
for i = 1:numel(FREQS)

    %Set gait frequency and max power
    w = FREQS(i);
    T = 1/w;
    maxPower = POWERS(i);
    %Set reward function
    optFun = @(x) getDisp(x,w,maxPower,lb,ub,k,b,funs);

    options = optimset('Display','off','MaxFunEvals',150);

    %Run optimization seeded with a teensy gait
    x0 = [.1,0,0];
    tic;
    disp(i/numel(FREQS));
    disp('Run 1')
    [optimalVals,optimalSpeed] = fminsearch(optFun,x0,options);
    toc

    %Store results
    SPEEDS_lowstart(i) = abs(optimalSpeed);
    NONLINS_lowstart(i) = norm(optimalVals(2:3));
    GAITS_lowstart{i} = optimalVals;

    %Run optimization seeded with a big gait
    x0 = [1.6,.1,.1];
    %Scale down big gait so it's still within power limits
    scaleDown = min(maxPower,2);
    x0 = x0*scaleDown/2;
    tic;
    disp('Run 2')
    [optimalVals,optimalSpeed] = fminsearch(optFun,x0,options);
    toc

    %Store results
    SPEEDS_highstart(i) = abs(optimalSpeed);
    NONLINS_highstart(i) = norm(optimalVals(2:3));
    GAITS_highstart{i} = optimalVals;
end

%Save results of constrained gait optimizations
save('DataFiles/PowerRestrictionOptimalGaits2.mat');

%Reward function for optimizing across constrained power and frequency
function val = getDisp(x,w,maxPower,lb,ub,k,b,funs)

    %Define the gait
    T = 1/w;
    y0 = [0,x(1),0,0,0,x(2),x(3),0,0,w*2*pi]';

    %If gait parameters exceed the limits, set reward to zero
    if any(x<lb) || any(x>ub)
        val = 0;
        return;
    end

    %Simulate the gait
    p = makeGait(y0);
    [displ,cost,angles,~] = simulate2DPassiveSwimmer(p,T,funs,k,b,0,1);

    %If gait execution is too spendy for max power, set reward to zero
    if cost/T > maxPower
        val = 0;
        return;
    end

    %Reward is gait speed
    val = -abs(displ/T);

end
    

    