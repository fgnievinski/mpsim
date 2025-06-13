function test_blank_diag_tri_sym (test_packed)
if (nargin == 0),  test_packed = false;  end

% empty:
A = [];
if test_packed,  A = packed(A);  end
myassert (~isblank(A));
myassert (~isdiag(A));
myassert (~istril(A));
myassert (~istriu(A));
myassert (~issym(A));

% scalar:
A = 1;
if test_packed,  A = packed(A);  end
myassert (~isblank(A));
myassert (~isdiag(A));
myassert (~istril(A));
myassert (~istriu(A));
myassert (~issym(A));

% non-square:
A = [1 2];
if test_packed,  A = packed(A);  end
myassert (~isblank(A));
myassert (~isdiag(A));
myassert (~istril(A));
myassert (~istriu(A));
myassert (~issym(A));

% blank:
A = zeros(2,2);
if test_packed,  A = packed(A);  end
myassert (isblank(A));
myassert (isdiag(A));
myassert (istril(A));
myassert (istriu(A));
myassert (issym(A));

% diagonal:
A = eye(2,2);
if test_packed,  A = packed(A);  end
myassert (~isblank(A));
myassert (isdiag(A));
myassert (istril(A));
myassert (istriu(A));
myassert (issym(A));

% lower triangular:
A = [1 0; 2 1];
if test_packed,  A = packed(A);  end
myassert (~isblank(A));
myassert (~isdiag(A));
myassert (istril(A));
myassert (~istriu(A));
myassert (~issym(A));

% upper triangular:
A = [1 2; 0 1];
if test_packed,  A = packed(A);  end
myassert (~isblank(A));
myassert (~isdiag(A));
myassert (~istril(A));
myassert (istriu(A));
myassert (~issym(A));

% symmetric:
A = [1 2; 2 1];
if test_packed,  A = packed(A);  end
myassert (~isblank(A));
myassert (~isdiag(A));
myassert (~istril(A));
myassert (~istriu(A));
myassert (issym(A));

% symmetric with only NaNs and zeros:
A = [0, NaN; NaN, 0];
myassert (~isblank(A));
myassert (~isdiag(A));
myassert (~istril(A));
myassert (~istriu(A));
myassert (issym(A));

end


% MATRIX SHAPES
% 
% An empty matrix (size 0x0)...
%     is empty
%     is not a scalar
%     is not square
%     is not blank
%     is not diag
%     is not tri
%     is not sym
% 
% A scalar (size 1x1)...
%     is not empty
%     is a scalar
%     is square
%     is not blank
%     is no diag
%     is not tri
%     is not sym
% 
% A not square matrix (size mxn, m~=n)...
%     is not empty
%     is not a scalar
%     is not square
%     is not blank
%     is not diag
%     is not tri
%     is not sym
% 
% 
% MATRIX STRUCTURES
% 
% Definitions: all matrices below are not empty, not scalar, square.
% - "blank": all zeroes;
% - "diagonal": upper and lower triangular parts (not including main diagonal) 
%               are all zeroes;
% - "triangular": upper or lower or both triangular parts (not including main 
%                 diagonal) are all zeroes;
% - "symmetric": upper triangular part equals transpose of lower triangular 
%                part (including main diagonal).
% 
% A blank matrix...
%     is blank
%     is diagonal
%     is triangular
%     is symmetric
% 
% A diagonal matrix...
%     may be blank
%     is diagonal
%     is triangular
%     is symmetric
% 
% A triangular matrix...
%     may be blank
%     may be diagonal
%     is triangular
%     is not symmetric
% 
% A symmetric matrix...
%     may be blank
%     may be diagonal
%     is not triangular
%     is symmetric
% 
% 
% Or, in other words,
% 
% a blank matrix is
% a diagonal matrix may be
% a triangular matrix may be
% a symmetric matrix may be
%     ... blank.
% 
% a blank matrix is
% a diagonal matrix is
% a triangular matrix may be
% a symmetric matrix may be
%     ... diagonal.
% 
% a blank matrix is
% a diagonal matrix is
% a triangular matrix is
% a symmetric matrix may be
%     ... triangular.
% 
% a blank matrix is
% a diagonal matrix is
% a triangular matrix may be
% a symmetric matrix is
%     ... symmetric.
% 
% 
% MATRIX TYPES
% 
% A matrix stored as a packed object can be one and only one of the 
% types: '', 'tri', or 'sym'.
% 
% Note: to keep things simple, we have decided to _not_ assure that an object 
% has not a simpler structure. E.g., a packed object defined as type 
%     triangular,
%     symmetric
% may have data actually making up, respectively, an
%     diagonal, blank, or empty,
%     diagonal, blank, or empty
% matrix.

