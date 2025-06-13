function ddeg = mat2deg (varargin)
    [deg, min, sec, sig] = mat_parts(horzcat(varargin{:}));
    ddeg = sig .* ( deg + (min + sec/60)/60 );
end

%!test
%! mat = [...
%!     0  0  0 +1
%!     0 30  0 +1
%!     0  1  0 +1
%!     0  0  1 +1
%!     1 30  0 -1
%! ];
%! ddeg = [...
%!     0
%!     0.5
%!     1/60
%!     1/3600
%!     -1.5
%! ];
%! ddeg2 = mat2deg (mat);
%! ddeg3 = mat2deg (mat(:,1), mat(:,2), mat(:,3), mat(:,4));
%! myassert (ddeg2, ddeg, -eps);
%! myassert (ddeg2, ddeg3);

