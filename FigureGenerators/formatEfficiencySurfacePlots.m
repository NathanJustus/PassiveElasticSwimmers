clear all;
initializeWorkspace;

%load('EfficiencySurfaceData_justFishTail2.mat');
load('DataFiles\EfficiencySurfaceData.mat');
load('DataFiles\rossColormap.mat');

doLabels = 0;
fs = 16;

disps = tl_disps;
costs = tl_costs;

mech_eff = disps./costs;
Ts = 1./FREQS;
metabolicRate = 0.05;
metabolicCosts = costs + metabolicRate*Ts;
metabolic_eff = disps./metabolicCosts;

figure(1);
clf;
surface(FREQS,AMPS,mech_eff);
colormap(blackCmap)
grid on;
view([10,40]);
xticks([0,2.5,5]);
zticks([0,1,2]);
axis([0,5,0,1.5,0,2.25]);
set(gca, 'fontname', 'cmu serif','fontsize',fs);
set(gcf,'color','w');
if doLabels
    xlabel('Frequency (Hz)');
    ylabel('Amplitude (rad)');
    zlabel('Efficiency');
    %title('Mechanical Power Efficiency - Fish Tail Swimmer');
else
%     xticklabels('');
%     yticklabels('');
%     zticklabels('');
end

figure(3);
clf;
surf(FREQS,AMPS,metabolic_eff);
colormap(blackCmap);
view([10,40]);
xticks([0,2.5,5]);
zticks([0,.5,1]);
axis([0,5,0,1.5]);
set(gca, 'fontname', 'cmu serif','fontsize',fs);
set(gcf,'color','w');

if doLabels
    xlabel('Frequency (Hz)');
    ylabel('Amplitude (rad)');
    zlabel('Efficiency (m/J)')
    %title('Metabolic Efficiency - Fish Tail Swimmer');
else
%     xticklabels('');
%     yticklabels('');
%     zticklabels('');
end

load('EfficiencySurfaceData_highSampleDensity.mat');
% load('DataFiles\EfficiencySurfaceData_highSampleDensity.mat');
load('DataFiles\rossColormap.mat');

disps = tl_disps;
costs = tl_costs;

doLabels = 0;
fs = 16;

mech_eff = disps./costs;
Ts = 1./FREQS;
metabolicRate = 0.05;
metabolicCosts = costs + metabolicRate*Ts;
metabolic_eff = disps./metabolicCosts;

mech_eff = filterData(mech_eff);
metabolic_eff = filterData(metabolic_eff);

nContours = 9;
figure(2);
clf;
contour(FREQS,AMPS,mech_eff,nContours);
colormap(flipud(blackCmap));
set(gca, 'fontname', 'cmu serif','fontsize',fs);
set(gcf,'color','w');

yticks([min(amps),.5,1,1.5]);
xticks([min(freqs),2.5,5]);
if doLabels
    xlabel('Frequency (Hz)');
    ylabel('Amplitude (rad)');
    %title('Mechanical Power Efficiency - Fish Tail Swimmer');
else
%     xticklabels('');
%     yticklabels('');
%     zticklabels('');
end
axis([.2,5,.1,1.5]);
axis square


figure(4);
clf;
contour(FREQS,AMPS,metabolic_eff,nContours);
colormap(flipud(blackCmap));
yticks([min(amps),.5,1,1.5]);
xticks([min(freqs),2.5,5]);
axis([.2,5,.1,1.5]);
set(gca, 'fontname', 'cmu serif','fontsize',fs);
set(gcf,'color','w');

if doLabels
    xlabel('Frequency (Hz)');
    ylabel('Amplitude (rad)');
    %title('Metabolic Efficiency - Fish Tail Swimmer');
else
%     xticklabels('');
%     yticklabels('');
%     zticklabels('');
end
axis square

function filteredMatrix = filterData(toFilter)

    filter = [2,3,2;3,4,3;2,3,2]/24;
    toFilter = [toFilter(:,1),toFilter,toFilter(:,end)];
    toFilter = [toFilter(1,:);toFilter;toFilter(end,:)];
    filteredMatrix = conv2(toFilter,filter,'same');
    filteredMatrix = filteredMatrix(2:end-1,2:end-1);
    
end