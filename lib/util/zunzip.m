function filename_out = zunzip (filename, outputdir)
    if (nargin < 2),  outputdir = [];  end
    filename_out = zzip (filename, outputdir, '-d');
end

%!test
%! % zunzip()
%! test('zzip')
