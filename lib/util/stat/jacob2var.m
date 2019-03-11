function V = jacob2var (J, C, C_type)
%JACOB2VAR  Return propagated variances without forming full covariance.
% 
    if (nargin < 3) || (isempty(C_type) && ~ischar(C_type)),  C_type = 'symm';  end
    switch lower(C_type)
    case {'','any','none'}
        V = sum(J.*(J*C'), 2);
    case {'sym','symm','symmetric'}
        V = sum(J.*(J*C), 2);
    case {'id','identity'}
        V = sum(J.^2, 2);
    otherwise
        error('MATLAB:jacob2var:badArg', 'Unknown C_type "%s".', C_type);
    end
    % Here we exploit the fact that we can do fewer computations 
    % if we wish only variances or standard deviations, as opposed to full 
    % covariance matrices. The key is the expression:
    % 
    %     diag(J*C*J') = sum(J.*(J*C'),2)  % for any J, C
    % 
    % or the simpler:
    % 
    %     diag(J*C*J') = sum(J.*(J*C'),2)  % for C symmetric
    % 
    % or the simplest:
    % 
    %     diag(J*C*J') = sum(J.^2, 2)  % for C identity
    % 
    % The first expression was given by John D'Errico 
    % on the comp.soft-sys.matlab newsgroup (thread subject: 
    % "Diagonal of J matrix product- unavoidable for loop?", URL 
    % <http://groups.google.com/group/comp.soft-sys.matlab/browse_thread/thread/43772dc1064b4170/1c7b77158d64850e?lnk=st&q=diagonal+of+matrix+product#1c7b77158d64850e>).
end

%!test
%! n = ceil(10*rand);
%! m = ceil(10*rand);
%! J = rand(n,m);
%! C_any = rand(m,m);
%! C_sym = makeitsymm(C_any);
%! C_id = eye(m,m);
%! 
%! type = {'', 'symm', 'id'};
%! Cs = {C_any, C_sym, C_id};%! 
%! for i=1:numel(type)
%!     C = Cs{i};
%!     V = jacob2var (J, C, type{i});
%!     V2 = diag(J * C * J');
%!     err = max(abs(V - V2));
%!     %disp(err)  % DEBUG
%!     assert(err < sqrt(eps()))
%! end

