% Yield R such that dirb(:).' / norm(dirb) = (R * dira(:).').' / norm(dira);
function [R, dirc, sin_ang, cos_ang] = get_rotation_matrix2 (dira, dirb, normalized)
    if (nargin < 3) || isempty(normalized),  normalized = false;  end
    dira = reshape(dira, [],3);
    dirb = reshape(dirb, [],3);
    if normalized
        %norma = 1;
        %normb = 1;
        norma_normb = 1;
        n = max(size(dira,1), size(dirb,1));
    else
        norma = norm_all(dira);
        normb = norm_all(dirb);
        norma_normb = norma .* normb;
        n = numel(norma_normb);
    end

    temp1 = cross_all(dira, dirb);
    temp2 = norm_all(temp1);
    dirc = temp1 ./ repmat(temp2, [1,3]);
    %if isequal(temp1, [0 0 0]),  dirc = temp1;  end
    idx = ismember(temp1, [0 0 0], 'rows');  dirc(idx,:) = temp1(idx,:);
    sin_ang = temp2 ./ norma_normb;
    cos_ang = dot_all(dira, dirb) ./ norma_normb;
    %ang = asin(temp2);

    dirc = frontal(dirc, 'pt');
    cos_ang = frontal(cos_ang, 'pt');
    sin_ang = frontal(sin_ang, 'pt');
    I = frontal(repmat(eye(3,3), [1,1,n]));
    zero = frontal(zeros(1,1,n));
    %I = (eye(3,3));
    %zero = (zeros(1,1));
    
    % cross-product matrix:
    temp = [...
                zero, -dirc(1,3,:), +dirc(1,2,:);
        +dirc(1,3,:),         zero, -dirc(1,1,:);
        -dirc(1,2,:), +dirc(1,1,:),         zero;
    ];

    % rotation matrix in Rodrigues' rotation formula:
    R = cos_ang .* I + sin_ang .* temp + (1 - cos_ang) .* (dirc.' * dirc);
      %cos_ang, sin_ang, dirc, temp  % DEBUG
      %R, R * R.' - I % DEBUG
      %myassert(R * R.' - I, zero, -100*eps)

    dirc = defrontal(dirc, 'pt');
    cos_ang = defrontal(cos_ang, 'pt');
    sin_ang = defrontal(sin_ang, 'pt');
    R = defrontal(R);
end

%!test
%! % Rodrigues' rotation formula:
%! function dir2 = rotate_rodrigues (dir1, dirc, cos_ang, sin_ang)
%!     myassert(norm(dirc), 1, eps)
%!     dir2 ...
%!         = dir1 * cos_ang ...
%!         + cross(dirc, dir1) * sin_ang ...
%!         +   dot(dirc, dir1) * dirc * (1 - cos_ang);
%! end
%! 
%! dira = normalize_pt(rand(1,3));
%! dirb = normalize_pt(rand(1,3));
%! 
%! [R, dirc, sin_ang, cos_ang] = get_rotation_matrix2 (dira, dirb);
%! dira2 = (R * dirb.').';
%! dirb2 = (R * dira.').';
%! 
%! dira3 = rotate_rodrigues (dirb, dirc, cos_ang, sin_ang);
%! dirb3 = rotate_rodrigues (dira, dirc, cos_ang, sin_ang);
%! 
%! %dira, dira2, dira2 - dira, fprintf('\n')  % DEBUG
%! %dira, dira3, dira3 - dira, fprintf('\n')  % DEBUG
%! %dirb, dirb2, dirb2 - dirb, fprintf('\n')  % DEBUG
%! %dirb, dirb3, dirb3 - dirb, fprintf('\n')  % DEBUG
%! 
%! myassert(dirb2, dirb, -100*eps)
%! myassert(dirb3, dirb, -100*eps)

%!test
%! % multiple points.
%! n = 10;
%! dira = normalize_vec(rand(n,3));
%! dirb = normalize_vec(rand(n,3));
%! [R, dirc, sin_ang, cos_ang] = get_rotation_matrix2 (dira, dirb);
%! for i=1:n
%!   [R2(:,:,i), dirc2(i,:), sin_ang2(i,1), cos_ang2(i,1)] = ...
%!     get_rotation_matrix2 (dira(i,:), dirb(i,:));
%! end
%! myassert(R2, R)
%! myassert(dirc2, dirc)
%! myassert(sin_ang2, sin_ang)
%! myassert(cos_ang2, cos_ang)

%!test
%! % two dirb with the same slope but different aspect:
%! % they lead to the same result only when the input is dira,
%! % but for any other input (dird here) the resulting 
%! % rotated vector is different.
%! % (see also get_rotation_matrix5.)
%! dirb1 = normalize_vec([0 1 1]);
%! dirb2 = normalize_vec([1 1 1]);
%! dira = [0 0 1];
%! R1 = get_rotation_matrix2 (dira, dirb1);
%! R2 = get_rotation_matrix2 (dira, dirb2);
%! dirb12 = (R1 * dira.').';
%! dirb22 = (R2 * dira.').';
%! %[dirb1; dirb12; dirb12-dirb1]  % DEBUG
%! %[dirb2; dirb22; dirb22-dirb2]  % DEBUG
%! dird = normalize_vec(rand(1,3));
%! dire1 = (R1 * dird.').';
%! dire2 = (R2 * dird.').';
%! %[dire1; dire2; dire2-dire1]  % DEBUG
%! assert(norm(dire2-dire1) > eps())

%!test
%! % how does it transform a perpendicular direction?
%! dirb = normalize_vec([0  0 1]);
%! dira = normalize_vec([0 +1 1]);
%! dird = normalize_vec([0 -1 1]);
%! R = get_rotation_matrix2 (dira, dirb);
%! dirb2 = (R * dira.').';
%! dire  = (R * dird.').';
%! myassert(dirb2, dirb, -sqrt(eps()))
%! myassert(dire, [0 -1 0], -sqrt(eps()))
