clear all;
%Make sure MatLab knows where sysplotter is and relevant folders have been
%added to the path
initializeWorkspace;

%Load swimmer model
load('SimPrep_ThreeLink.mat');

%Define red and black color
rossred = [234 14 30]/255;
black = [0,0,0];

%Do a sweep of frequency and amplitude for candidate input gaits
nSamples = 21;
freqs = linspace(.2,5,21);
amps = linspace(.1,1.5,21);
[FREQS,AMPS] = meshgrid(freqs,amps);

%Make storage for three-link efficiencies, passive response magnitudes and
%phases, net gait displacements, and net gait costs
tlEfficiencies = zeros(size(FREQS));
tl_mags = zeros(size(FREQS));
tl_phases = zeros(size(FREQS));
tl_disps = zeros(size(FREQS));
tl_costs = zeros(size(FREQS));

%For every candidate input gait
for i = 1:numel(FREQS)
    
    %Print progress to console
    disp(i/numel(FREQS));
    
    %Get gait frequency and gait period
    w = FREQS(i);
    T = 1/w;
    %Make vector of gait coefficients
    coeffs = [0;AMPS(i);0;0;0;0;0;0;0;w*2*pi];
    %Get time parameterization of gait
    p = makeGait(coeffs);
    
    %Make time vector for input signal
    ts = linspace(0,T,101);
    %Simulate the swimmer acting under the input signal
    [displ,cost,angles,final_loop] = simulate2DPassiveSwimmer(p,T,s.funs,...
        s.physics.k,s.physics.b,0,1);
    %If all values are valid, do a fourier fit of the resulting motion and
    %store results
    if ~any(any(isnan(angles)))
        tlEfficiencies(i) = displ/cost;
        fit_ft = fit(ts',angles(1,:)','fourier1');
        tl_mags(i) = sqrt(fit_ft.a1^2+fit_ft.b1^2);
        tl_phases(i) = atan2(fit_ft.b1,fit_ft.a1);
        tl_disps(i) = displ;
        tl_costs(i) = cost;
    end
    
end

%Store results for later analysis
save('DataFiles/EfficiencySurfaceData_lowSampleDensity_tl.mat');

% figure(1);
% clf;
% hold on;
% plot(freqs,threeLinkEfficiencies,'LineWidth',2,'Color',black);
% plot(freqs,fishTailEfficiencies,'LineWidth',2,'Color',rossred);
% legend('Three Link Swimmer','Fish Tail Swimmer')
% ylabel('Efficiency (m/J)')
% xlabel('Frequency (Hz)')
% title('Efficiency of Swimmers Performing Identical Gaits at Different Frequencies')
% 
% figure(2);
% clf;
% hold on;
% plot(freqs,tl_mags/2,'LineWidth',2,'Color',black);
% plot(freqs,ft_mags/2,'LineWidth',2,'Color',rossred);
% legend('Three Link Swimmer','Fish Tail Swimmer')
% ylabel('Passive Magnitude I/O Ratio (rad/rad)')
% xlabel('Frequency (Hz)')
% title('Passive Magnitude Ratios for Different Swimmers')
% 
% figure(3);
% clf;
% hold on;
% plot(freqs,tl_phases,'LineWidth',2,'Color',black);
% plot(freqs,ft_phases,'LineWidth',2,'Color',rossred);
% legend('Three Link Swimmer','Fish Tail Swimmer')
% ylabel('Passive Magnitude Phase Offset from Active Joint (rad)')
% xlabel('Frequency (Hz)')
% title('Phase Offsets for Different Swimmers')
