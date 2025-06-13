function name = polyname (poly)
    %degree = numel(poly) + 1;  % WRONG!
    degree = numel(poly) - 1;
    %degrees = 0:degree;  % WRONG!
    degrees = degree:-1:0;
    if isempty(degrees),  name = {};  return;  end
    name = strcat('poly', num2strcell(degrees));
end
