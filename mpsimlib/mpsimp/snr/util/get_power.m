function out = get_power (in)
    out = in .* conj(in);
    out = real(out);  % (drop zero imaginary component)
end

