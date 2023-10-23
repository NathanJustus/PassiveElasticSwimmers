%Optimize three link behavior and passive constants
function [optimalVals,displ_final,cost_final,angles_final] = optimizeThreeLinkConstants(s)

    %Make sure that model has a defined connection and mass metric
    if ~isfield(s,'funs')
        s = fitConnectionAndMetric(s);
    end
    
    rossred = [234 14 30]/255;
    
    %Define starting guess for optimal parameters
    k = 0.0349;
    b = 0.0052;
    amp = 1.2455;
    w = 1;
    T = 1/w;
    funs = s.funs;
    
    %Set reward function
    optFun = @(x) getDisp(x,w,T,funs);
    
    %Initial conditions
    x0 = [amp,0,0,k,b];
    %Optimization options
    options = optimset('Display','iter','MaxFunEvals',300);
    
    %Run optimization
    tic;
    optimalVals = fminsearch(optFun,x0,options);
    toc
    
    %Simulate optimal gait to check the performance
    x = optimalVals;
    y0 = [0,x(1),0,0,0,x(2),x(3),0,0,w*2*pi]';
    p = makeGait(y0);
    [displ_final,cost_final,angles_final,~] = simulate2DPassiveSwimmer(p,T,funs,x(4),x(5),0,1);

end

%Reward function
function val = getDisp(x,w,T,funs)

    %Define candidate gait
    y0 = [0,x(1),0,0,0,x(2),x(3),0,0,w*2*pi]';
    p = makeGait(y0);

    %Simulate candidate gait
    [displ,cost,angles,~] = simulate2DPassiveSwimmer(p,T,funs,x(4),x(5),0,1);

    %Period at unit power is third root of power at unit period
    T = cost^(1/3);
    %Reward is speed at unit power
    val = -displ/T;

end
    

    