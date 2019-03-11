function out = inv_3by3 (in)
    a = in(1,1,:);  b = in(1,2,:);  c = in(1,3,:);
    d = in(2,1,:);  e = in(2,2,:);  f = in(2,3,:);
    g = in(3,1,:);  h = in(3,2,:);  i = in(3,3,:);

    A =   e.*i-f.*h; 
    B = -(d.*i-f.*g);
    C =   d.*h-e.*g;
    D = -(b.*i-c.*h); 
    E =   a.*i-c.*g; 
    F = -(a.*h-b.*g);
    G =   b.*f-c.*e; 
    H = -(a.*f-c.*d);
    I =   a.*e-b.*d;
    
    temp1 = [...
        A, B, C;
        D, E, F;
        G, H, I;      
    ];
    temp1 = frontal_transpose(temp1);
    temp2 = 1 ./ (a.*A + b.*B + c.*C);
    out = frontal_times(temp1, temp2);

    % formulation as in <https://en.wikipedia.org/wiki/Invertible_matrix#Inversion_of_3.C3.973_matrices>
end

%!test
%! %n = ceil(10*rand);
%! for n=[1,ceil(10*rand),ceil(10*rand)]
%!   in = [];  for i=1:n,  in = cat(3, in, randsym(3));  end
%!   out = [];  for i=1:n,  out = cat(3, out, inv(in(:,:,i)));  end
%!   out2 = inv_3by3 (in);
%!   out, out2, out2 - out  % DEBUG
%!   myassert(out2, out, -sqrt(eps()))
%!   %pause  % DEBUG
%! end
