rossred = [234 14 30]/255;
midColor = [1 1 1];


rrCmap = zeros(255,3);
blackCmap = zeros(255,3);

for i = 1:3
    piece1 = linspace(rossred(i),midColor(i),128)';
    piece2 = linspace(midColor(i),0,128)';
    rrCmap(:,i) = [piece1;piece2(2:end)];
    blackCmap(:,i) = linspace(0,1,255)';
end

clearvars -except rrCmap blackCmap
save('DataFiles\rossColormap.mat');