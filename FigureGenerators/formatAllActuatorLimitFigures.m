% try
%     close(fig1);
%     close(fig2);
% end
% 
plotSpeeds;

tickMarks = 0;
fs = 18;

%fig1 = openfig('FigureFiles/AllSpeedGaits_Greyscale_ThreeLink.fig','new');
fig1 = figure(2);
ax1 = findall(fig1,'type','axes');
l1 = ax1.Children(1);
view([12,20]);
xticks([2,3,4])
yticks([0,1000,2000]);
zticks([0,0.25,.5,.75]);
axis([2,4,0,2000,0,.85])
fig1.Position = [50,300,575,488];

legend(ax1,l1,'Multistart Results','Location','sw');
ax1.Legend.FontSize = fs;
ax1.Legend.Position = [.15,.17,ax1.Legend.Position(3:4)];

if ~tickMarks
    xticklabels('');
    yticklabels('');
    zticklabels('');
end



% fig2 = openfig('FigureFiles/AllSpeedGaitsNonlinearities_Greyscale_ThreeLink.fig','new');
fig2 = figure(4);
ax2 = findall(fig2,'type','axes');
l2 = ax2.Children(1);
view([12,20]);
xticks([2,3,4])
yticks([0,1000,2000]);
ax2.ZLim = [0,0.5];
zticks([0,.25,.5]);
fig2.Position = [600,300,575,488];

legend(ax2,l2,'Multistart Results','Location','ne');
ax2.Legend.FontSize = fs;
ax2.Legend.Position = [.475,.78,ax2.Legend.Position(3:4)];

if ~tickMarks
    xticklabels('');
    yticklabels('');
    zticklabels('');
end



fig3 = figure(6);
ax3 = findall(fig3,'type','axes');
l3 = ax3.Children(1);
xticks([2,3,4])
yticks([0,1000,2000]);
fig3.Position = [1150,300,575,488];
axis([2,4,0,2000]);

legend(ax3,l3,'Multistart Results','Location','nw');
ax3.Legend.FontSize = 18;
ax2.Legend.Position = [.15,.15,.6,ax2.Legend.Position(4)];

if ~tickMarks
    xticklabels('');
    yticklabels('');
end
