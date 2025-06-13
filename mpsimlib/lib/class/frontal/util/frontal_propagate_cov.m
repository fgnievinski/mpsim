function [cov_out, std_out] = frontal_propagate_cov (cov_in, jacobian)
    if isscalar(jacobian) && abs(jacobian) == 1
        cov_out = cov_in;
        if (nargout > 1)
            temp = defrontal_pt(frontal_transpose(frontal_diag(cov_out)));
            std_out = sqrt(temp);
        end
        return;
    end
    
    % (let frontal_mtimes sort it out.)
    %n = size(jacobian, 3);
    %assert ( size(cov_in, 3) == n );
    %assert ( size(cov_in, 1) == size(cov_in, 2) );
    %myassert ( isequal(size(cov_in), [3, 3, n]) );  % doesn't work

    %% simplified expression for a single point:
    %cov_out = jacobian * cov_in * jacobian.';
    %std_out = sqrt(diag(cov_out)).';
    
    cov_out = frontal_mtimes(frontal_mtimes(...
        jacobian, cov_in), frontal_transpose(jacobian));
    if (nargout < 2),  return;  end
    std_out = cov2std(cov_out);    
end

%!test
%! jacobian = eye(3);
%! cov_in = rand(3,3);
%! cov_out = frontal_propagate_cov (cov_in, jacobian);
%! myassert (cov_out, cov_in, -eps);

%!test
%! % Multiple points:
%! n = 10000;%ceil(10*rand);
%! cov_in = repmat(rand(3,3), [1,1,n]);
%! jacobian = repmat(eye(3,3), [1,1,n]);
%! 
%! [cov_out, std_out] = frontal_propagate_cov (cov_in, jacobian);
%!
%! myassert ( size(cov_out,3) == n )
%! myassert ( size(std_out,1) == n )
%! myassert ( cov_in, repmat(cov_in(:,:,1), [1,1,n]))
%! % since jacobian is identity matrix:
%! myassert ( cov_in, cov_out )

%!test
%! cov_in = rand;
%! cov_out = frontal_propagate_cov (cov_in, 1);
%!   myassert (cov_out, cov_in);
%! cov_out = frontal_propagate_cov (cov_in, -1);
%!   myassert (cov_out, cov_in);
%! [cov_out, std_out] = frontal_propagate_cov (cov_in, -1);

