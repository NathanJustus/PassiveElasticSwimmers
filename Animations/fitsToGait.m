%Convert a cell array of fourier4 curve fits to a format-fitting gait
%definition

function p = fitsToGait(fits)

if numel(fits) == 1
    y = [fits.a0;fits.a1;fits.b1;fits.a2;fits.b2;fits.a3;fits.b3;fits.a4;fits.b4;fits.w];
else
    y = zeros(10,numel(fits));
    for i = 1:numel(fits)
        y(:,i) = [fits{i}.a0;fits{i}.a1;fits{i}.b1;fits{i}.a2;fits{i}.b2;fits{i}.a3;fits{i}.b3;fits{i}.a4;fits{i}.b4;fits{i}.w];
    end
end

p = makeGait(y);