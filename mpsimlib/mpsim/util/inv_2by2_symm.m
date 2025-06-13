function out = inv_2by2_symm (in)
    temp1 = [...
        +in(2,2,:), -in(1,2,:);
        -in(2,1,:), +in(1,1,:);
    ];
    temp2 = 1 ./ ( in(1,1,:) .* in(2,2,:) - in(1,2,:).^2 );
    out = frontal_times(temp1, temp2);
end

%!test
%! %n = ceil(10*rand);
%! for n=[1,ceil(10*rand)]
%!   in = [];  for i=1:n,  in = cat(3, in, randsym(2));  end
%!   out = [];  for i=1:n,  out = cat(3, out, inv(in(:,:,i)));  end
%!   out2 = inv_2by2_symm (in);
%!   %out, out2, out2 - out  % DEBUG
%!   myassert(out2, out, -sqrt(eps()))
%!   %pause  % DEBUG
%! end

