clear all;
initializeWorkspace;

load('normalizedFishTailOptimalGait.mat');

p = makeGait(y0);
k = optimalVals(4);
b = optimalVals(5);

[ft_displ,ft_cost,angles,final_loop] = simulate2DPassiveSwimmer(p,1,s.funs,k,b,0,0);
ts = linspace(0,1,numel(angles(1,:)));

phi = atan2(final_loop(2,end),final_loop(1,end));
fl = zeros(3,size(final_loop,2));
for i = 1:size(final_loop,2)
    fl(:,i) = [getRotMatrix(-phi)*final_loop(1:2,i);final_loop(3,i)-phi];
end

fish_fl = fl;
fish_angs = angles;

load('normalizedThreeLinkOptimalGait.mat');

p = makeGait(y0);
k = optimalVals(4);
b = optimalVals(5);

[tl_displ,tl_cost,angles,final_loop] = simulate2DPassiveSwimmer(p,1,s.funs,k,b,0,0);
ts = linspace(0,1,numel(angles(1,:)));

phi = atan2(final_loop(2,end),final_loop(1,end));
fl = zeros(3,size(final_loop,2));
for i = 1:size(final_loop,2)
    fl(:,i) = [getRotMatrix(-phi)*final_loop(1:2,i);final_loop(3,i)-phi];
end

tl_fl = fl;
tl_angs = angles;

figure(1);
fig = gcf;
set(fig,'color','w');
fig.Position = [2000 200 1748 600];
clf;

subplot(2,1,2);
plotFishTailSwimmerMotion(fish_angs,fish_fl,1,8.9,[-.5,5,-.35,.35],5,0);

subplot(2,1,1);
plotThreeLinkSwimmerMotion(tl_angs,tl_fl,1,10,[-.5,5,-.35,.35],5,0);

