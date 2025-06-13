function alpha2 = get_outlier_alpha2 (num_tests, alpha, type)
    %type_default = 'bonferroni';
    type_default = 'sidak';
        if (nargin < 2) || isempty(alpha),  alpha = 5/100;  end
    if (nargin < 3) || isempty(type),  type = type_default;  end
    if islogical(type) && (type==false),  alpha2 = alpha;  return;  end
    switch lower(type)
    case {'student','none'}
        alpha2 = alpha;
    case 'bonferroni'
        alpha2 = alpha./num_tests;
    case 'sidak'
        alpha2 = 1 - (1-alpha).^(1./num_tests);
    otherwise
        error('MATLAB:get_outlier_statistic:unkType', ...
            'Unknown type "%s".', char(type));
    end
end

%!test
%! % get_outlier_alpha2()
%! test get_outlier_statistic
