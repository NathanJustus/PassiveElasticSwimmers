function [vec1,vec2] = phaseRotateVecs(vec1,vec2,phase)

    if vec1(end) == vec1(1)
        vec1 = vec1(1:end-1);
        vec2 = vec2(1:end-1);
    else
        vec1 = vec1(:);
        vec2 = vec2(:);
    end
    
    fractionRotate = phase/(2*pi);
    indexSlice = floor(numel(vec1)*fractionRotate);
    
    vec1 = [vec1(indexSlice+1:end);vec1(1:indexSlice)];
    vec2 = [vec2(indexSlice+1:end);vec2(1:indexSlice)];
    vec1(end+1) = vec1(1);
    vec2(end+1) = vec2(1);
    
end