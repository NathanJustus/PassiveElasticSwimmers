function animateThreeLinkSwimmer(s,p,T,numPeriods,axisBounds)

    FPS = 60;
    [ts,states,rs] = evaluateSwimmingMotion(s,p,T,FPS);
    
    animStates = states;
    animRs = rs;
    for i = 2:numPeriods
        animStates = [animStates,states + [animStates(1,end);0;0]];
        animRs = [animRs,rs];
    end

    thetas = linspace(0,2*pi,20);
    rm = .0185;
    motor1 = [rm*cos(thetas)+1/6;rm*sin(thetas)];
    motor2 = [rm*cos(thetas)-1/6;rm*sin(thetas)];

    writerObj = VideoWriter('Animations/threeLinkSwimming.mp4','MPEG-4');
    writerObj.FrameRate = FPS;

    open(writerObj);
    figure(1);
    fig = gcf;
    set(fig,'color','w');
    fig.Position = [2000 419 1748 388];
    for i = 1:size(animStates,2)
        clf;

        motor1 = [rm*cos(thetas)+1/6;rm*sin(thetas)];
        motor2 = [rm*cos(thetas)-1/6;rm*sin(thetas)];

        geom.linklengths = [1 1 1]/3;
        angs = [animRs(1,i),animRs(2,i)];
        B = fat_chain(geom,angs);
        state = animStates(:,i);

        B = shiftMatrixPoints(B,state(3),[0,0]);
        B = shiftMatrixPoints(B,0,[state(1:2)]);
        B1 = B(:,1:101);
        B2 = B(:,103:203);
        B3 = B(:,205:305);
        motor1 = shiftMatrixPoints(motor1,state(3),[0,0]);
        motor1 = shiftMatrixPoints(motor1,0,[state(1:2)]);
        motor2 = shiftMatrixPoints(motor2,state(3),[0,0]);
        motor2 = shiftMatrixPoints(motor2,0,[state(1:2)]);

        plot([0,0],axisBounds(3:4),'k');
        hold on;

        mB1 = mean(B1,2);
        mB2 = mean(B2,2);
        mB3 = mean(B3,2);
        middle = mean([mB1,mB2,mB3],2);

        if i ~= 1
            plot([middle(1),middle(1)],axisBounds(3:4),'--k');
        end

        fill(B1(1,:),B1(2,:),'k');
        fill(B2(1,:),B2(2,:),'k');
        fill(B3(1,:),B3(2,:),'k');
        fill(motor1(1,:),motor1(2,:),'r');
        fill(motor2(1,:),motor2(2,:),'r');


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