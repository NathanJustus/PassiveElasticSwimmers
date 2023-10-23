function animateFishTailSwimmer(s,p,T,numPeriods,axisBounds)

    FPS = 60;
    [ts,states,rs] = evaluateSwimmingMotion(s,p,T,FPS);
    
    animStates = states;
    animRs = rs;
    for i = 2:numPeriods
        animStates = [animStates,states + [animStates(1,end);0;0]];
        animRs = [animRs,rs];
    end
    animStates(1,:) = animStates(1,:) - 1/12;


    writerObj = VideoWriter('Animations/fishTailSwimming.mp4','MPEG-4');
    FPS = 84;
    writerObj.FrameRate = FPS;

    open(writerObj);
    figure(1);
    fig = gcf;
    set(fig,'color','w');
    fig.Position = [2000 419 1748 388];
    for i = 1:size(animStates,2)
        clf;

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
        mBody = mean([mHead,mTail],2);
        mBody(1) = mBody(1)-1/12;

        plot([0,0],axisBounds(3:4),'k');
        hold on;

        if i ~= 1
            plot([mBody(1),mBody(1)],axisBounds(3:4),'--k');
        end

        fill(head(1,:),head(2,:),'k');
        fill(tail(1,:),tail(2,:),'k');
        fill(motor(1,:),motor(2,:),'r');
        axis equal;
        axis(axisBounds);
        ax = gca;
        set(ax, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
        set(ax,'Visible','off')
        drawnow;
        thisFrame = getframe(gcf);
        writeVideo(writerObj,thisFrame);
    end

    close(writerObj)

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