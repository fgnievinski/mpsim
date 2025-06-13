function mat=deg2mat(ddeg)
    sig=sign(ddeg);
    ddeg=abs(ddeg);

    deg = fix(ddeg);
    min1=(ddeg-deg)*60;
    min=fix(min1);
    sec=(min1-min)*60;
    sec=((ddeg-fix(ddeg))*60 - fix((ddeg-fix(ddeg))*60))*60;

    mat = [deg, min, sec, sig];

    mat = mat_normal (mat);
end

%!test
%! deg = [0; -90; 90.5; -(90+1/3600); -(1/60); 180; 1; (90+1/60)];
%! mat = [...
%!     0, 0, 0, 0;
%!     90, 0, 0, -1;
%!     90, 30, 0, 1;
%!     90, 0, 1, -1;
%!     0, 1, 0, -1;
%!     180, 0, 0, 1;
%!     1, 0, 0, 1;
%!     90, 1, 0, 1;
%! ];
%! mat2 = deg2mat (deg);
%! %mat2, mat, mat2 - mat  % DEBUG
%! myassert (mat2, mat, -sqrt(eps));

%!test
%! n = ceil(10*rand);
%! temp = rand(n,1);
%! sig = ones(n,1);  sig(temp>0.5) = -1;
%! deg = ceil(rand(n,1)*180);
%! min = ceil(rand(n,1)*60);
%! sec = rand(n,1)*60;
%! mat = [deg, min, sec, sig];
%! 
%! %idx = sec == 60;  min(idx) = min(idx) + 1;  sec(idx) = 0; 
%! %idx = min == 60;  deg(idx) = deg(idx) + 1;  min(idx) = 0; 
%! 
%! ddeg = sig .* (deg + (min + sec/60)/60);
%! 
%! mat2 = deg2mat(ddeg);
%! err = mat2 - mat;
%! idx = any(abs(err) > sqrt(eps), 2);
%! %idx, [mat(idx,:), mat2(idx,:)], [deg(idx), min(idx), sec(idx)]  % DEBUG
%! myassert (err, 0, -sqrt(eps));

