% unique values and number of duplicates.
function [out1, out2, m, n] = unique2 (in, varargin)
    %myassert (isvector(in));
    [out1, m, n] = unique(in, varargin{:});

    if (nargout < 2),  return;  end
    if isempty(in),  out2 = [];  return;  end
    
    % n gives the indices to unique values in vector in.
    % we prefer to handle n instead of in because in is always double.
    n = reshape(n, [], 1);
    ns = sort(n);
    % last occurence of each repeated value in sorted list:
    nd = diff(ns);  % diff of sorted n is zero for repeated values
    nidx = [nd ~= 0; true];
    nind = find(nidx);
    % difference between position of successive last occurences 
    % of each repeated value gives the number of repetitions  
    % of each unique value:
    out2 = diff([0; nind]);
    if (nargin > 1)
        out2 = reshape(out2, [size(out1,1) 1]);
        myassert (sum(out2), size(in,1));
    else
        out2 = reshape(out2, size(out1));
        myassert (sum(out2), length(in));
    end
end

%!test
%! A = [1 1 5 6 2 3 3 9 8 6 2 4];
%! [out1, out2] = unique2 (A);
%! myassert (out1, [1 2 3 4 5 6 8 9]);
%! myassert (out2, [2 2 2 1 1 2 1 1]);

%!test
%! A = [1 1 NaN NaN];
%! [out1, out2] = unique2 (A);
%! myassert (out1, [1 NaN NaN]);
%! myassert (out2, [2 1 1]);

%!test
%! A = {'aaa', 'bbb', 'aaa'};
%! [out1, out2] = unique2 (A);
%! myassert (out1, {'aaa', 'bbb'});
%! myassert (out2, [2 1]);

%!test
%! A = [1 2; 1 3; 1 2];
%! [out1, out2] = unique2 (A, 'rows');
%! myassert (out1, [1 2; 1 3]);
%! myassert (out2, [2; 1]);

%!test
%! [out1, out2] = unique2([]);
%! myassert (out1, []);
%! myassert (out2, []);

%!test
%! n = ceil(10*rand);
%! A = roundn(rand(n,1), -1);
%! % make sure there are repetitions:
%! if ~(length(unique(A)) < length(A))
%!     A = [A; A];
%! end
%! %A  % DEBUG
%! 
%! % Simpler, slower version:
%! in = A;
%! out1 = unique(A);
%! in_ind = 1:length(in);
%! out2 = zeros(size(out1));
%! for i=1:length(out1)
%!     if iscell(out1) && ischar(out1{i})
%!         temp = strcmp(in, out1{i});
%!     elseif isnan(out1(i))
%!         temp = isnan(out1(i));
%!     else
%!         temp = (in == out1(i));
%!     end
%!     out2(i) = sum(temp);
%! end
%! 
%! [ignore, out22] = unique2(A);
%! 
%! myassert(out22, out2);

