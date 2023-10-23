animationTime = 4;
FPS = 60;
nFrames = animationTime*FPS;

lags = linspace(0,2*pi,60*animationTime);
thetas = linspace(0,2*pi,100);

xs = cos(thetas);
figure(1);
for i = 1:numel(lags)
    clf;
    ys = sin(thetas + lags(i));
    plot(xs,ys);
    axis([-1,1,-1,1]);
    axis equal;
    title(['Phase Lag: ',num2str(round(lags(i)*180/pi))]);
    drawnow;
    if i == 1
        gif('PhaseLagAnimation.gif','DelayTime',1/FPS);
    else
        gif;
    end
end