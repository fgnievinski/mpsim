function V = frontal_jacob2var (J, C, C_type, J_type)
    if (nargin < 3),  C_type = [];  end
    if (nargin < 4),  J_type = [];  end
    J = frontal(J, J_type);
    C = frontal(C);
    V = jacob2var (J, C, C_type);
    V = defrontal(V, J_type);
end

%!test
%! C = rand(2,2);
%! J = rand(1,2);
%! V1 = J*C*J';
%! V2 = frontal_jacob2var (J, C);
%! %V1, V2, V2-V1  % DEBUG
%! myassert(V1, V2, -sqrt(eps()))

%!test
%! % frontal_jacob2var()
%! C = rand(1,1,3);
%! J = rand(3,1);
%! for i=1:3,  V1(i,1) = J(i,:)*C(:,:,i)*J(i,:)';  end
%! V2 = frontal_jacob2var_pt (J, C);
%! %V1, V2, V2-V1  % DEBUG
%! myassert(V1, V2, -eps())

%!test
%! % frontal_jacob2var()
%! C = rand(2,2,3);
%! J = rand(1,2);
%! for i=1:3,  V1(i,1) = J*C(:,:,i)*J';  end
%! V2 = frontal_jacob2var_pt (J, C);
%! %V1, V2, V2-V1  % DEBUG
%! myassert(V1, V2, -eps())

%!test
%! C = rand(2,2);
%! J = rand(3,2);
%! for i=1:3,  V1(i,1) = J(i,:)*C*J(i,:)';  end
%! V2 = frontal_jacob2var (J, C);
%! %V1, V2, V2-V1  % DEBUG
%! myassert(V1, V2, -eps())

