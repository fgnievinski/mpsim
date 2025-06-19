function R = convert_rot_axis_ang (dir, ang)
    myassert(isvector(dir))
    if (length(dir) == 2),  dir(3) = 0;  end
    myassert(length(dir) == 3)
    dir = dir(:);  % column vector
    ang = ang*pi/180;

    temp = [...
             0  -dir(3) +dir(2)
        +dir(3)      0  -dir(1)
        -dir(2) +dir(1)      0
    ];
    R = eye(3)*cos(ang)...
        + (1 - cos(ang)) * dir * transpose(dir)...
        - temp*sin(ang);
end

%TODO: test it!
% - hint: use tectonic values available at <http://dgfi2.dgfi.badw-muenchen.de/geodis/GDYN/apkim.html>

