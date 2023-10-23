function B = drawCubicCurvatureSwimmer(headRatio,r,doPlotting)

if nargin < 3
    doPlotting = 0;
end

sysplotterLoc = 'C:\Users\njustus\Box\Research\SysplotterFresh\ProgramFiles';
addpath(genpath(sysplotterLoc));

head_r = 0.015;

display.aspect_ratio = .04;
display.sharpness = .05;

at = r(1);
ah = r(2);

geom.linklengths = [headRatio,headRatio];
geom.length = 2*headRatio;

B = fat_chain(geom,0,display);
Head = B(:,size(B,2)/2+1:end-1);

Headx = Head(1,:);
Heady = Head(2,:);

[Headx,Heady] = shiftPoints(Headx,Heady,ah,0,0);

B = struct();
B.head = [Headx;Heady];

thetas = linspace(0,2*pi,20);
motor_r = .0185;
motor = [motor_r*cos(thetas);motor_r*sin(thetas)];

nJointsTail = 22;
s = linspace(0,1-headRatio,nJointsTail);
ds = s(2)-s(1);

C = (18*nJointsTail + 18)/(7*nJointsTail^2 + 8*nJointsTail);
tailArcLength = linspace(1,0,nJointsTail);
body_curv = C*at*(tailArcLength - 1/3*tailArcLength.^2);
body_r = head_r*cos(linspace(0,pi/2,nJointsTail));
tail_r = zeros(2,nJointsTail);
tail_l = zeros(2,nJointsTail);
spine = zeros(2,nJointsTail);
theta = pi;

for i = 2:nJointsTail
    
    theta = theta - body_curv(i-1);
    spine(:,i) = spine(:,i-1) + ds*[cos(theta);sin(theta)];
    
    br = body_r(i);
    tail_r(:,i) = spine(:,i) + br*[cos(theta-pi/2);sin(theta-pi/2)];
    tail_l(:,i) = spine(:,i) + br*[cos(theta+pi/2);sin(theta+pi/2)];

    if i == 6
        midX = spine(1,i);
        midY = spine(2,i);
        rotTheta = pi-theta;
    end

end

B.tail = [tail_r,fliplr(tail_l)];
B.spine = spine;

B.head = [B.head;ones(1,numel(B.head(1,:)))];
B.head = shiftMatrixPoints(B.head,0,[-midX;-midY]);
B.head = shiftMatrixPoints(B.head,rotTheta,[0,0]);
B.tail = [B.tail;ones(1,numel(B.tail(1,:)))];
B.tail = shiftMatrixPoints(B.tail,0,[-midX;-midY]);
B.tail = shiftMatrixPoints(B.tail,rotTheta,[0,0]);
B.spine = [B.spine;ones(1,numel(B.spine(1,:)))];
B.spine = B.spine(:,1:end-1);
B.spine = shiftMatrixPoints(B.spine,0,[-midX;-midY]);
B.spine = shiftMatrixPoints(B.spine,rotTheta,[0,0]);
motor = shiftMatrixPoints(motor,0,[-midX;-midY]);
motor = shiftMatrixPoints(motor,rotTheta,[0;0]);
B.motor = motor;

if doPlotting
    figure(2);
    clf;
    hold on;
    %plot(B.spine(1,:),B.spine(2,:),'r');
    plot(B.head(1,:),B.head(2,:),'k');
    plot(B.tail(1,:),B.tail(2,:),'k');
    plot(B.motor(1,:),B.motor(2,:),'r');
    axis equal;
end
    

end

function R = getRotMatrix(theta)

    R = [cos(theta),-sin(theta);sin(theta),cos(theta)];

end

function newMatrix = shiftMatrixPoints(mat,theta,ds)

    xs = mat(1,:);
    ys = mat(2,:);
    [newXs,newYs] = shiftPoints(xs,ys,theta,ds(1),ds(2));
    newMatrix = [newXs;newYs];

    if size(mat,1) == 3
        newMatrix = [newMatrix;ones(1,size(mat,2))];
    end

end

function [newX,newY] = shiftPoints(x,y,theta,dx,dy)

    R = getRotMatrix(theta);
    
    allPoints = [x;y];
    rotatedPoints = R*allPoints;
    
    newX = rotatedPoints(1,:) + dx;
    newY = rotatedPoints(2,:) + dy;

end