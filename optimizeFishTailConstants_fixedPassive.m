%Optimize fish tail input gait with fixed suboptimal passive coefficients
clear all;
%Make sure MatLab knows where sysplotter is and relevant folders have been
%added to the path
initializeWorkspace;

%Define red color for plotting
rossred = [234 14 30]/255;
%Load fish tail model
load('SimPrep_FlagellaTailTapered.mat');
%Make sure that the model has functions for estimating motility map and the
%mass metric
s = fitConnectionAndMetric(s);
funs = s.funs;

%Provide starting guesses for gait parameters
%k = 0.025;
%b = 0.005;
k = s.physics.k;
b = s.physics.b;
amp = 1.4;
w = 1;

%Set optimization function
optFun = @(x) getDisp(x,k,b,funs);

%Vector of parameters for initial guess at optimal gait
x0 = [1,0,0,1];
%Set optimization options
options = optimset('Display','iter','MaxFunEvals',200);

%Run optimization
tic;
optimalVals = fminsearch(optFun,x0,options);
toc

%Perform simulation of resulting optimal gait to see how it does
x = optimalVals;
y0 = [0,x(1),0,0,0,x(2),x(3),0,0,x(4)*2*pi]';
p = makeGait(y0);
T = 1/x(4);
[displ,cost,angles,~] = simulate2DPassiveSwimmer(p,T,funs,k,b,0,0);

%See gait speed at unit power (makes less sense for systems with fixed
%passive coefficients but it's useful for comparison with
%optimal-coefficient gait)
unitPowerSpeed = displ/(cost^(1/3));

%Define reward function for optimization
function val = getDisp(x,k,b,funs)

    %If gait parameters leave bounds of allowed motion, set reward to 0
    if abs(x(1)) > 2*pi/3 || abs(x(4)) > 1.95
        val = 0;
        return;
    end

    %Gait period is inverse of gait frequency
    T = 1/x(4);
    %Define gait parameter vector
    y0 = [0,x(1),0,0,0,x(2),x(3),0,0,x(4)*2*pi]';
    %Convert gait to time-parameterization
    p = makeGait(y0);

    %Simulate the gait
    [displ,cost,angles,~] = simulate2DPassiveSwimmer(p,T,funs,k,b,0,0);

    %Reward is gait speed
    %val = -abs(displ/T);

    %Reward is gait mechanical efficiency
    %val = -abs(displ/(cost));

    %Reward is gait metabolic efficiency
    metabolicRate = 0.05;
    val = -abs(displ/(cost + metabolicRate*T));

end
    

    