function plotThreeLinkSwimmerMotion(rs,fl,T,numPeriods,axisBounds,numFreezeFrames,oneGait)

    FPS = 60;
    states = fl;
    rossred = [234 14 30]/255;
    
    animStates = states;
    animRs = rs;
    for i = 2:numPeriods
        animStates = [animStates(:,1:end-1),states + [animStates(1,end);0;0]];
        animRs = [animRs(:,1:end-1),rs];
    end
    cgStates = zeros(2,numel(animStates(1,:)));
    for i = 1:numel(animStates(1,:))
        a1 = animRs(1,i);
        a2 = animRs(2,i);
        r1 = [-1/6-1/6*cos(a1);1/6*sin(a1)];
        r2 = [0;0];
        r3 = [1/6 + 1/6*cos(a2);1/6*sin(a2)];
        cg_linkFrame = (r1+r2+r3)/3;
        cg_worldFrame = getRotMatrix(animStates(3,i))*cg_linkFrame;
        cgStates(:,i) = cg_worldFrame+animStates(1:2,i);
    end
    cgStates(1,:) = cgStates(1,:) - cgStates(1,1);
    yshift = -1*mean(cgStates(2,:));
    cgStates(2,:) = cgStates(2,:) + yshift;
    %animStates(1:2,:) = cgStates;

    hold on;
    if ~oneGait
        plot(cgStates(1,:),cgStates(2,:),'Color',rossred,'LineWidth',2);
        plot([0,0],axisBounds(3:4),'k');
    end

    n = numel(animStates(1,:));
    ts = linspace(0,T*numPeriods,n);
    indexStep = floor(n/(numFreezeFrames-1));
    freezeIndices = [1];
    for i = 2:numFreezeFrames-1
        freezeIndices(i) = freezeIndices(i-1) + indexStep;
    end
    freezeIndices(numFreezeFrames) = n;
    
    thetas = linspace(0,2*pi,20);
    rm = .0185;
    motor1 = [rm*cos(thetas)+1/6;rm*sin(thetas)];
    motor2 = [rm*cos(thetas)-1/6;rm*sin(thetas)];

    for index = 1:numel(freezeIndices)

        i = freezeIndices(index);

        motor1 = [rm*cos(thetas)+1/6;rm*sin(thetas)];
        motor2 = [rm*cos(thetas)-1/6;rm*sin(thetas)];

        geom.linklengths = [1 1 1]/3;
        angs = [animRs(1,i),animRs(2,i)];
        B = fat_chain(geom,angs);
        state = animStates(:,i);
        state(1) = cgStates(1,i);
        state(2) = state(2) + yshift;

        B = shiftMatrixPoints(B,state(3),[0,0]);
        B = shiftMatrixPoints(B,0,[state(1:2)]);
        B1 = B(:,1:101);
        B2 = B(:,103:203);
        B3 = B(:,205:305);
        motor1 = shiftMatrixPoints(motor1,state(3),[0,0]);
        motor1 = shiftMatrixPoints(motor1,0,[state(1:2)]);
        motor2 = shiftMatrixPoints(motor2,state(3),[0,0]);
        motor2 = shiftMatrixPoints(motor2,0,[state(1:2)]);

        mB1 = mean(B1,2);
        mB2 = mean(B2,2);
        mB3 = mean(B3,2);
        middle = mean([mB1,mB2,mB3],2);

        if index == numel(freezeIndices) && ~oneGait
            plot([cgStates(1,end),cgStates(1,end)],axisBounds(3:4),'--k');
        end

        if ~oneGait
            fill(B1(1,:),B1(2,:),[1,1,1]);
            fill(B2(1,:),B2(2,:),[1,1,1]);
            fill(B3(1,:),B3(2,:),[1,1,1]);
            plot(B1(1,:),B1(2,:),'k');
            plot(B2(1,:),B2(2,:),'k');
            plot(B3(1,:),B3(2,:),'k');
            fill(motor1(1,:),motor1(2,:),'r');
        else
            ofs = .25;
            alpha = index/numel(freezeIndices);
            a2 = (alpha+ofs)/(1+ofs);
            lc = 1-a2;

            fill(B1(1,:),B1(2,:),[1,1,1]);
            fill(B2(1,:),B2(2,:),[1,1,1]);
            fill(B3(1,:),B3(2,:),[1,1,1]);

            plot(B1(1,:),B1(2,:),'Color',[lc,lc,lc]);
            plot(B2(1,:),B2(2,:),'Color',[lc,lc,lc]);
            plot(B3(1,:),B3(2,:),'Color',[lc,lc,lc]);
            fill(motor1(1,:),motor1(2,:),'r','FaceAlpha',alpha,'EdgeColor',[lc,lc,lc]);
        end
    end

    axis equal;
    axis(axisBounds);
    ax = gca;
    set(ax, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
    set(ax,'Visible','off');

end

function plotFishTailSwimmerMotion(rs,fl,T,numPeriods,axisBounds,numFreezeFrames,oneGait)

    remainder = numPeriods-floor(numPeriods);
    numPeriods = floor(numPeriods);

    FPS = 60;
    states = fl;
    rossred = [234 14 30]/255;
    
    animStates = states;
    animRs = rs;
    for i = 2:numPeriods
        animStates = [animStates,states(:,2:end) + [animStates(1,end);0;0]];
        animRs = [animRs,rs(:,2:end)];
    end
    nStates = size(states,2);
    lastState = floor(nStates*remainder);
    animStates = [animStates,states(:,2:lastState) + [animStates(1,end);0;0]];
    animRs = [animRs,rs(:,2:lastState)];

    init = 11;
    other = mod(init-50,101);
    overrideIndices = [init,other,init,other,init];
    yoffset = -1.5/12;
    yoffsets = [yoffset,-yoffset,yoffset,-yoffset,yoffset];
    fa = 1;

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
    %overrideIndices = mod(freezeIndices,101);

    plot([0,0],axisBounds(3:4),'k');
    hold on;

    for index = 1:numel(freezeIndices)

        i = freezeIndices(index);

        %B = drawCubicCurvatureSwimmer(1/3,[animRs(1,i),animRs(2,i)]);
        B = drawCubicCurvatureSwimmer(1/3,[rs(1,overrideIndices(index)),rs(2,overrideIndices(index))]);
        state = animStates(:,i);
        state(2) = yoffsets(index);
        state(3) = fl(3,overrideIndices(index));

        head = shiftMatrixPoints(B.head,state(3),[0,0]);
        head = shiftMatrixPoints(head,0,[state(1:2)]);
        tail = shiftMatrixPoints(B.tail,state(3),[0,0]);
        tail = shiftMatrixPoints(tail,0,[state(1:2)]);
        motor = shiftMatrixPoints(B.motor,state(3),[0,0]);
        motor = shiftMatrixPoints(motor,0,[state(1:2)]);

        mHead = mean(head,2);
        mTail = mean(tail,2);
        mBody = (2*mHead + mTail)/3;

        if index == numel(freezeIndices) && ~oneGait
            plot([cgStates(1,end),cgStates(1,end)],axisBounds(3:4),'--k');
        end

        if ~oneGait
            fill(head(1,:),head(2,:),[1,1,1],'FaceAlpha',fa);
            fill(tail(1,:),tail(2,:),[1,1,1],'FaceAlpha',fa);
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