function answer = get_rot (axis, ang)
    ang = reshape(ang, 1, 1, []);
    ang = ang * pi/180;
    zero = zeros(size(ang));
    one  =  ones(size(ang));

    switch axis
    case 1
        answer = [...
             one        zero        zero
            zero    cos(ang)    sin(ang)
            zero   -sin(ang)    cos(ang)
        ];
    case 2
        answer = [...
            cos(ang)    zero   -sin(ang);
                zero     one        zero;
            sin(ang)    zero    cos(ang);
        ];
    case 3
        answer = [...
             cos(ang)   sin(ang)    zero;
            -sin(ang)   cos(ang)    zero;
                 zero       zero     one;
        ];
    otherwise
        error('MATLAB:get_rot:badAxis', 'Axis must be 1, 2, or 3.');
    end
end

%!test
%! % simple rotations:
%! ang = 90;
%! for axis=[1,2,3]
%!     %axis  % DEBUG
%!     switch axis
%!     case 1
%!         pt_in  = [0 0 1];
%!         pt_out = [0 1 0];
%!     case 2
%!         pt_in  = [1 0 0];
%!         pt_out = [0 0 1];
%!     case 3
%!         pt_in =  [0 1 0];
%!         pt_out = [1 0 0];
%!     end
%!     R = get_rot (axis, ang);
%!     pt_out2 = (R * pt_in')';
%!     myassert (pt_out2, pt_out, -eps)
%! end

%!test
%! % x,y,z coordinates remain constant under R1,R2,R3 rotations, respectively:
%! ang = rand*360;
%! pt_in = rand(1,3);
%! for axis=[1,2,3]
%!     R = get_rot (axis, ang);
%!     pt_out = (R * pt_in')';
%!     myassert (pt_out(axis), pt_in(axis), -eps);
%! end

%!test
%! % multiple points:
%! n = ceil(10*rand);
%! ang = repmat(rand*360, n, 1);
%! for axis=[1,2,3]
%!     answer = get_rot (axis, ang);
%!     myassert (isequal(size(answer), [3, 3, n]) ...
%!             || ( n == 1 && isequal(size(answer), [3, 3]) ));
%!     myassert (answer, repmat(answer(:,:,1), [1, 1, n]));
%! end

