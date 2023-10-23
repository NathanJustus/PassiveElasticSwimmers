clear all;
initializeWorkspace;

close all;
open('blankFishCCF.fig');
fig1 = gcf;

load('FishTail_MetabolicOptimal_0p05.mat');

% load('MultiStartResults3.mat','bestResults2','s');
% bestOpt = bestResults2{end};
% %load('MultiStartResults_FT_Met_1.mat','bestOpt');
% %load('MultiStartResults_FT_Met_3.mat','bestOpt');
% 
rossred = [234 14 30]/255;
%     
% ybest = bestOpt.yf;
% ybest_onlyFirst = ybest(:,2);
% ybest_onlyFirst(6:7) = [0;0];
% 
% w = ybest(end,2);
% T = 2*pi/w;
% ts = linspace(0,T,105);
% 
% p = makeGait(ybest);
% p1 = makeGait(ybest_onlyFirst);

% T = 1;
% p = makeGait(y0);
% k = optimalVals(4);
% b = optimalVals(5);
% 
% [displ,cost,angles,final_loop] = simulate2DPassiveSwimmer(p,T,s.funs,k,b,0,0);

% a1s = p.phi_def{1}(ts);
% a2s = p.phi_def{2}(ts);
% 
% [a1s,a2s] = phaseRotateVecs(a1s,a2s,pi/2-.6);
% a1s(end+1) = a1s(1);
% a2s(end+1) = a2s(1);

hold on;
lw = 3;
gr = [1,1,1]*.4;
%plot((a2s+flipud(a1s))/2,(a1s+flipud(a2s))/2,'--','LineWidth',2,'Color',gr);
%plot(a2s,a1s,'LineWidth',lw,'Color',rossred);
angles(:,end+1) = angles(:,1);
plot(angles(2,:),angles(1,:),'LineWidth',lw,'Color',rossred);
arrowLines = plot_dir_arrows(angles(2,:),angles(1,:),2);
for i = 1:numel(arrowLines)
    arrowLines(i).Color = rossred;
    arrowLines(i).LineWidth = lw;
end

% be = .12;
% boxX = [be,-be,-be,be,be];
% boxY = [be,be,-be,-be,be];
% plot(boxX,boxY,'k','LineWidth',.5);

set(gca, 'fontname', 'cmu serif');
set(gcf,'color','w');
xticks([-pi,0,pi]);
yticks([-pi,0,pi]);
xticklabels({'\pi','0','\pi'})
yticklabels({'-\pi','0','\pi'})
axis equal
xlabel('$r_c$','Interpreter','latex');
ylabel('$r_p$','Interpreter','latex');
%title({'Fish-Tail','Power Normalized Optimal Gait'});
set(gca,'TitleFontWeight','normal');



set(fig1,'Position',[2500 130 700 700]);