function coeff = read_geopot_coeff (filepath)
    dir = fileparts(filepath);
    coeff = setup_geopot (dir, false);
end

%!test
%! filename = 'D:\Felipe-old\ray_tracer-data\geopot\egm96_to360.ascii';
%! coeff = read_geopot_coeff (filename);
%! 
%! %myassert ( isequal(size(coeff.C), [361 361]) );
%! %myassert ( isequal(size(coeff.S), [361 361]) );
%! %myassert ( isequal(coeff.S([0 1]+1, :), zeros(2, 361)) );
%! %myassert ( isequal(coeff.C([0 1]+1, :), zeros(2, 361)) );
%! %myassert ( isequal(coeff.C(2+1, 0+1), -0.484165371736E-03) );
%! %myassert ( isequal(coeff.S(2+1, 0+1),  0.000000000000E+00) );
%! %myassert ( isequal(coeff.C(360+1, 360+1), -0.447516389678E-24) );
%! %myassert ( isequal(coeff.S(360+1, 360+1), -0.830224945525E-10) );

