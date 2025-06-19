function answer = isdiag (A)
    error(nargchk(1, 1, nargin, 'struct'));
    error(nargoutchk(0, 1, nargout, 'struct'));

    % degenerate shape:
    if ( isempty(A) || isscalar(A) || ~issquare(A) )
        answer = false;
        return;
    end
    
% %    % diagonal?
% %    idx = ~diag(true(length(A), 1));
% %    if ~any(A(idx))
% %        answer = true;
% %        return;
% %    end
%     % check one triangular part at a time,
%     % to use less memory:
%     answer = istril(A) && istriu(A);

    siz = size(A);
    ind_diag = sub2ind(siz, 1:siz(1), 1:siz(2))';  % index of diagonal elements.
    ind_nz = find(A);  % index of non-zero elements.
    %ind_diag, ind_nz, all(ismember(ind_nz, ind_diag))  % DEBUG
    answer = isempty(ind_nz) || all(ismember(ind_nz, ind_diag));
end

%!test
%! % isdiag ()
%! do_test_blank_diag_tri_sym;

