clear all;
initializeWorkspace;
load('passiveGaitGeneratorPrep.mat','s');
load('normalizedFishTailOptimalGait.mat');

p = makeGait(y0);
k = optimalVals(4);
b = optimalVals(5);

[displ,cost,angles,final_loop] = simulate2DPassiveSwimmer(p,1,s.funs,k,b,0,0);
ts = linspace(0,1,numel(angles(1,:)));

phi = atan2(final_loop(2,end),final_loop(1,end));
fl = zeros(3,size(final_loop,2));
for i = 1:size(final_loop,2)
    fl(:,i) = [getRotMatrix(-phi)*final_loop(1:2,i);final_loop(3,i)-phi];
end

figure(1);
fig = gcf;
set(fig,'color','w');
fig.Position = [2000 200 1748 600];
clf;

subplot(2,1,2);
plotFishTailSwimmerMotion(angles,fl,1,10,[-.5,4.5,-.35,.35],5,0);

subplot(2,1,1);
plotFishTailSwimmerMotion(angles,fl,1,10,[-.5,4.5,-.35,.35],10,1);


function plotFishTailSwimmerMotion(rs,fl,T,numPeriods,axisBounds,numFreezeFrames,oneGait)

    FPS = 60;
    states = fl;
    rossred = [234 14 30]/255;
    
    animStates = states;
    animRs = rs;
    for i = 2:numPeriods
        animStates = [animStates,states(:,2:end) + [animStates(1,end);0;0]];
        animRs = [animRs,rs(:,2:end)];
    end

    cgStates = zeros(2,numel(animStates(1,:)));
    for i = 1:numel(animStates(1,:))
        a1 = animRs(1,i);
        a2 = animRs(2,i);
        B = drawCubicCurvatureSwimmer(1/3,[a1,a2]);
        bodyMean = (2*mean(B.tail,2)+mean(B.head,2))/3;
        cg_worldFrame = getRotMatrix(animStates(3,i))*bodyMean(1:2);
        cgStates(:,i) = cg_worldFrame+animStates(1:2,i);
    end
    animStates(1:2,:) = animStates(1:2,:) - cgStates(1:2,1);
    cgStates(1:2,:) = cgStates(1:2,:) - cgStates(1:2,1);
    %animStates(1:2,:) = cgStates;

    hold on;
    if ~oneGait
        plot(cgStates(1,:),cgStates(2,:),'Color',rossred,'LineWidth',2);
        plot([0,0],axisBounds(3:4),'k');
    end

    n = numel(animStates(1,:));
    ts = linspace(0,T*numPeriods,n);
    indexStep = n/(numFreezeFrames-1);
    freezeIndices = [1];
    for i = 2:numFreezeFrames-1
        freezeIndices(i) = freezeIndices(i-1) + indexStep;
    end
    freezeIndices(numFreezeFrames) = n;
    freezeIndices = floor(freezeIndices);

    for index = 1:numel(freezeIndices)

        i = freezeIndices(index);

        B = drawCubicCurvatureSwimmer(1/3,[animRs(1,i),animRs(2,i)]);
        state = animStates(:,i);

        head = shiftMatrixPoints(B.head,state(3),[0,0]);
        head = shiftMatrixPoints(head,0,[state(1:2)]);
        tail = shiftMatrixPoints(B.tail,state(3),[0,0]);
        tail = shiftMatrixPoints(tail,0,[state(1:2)]);
        motor = shiftMatrixPoints(B.motor,state(3),[0,0]);
        motor = shiftMatrixPoints(motor,0,[state(1:2)]);

        mHead = mean(head,2);
        mTail = mean(tail,2);
        mBody = (2*mHead + mTail)/3;

        plot([0,0],axisBounds(3:4),'k');
        hold on;

        if index == numel(freezeIndices) && ~oneGait
            plot([cgStates(1,end),cgStates(1,end)],axisBounds(3:4),'--k');
        end

        if ~oneGait
            fill(head(1,:),head(2,:),[1,1,1]);
            fill(tail(1,:),tail(2,:),[1,1,1]);
            fill(motor(1,:),motor(2,:),[1,1,1]);
            plot(head(1,:),head(2,:),'k');
            plot(tail(1,:),tail(2,:),'k');
            fill(motor(1,:),motor(2,:),'r');
        else
            ofs = .25;
            alpha = index/numel(freezeIndices);
            a2 = (alpha+ofs)/(1+ofs);
            lc = 1-a2;

            fill(head(1,:),head(2,:),[1,1,1]);
            fill(tail(1,:),tail(2,:),[1,1,1]);
            fill(motor(1,:),motor(2,:),[1,1,1]);

            plot(head(1,:),head(2,:),'Color',[lc,lc,lc]);
            plot(tail(1,:),tail(2,:),'Color',[lc,lc,lc]);
            fill(motor(1,:),motor(2,:),'r','FaceAlpha',alpha,'EdgeColor',[lc,lc,lc]);
        end
    end

    axis equal;
    axis(axisBounds);
    ax = gca;
    set(ax, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
    set(ax,'Visible','off');

end

function R = getRotMatrix(theta)

    R = [cos(theta),-sin(theta);sin(theta),cos(theta)];

end

function newMatrix = shiftMatrixPoints(mat,theta,ds)

    if nargin == 2
        ds = [0,0];
    end

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