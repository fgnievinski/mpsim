function nrml = tangent2normal_2d (tan)
    assert( (size(tan,2)<3) || all(tan(:,3)==0) )
    nrml = [-tan(:,2), +tan(:,1)];
    % see <http://mathworld.wolfram.com/NormalVector.html>.
end

%!test
%! function nrml = tangent2normal_3d (tan)
%!     down = [0 0 -1];
%!     bin = down;
%!     nrml = cross_all(tan, bin);
%! end
%! 
%! n = 4;
%! tan_2d = normalize_all(rand(n,2));
%! tan_3d = [tan_2d, zeros(n,1)];
%! 
%! nrml_2d = tangent2normal_2d (tan_2d);
%! nrml_3d = tangent2normal_3d (tan_3d);
%! 
%! nrml_3db = [nrml_2d, zeros(n,1)];
%! nrml_2db = nrml_3d(:,1:2);
%! 
%! %nrml_3d, nrml_3db, nrml_3d-nrml_3db  % DEBUG
%! %nrml_2d, nrml_2db, nrml_2d-nrml_2db  % DEBUG
%! 
%! myassert(nrml_3d, nrml_3db, -sqrt(eps()))
%! myassert(nrml_2d, nrml_2db, -sqrt(eps()))
