function answer = defrontal(A, opt)
    answer = A.data;
    if (nargin < 2),  return;  end
    if strcmp(opt, 'pt'),  answer = defrontal_pt(answer);  end
end

%function answer = defrontal(A, opt)
%    if (nargin < 2),  opt = '';  end
%    answer = A.data;
%    if strcmp(opt, 'pt'),  answer = defrontal_pt(answer);  end
%end

