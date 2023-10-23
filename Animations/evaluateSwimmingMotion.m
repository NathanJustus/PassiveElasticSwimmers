function [ts,states,rs] = evaluateSwimmingMotion(s,p,T,FPS)

    if isfield(p,'cBVI_opt')
        gait = p.phi_def{1}{1};
        dGait = p.dphi_def{1}{1};
    elseif isfield(p,'phi_def')
        gait = @(t) [p.phi_def{1}(t),p.phi_def{2}(t)];
        dGait = @(t) [p.dphi_def{1}(t),p.dphi_def{2}(t)];
    end

    n = FPS;
    ts = linspace(0,T,n);
    states = zeros(3,n);

    for i = 1:n-1
        state = states(:,i);
        theta = state(3);
        R = [cos(theta),-sin(theta),0;sin(theta),cos(theta),0;0,0,1];

        rs = gait(ts(i));
        r1 = rs(1);
        r2 = rs(2);
        A = s.A(r1,r2);
        g_circ = -A*dGait(ts(i))';

        g_dot = R*g_circ;
        states(:,i+1) = state + (ts(i+1)-ts(i))*g_dot;
    end

    phi = atan2(states(2,end),states(1,end));
    states = zeros(3,n);
    states(3,1) = -phi;
    rs = zeros(2,n);

    for i = 1:n-1
        state = states(:,i);
        theta = state(3);
        R = [cos(theta),-sin(theta),0;sin(theta),cos(theta),0;0,0,1];

        r = gait(ts(i));
        r1 = r(1);
        r2 = r(2);
        rs(:,i) = [r1;r2];
        A = s.A(r1,r2);
        g_circ = -A*dGait(ts(i))';

        g_dot = R*g_circ;
        states(:,i+1) = state + (ts(i+1)-ts(i))*g_dot;
    end
    rs(:,end) = gait(ts(end))';
end