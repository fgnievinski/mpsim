% This function is shared by isequal.m and 
% isequalwithequalnans.m
function answer = isequal2 (fisequal, varargin)
    if (nargin < (2+1))
        temp = sprintf('packed:%s:notEnoughInputs', fisequal);
        error (temp, 'Not enough input parameters.');
    elseif (nargin > (2+1))
        answer =   feval(fisequal, varargin{1}, varargin{2}) ...
                 & feval(fisequal, varargin{2:end});
        return;
    end
    myassert (nargin == (2+1));
    
    A = varargin{1};
    B = varargin{2};
    
    if (isempty(A) && isempty(B))
        answer = true;
        return;
    elseif ~isequal(size(A), size(B))
        answer = false;
        return;
    elseif (~ispacked(A) && ~ispacked(B))
        answer = feval(fisequal, A, B);
        return;
    elseif xor(ispacked(A), ispacked(B))
        answer = feval(fisequal, full(A), full(B));
        return;
    elseif (ispacked(A) && ispacked(B))
        if feval(fisequal, struct(A), struct(B))
            answer = true;
            return;
        else
            temp = ~strcmp(A.type, B.type) || ~strcmp(A.uplow, B.uplow);
            if strcmp(fisequal, 'isequal')
                temp = temp || any(isnan(A.data)) || any(isnan(B.data));
            end
            myassert (temp);
            % Their data contents may still be the same (e.g., 
            % a diagonal matrix stored as triangular or symmetric type).
            answer = feval(fisequal, full(A), full(B));
            return;
        end
    end
end

%!test
%! % isequal2 ()
%! test('isequal', 'packed');
%! test('isequalwithequalnans', 'packed');

