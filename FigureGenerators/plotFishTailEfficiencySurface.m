initializeWorkspace;
load('EfficiencySurfaceData_justFishTail2.mat');

mech_eff = ft_disps./ft_costs;
Ts = 1./FREQS;
metabolicRate = 0.05;

metabolicCosts = ft_costs + metabolicRate*Ts;
metabolic_eff = ft_disps./metabolicCosts;

figure(1);
clf;
surf(FREQS,AMPS,mech_eff);

figure(2);
clf;
surf(FREQS,AMPS,metabolic_eff);