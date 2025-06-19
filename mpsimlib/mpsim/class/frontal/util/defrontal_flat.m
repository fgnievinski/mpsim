function J_out = defrontal_flat (J_in)
    [m,n,o] = size(J_in);

    J_out = cell(m,n);
    for i=1:m, for j=1:n
        J_out{i,j} = spdiags(squeeze(J_in(i,j,:)), 0, o, o);
    end, end

    J_out = cell2mat(J_out);
end

function J_out = defrontal_flat_old (J_in)
    myassert (size(J_in,1) == 3 && size(J_in,2) == 3);
    n = size(J_in, 3);

    J_out = [...
        % first row block:
        spdiags(reshape(J_in(1,1,:),[],1), 0,n,n), ...
        spdiags(reshape(J_in(1,2,:),[],1), 0,n,n), ...
        spdiags(reshape(J_in(1,3,:),[],1), 0,n,n); ...
        % second row block:
        spdiags(reshape(J_in(2,1,:),[],1), 0,n,n), ...
        spdiags(reshape(J_in(2,2,:),[],1), 0,n,n), ...
        spdiags(reshape(J_in(2,3,:),[],1), 0,n,n); ...
        % third row block:
        spdiags(reshape(J_in(3,1,:),[],1), 0,n,n), ...
        spdiags(reshape(J_in(3,2,:),[],1), 0,n,n), ...
        spdiags(reshape(J_in(3,3,:),[],1), 0,n,n); ...
    ];
end

%!test
%! % single frontal page:
%! J_in = rand(3);
%! J_out = J_in;
%! J_out2 = full(defrontal_flat (J_in));
%! myassert (J_out2, J_out);

%!test
%! n = ceil(10*rand);
%! J_in = rand(3,3,n);
%! 
%! diag2p = reshape(cat(3, J_in(1,3,:)), [], 1);
%! diag1n = reshape(cat(3, J_in(2,1,:), J_in(3,2,:)), [], 1);
%! diag0  = reshape(cat(3, J_in(1,1,:), J_in(2,2,:), J_in(3,3,:)),[],1);
%! diag1p = reshape(cat(3, J_in(1,2,:), J_in(2,3,:)), [], 1);
%! diag2n = reshape(cat(3, J_in(3,1,:)), [], 1);
%! 
%! myassert (diag(J_in(:,:,1), -2), diag2n([1]));
%! myassert (diag(J_in(:,:,1), -1), diag1n([1; n+1]));
%! myassert (diag(J_in(:,:,1),  0), diag0 ([1; n+1; 2*n+1]));
%! myassert (diag(J_in(:,:,1), +1), diag1p([1; n+1]));
%! myassert (diag(J_in(:,:,1), +2), diag2p([1]));
%! 
%! temp = [...
%!     [diag2n; zeros(n,1); zeros(n,1)], ...
%!     [diag1n; zeros(n,1)], ...
%!     [diag0], ...
%!     [zeros(n,1); diag1p], ...
%!     [zeros(n,1); zeros(n,1); diag2p], ...
%! ];
%! %B = spdiags(J_in);  B, temp  % DEBUG
%! 
%! J_out = spdiags (temp, [-2*n -1*n 0 +1*n +2*n], 3*n, 3*n);
%! 
%! J_out2 = defrontal_flat (J_in);
%! 
%! %full(J_out), full(J_out2)
%! myassert (J_out, J_out2);

%!test
%! try
%!     n = ceil(10*rand);
%!     ell = get_ellipsoid('grs80');
%!     pt_geod = rand_pt_geod(n);
%!     pt_cart = convert_to_cartesian (pt_geod, ell);
%!     param = 100*rand(7,1);
%! catch
%!     % (geodetic functions unavailable)
%!     return;
%! end
%! 
%! J = get_jacobian_similarity_obs (param, n);
%! obs_design = defrontal_flat (J);
%! 
%! obs_design2 = get_obs_design (param, n);
%! 
%! %full(obs_design), full(obs_design2)
%! %full(obs_design) - eye(n*3)
%! myassert (obs_design, obs_design2);
%! 
%! function obs_design = get_obs_design (param, num_pts)
%!     R = similarity ('radius');
%!     trans_X = param(1);
%!     trans_Y = param(2);
%!     trans_Z = param(3);
%!     scale_change = param(4) / R;
%!     rot_X   = param(5) / R;
%!     rot_Y   = param(6) / R;
%!     rot_Z   = param(7) / R;
%!     
%!     zero = sparse(num_pts, num_pts);
%!     I    =  speye(num_pts, num_pts);
%!     s = scale_change;
%!     
%!     obs_design = [...
%!          (1+s).*I, +rot_Z.*I, -rot_Y.*I;
%!         -rot_Z.*I,  (1+s).*I, +rot_X.*I;
%!         +rot_Y.*I, -rot_X.*I,  (1+s).*I;
%!     ];
%!     %obs_design = sparse(obs_design);
%!     myassert (issparse(obs_design));
%!     % param_design = [...
%!     %     obs_design_X;
%!     %     obs_design_Y;
%!     %     obs_design_Z;
%!     % ];
%!     % where obs_design_X = [...
%!     %     df_X/dX, df_X/dY, df_X/dZ, df_X/dX', df_X/dY', df_X/dZ';
%!     % ];
%!     % and df_X/dX = [...
%!     %     df_X1/dX1, df_X1/dX2, df_X1/dX3, ... ;
%!     %     df_X2/dX1, df_X2/dX2, df_X2/dX3, ... ;
%!     %     df_X3/dX1, df_X3/dX2, df_X3/dX3, ... ;
%!     %     ...
%!     % ];
%! end

%!test
%! % size other than 3 by 3:
%! temp = defrontal_flat(ones(2,3,4));
%! %full(temp)  % DEBUG
%! myassert(size(temp), [4*2,4*3])

