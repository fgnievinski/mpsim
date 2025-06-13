function pos_geod = rand_pos_geod (n, lim)
%RAND_POS_GEOD: Return random geodetic position; useful for testing.

    if (nargin < 1),  n = 1;  end
    if (nargin < 2)
        lim = [-90, +90; -180, +180; -500, +500];
    end

    lat = randint(lim(1,1), lim(1,2), n, 1);
    lon = randint(lim(2,1), lim(2,2), n, 1);
      h = randint(lim(3,1), lim(3,2), n, 1);

    pos_geod = [lat, lon, h];
end

%!test
%! n = ceil (100*rand);
%! pos_geod = rand_pos_geod (n);
%! myassert (size(pos_geod), [n, 3]);
%! myassert (all(  -90 <= pos_geod(:,1) & pos_geod(:,1) <=  +90 ));
%! myassert (all( -180 <= pos_geod(:,2) & pos_geod(:,2) <= +180 ));
%! myassert (all( -500 <= pos_geod(:,3) & pos_geod(:,3) <= +500 ));

%!test
%! myassert (size(rand_pos_geod), [1, 3])

%!test
%! pos_geod = rand_pos_geod(1, [0,10; 10,20; 20,30]);
%! myassert( 0 <= pos_geod(1) & pos_geod(1) <= 10)
%! myassert(10 <= pos_geod(2) & pos_geod(2) <= 20)
%! myassert(20 <= pos_geod(3) & pos_geod(3) <= 30)
