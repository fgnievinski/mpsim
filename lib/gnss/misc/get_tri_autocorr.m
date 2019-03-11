function answer = get_tri_autocorr (delay, chip)
    if isempty(chip)
        answer = 1;
        return;
    end
    temp = abs(delay) ./ chip;
    answer = 1 - temp;
    answer(temp > 1) = 0;
end
