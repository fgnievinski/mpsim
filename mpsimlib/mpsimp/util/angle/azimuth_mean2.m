function azim = azimuth_mean2 (azim1, azim2)
    nd1 = ndims(azim1);
    nd2 = ndims(azim2);
    assert(nd2==nd1);
    nd3 = nd1 + 1;
    azim3 = cat(nd3, azim1, azim2);
    azim = azimuth_stat (azim3, @nanmean, nd3);
end

%!test
%! out = azimuth_mean2([3 5], [4 6])
%! myassert(out, [3.5 5.5], -sqrt(eps()))
%! out = azimuth_mean2([3; 4], [5; 6])
%! myassert(out, [4; 5], -sqrt(eps()))
