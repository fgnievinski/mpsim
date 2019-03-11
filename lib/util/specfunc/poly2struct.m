function struct = poly2struct (poly)
    name = polyname (poly);
    struct = num2struct(rowvec(poly), name, 2);
end
