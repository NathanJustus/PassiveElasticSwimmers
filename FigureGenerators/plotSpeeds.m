initializeWorkspace

load('rossColormap.mat');
load('PowerRestrictionOptimalGaits.mat');

rossred = [234 14 30]/255;
lw = 3;
fs = 16;

%colormap default
figure(1);
clf;
hold on;
set(gca, 'fontname', 'CMU Serif');
colormap(blackCmap);
surf(FREQS,POWERS,SPEEDS);
multiStartResults = plot3(optFreqs,optPowers,optSpeeds,'Color',rossred,'LineWidth',lw);
view([12,23]);
axis([1,2.5,0,3,0,.75]);
zticks([0,.25,.5,.75]);
set(gca,'FontSize',fs);
legend(multiStartResults,'Unconstrained Frequency','Location','best','Interpreter','latex','FontSize',fs)
set(gcf,'color','w');
grid on;
% xlabel('Frequency','FontSize',fs,'interpreter','latex')
% ylabel('Average Power Cieling','FontSize',fs,'interpreter','latex')
% zlabel('Optimal Speed','FontSize',fs,'interpreter','latex')

nUp = 50;
f1s = FREQS(1,:);
p1s = POWERS(:,1)';
f2s = linspace(f1s(1),f1s(end),nUp);
p2s = linspace(p1s(1),p1s(end),nUp);
[FREQS2,POWERS2] = meshgrid(f2s,p2s);
SPEEDS2 = interp2(FREQS,POWERS,SPEEDS,FREQS2,POWERS2);

figure(2);
clf;
hold on;
set(gca, 'fontname', 'CMU Serif');
colormap(flipud(blackCmap));
contour(FREQS2,POWERS2,SPEEDS2);
msr = plot(optFreqs,optPowers,'Color',rossred,'LineWidth',lw);
yticks([.5,1,1.5,2,2.5]);
set(gca,'FontSize',fs);
legend(msr,'Unconstrained Frequency','Location','nw','Interpreter','latex','FontSize',fs)
% xlabel('Frequency','Interpreter','latex');
% ylabel('Power Budget','Interpreter','latex');
set(gcf,'color','w');
