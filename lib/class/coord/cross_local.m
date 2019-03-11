function c = cross_local (a, b)
    c = xyz2neu(cross_all(neu2xyz(a), neu2xyz(b)));
end

