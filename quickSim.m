%Quickly simulates a passive gait for debugging purposes

%Make sure MatLab knows where sysplotter is and relevant folders have been
%added to the path
initializeWorkspace;

%Load swimmer model
load('SimPrep_FlagellaTailTapered.mat');

%Set passive constants
k = 0.025;
b = 0.005;

%Set gait parameters
T = 1;
w = 1;
A = 1.2;

%Make gait
y = [0,A,0,0,0,0,0,0,0,2*pi*w]';
p = makeGait(y);

%Simulate gait
[displ,cost,angles,~] = simulate2DPassiveSwimmer(p,T,s.funs,k,b,0,0);

%Plot shape changes of passive gait
figure(10);
clf;
plot(angles(2,:),angles(1,:));
axis equal;