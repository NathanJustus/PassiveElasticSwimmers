%Optimize both gait behavior and passive parameters for the fish tail
%swimmer
clear all;
%Make sure MatLab knows where sysplotter is and relevant folders have been
%added to the path
initializeWorkspace;

rossred = [234 14 30]/255;
%Load fish tail model
load('SimPrep_FlagellaTailTapered.mat');
%Make sure that the model has functions for estimating motility map and the
%mass metric
s = fitConnectionAndMetric(s);
funs = s.funs;

%Provide starting guesses for gait parameters
k = 0.025;
b = 0.005;
amp = 1.4;
w = 1;
T = 1/w;

%Define optimization function
optFun = @(x) getDisp(x,w,T,funs);

%Vector of initial conditions for gait/parameter optimization
x0 = [amp,0,0,k,b];
%Set optimization options
options = optimset('Display','iter','MaxFunEvals',300);

%Run optimization
tic;
optimalVals = fminsearch(optFun,x0,options);
toc

%See how well the optimal gait performs
x = optimalVals;
y0 = [0,x(1),0,0,0,x(2),x(3),0,0,w*2*pi]';
p = makeGait(y0);
[displ,cost,angles,~] = simulate2DPassiveSwimmer(p,T,funs,x(4),x(5),0,0);

%Get optimal gait speed when performed at unit power
unitPowerSpeed = displ/(cost^(1/3));

%Reward function for optimization
function val = getDisp(x,w,T,funs)

    %If passive parameters go below zero, set fitness to zero
    if x(4) < 0 || x(5) < 0
        val = 0;
        return;
    end

    %Vector of gait coefficients
    y0 = [0,x(1),0,0,0,x(2),x(3),0,0,w*2*pi]';
    %Convert vector to time-parameterization of gait
    p = makeGait(y0);
    %Run simulation of passive swimmer with candidate gait and coefficients
    [displ,cost,angles,~] = simulate2DPassiveSwimmer(p,T,funs,x(4),x(5),0,0);
    %Time at unit power is third root of power at unit time
    T = cost^(1/3);
    %Reward function is gait speed at unit power
    val = -displ/T;

end
    

    