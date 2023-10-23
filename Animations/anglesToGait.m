function p = anglesToGait(ts,angles)
    ts = ts(:);
    rp = fit(ts,angles(1,:)','fourier4');
    rc = fit(ts,angles(2,:)','fourier4');
    p = fitsToGait({rp,rc});
end