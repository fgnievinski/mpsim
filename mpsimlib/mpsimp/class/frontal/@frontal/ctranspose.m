function C = ctranspose (A)
    %whos A  % DEBUG
    if ~isreal(A)
        error ('frontal:ctranspose:notSupported', 'Feature not supported.');
    end
    C = transpose(A);
end
