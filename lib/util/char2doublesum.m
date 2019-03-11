function val = char2doublesum (txt, pt_col)
%CHAR2DOUBLESUM: Convert numbers in fixed-format character strings.

    num_cols = size(txt,2);
    if (nargin < 2),  pt_col = [];  end
    
    %% find out where is the decimal separator:
    if isempty(pt_col)      
        idx = (txt == '.');
        cnt = sum(idx,2);
        assert(all(cnt<=1))  % no more than one decimal separator per number
        if any(idx(:))
            %J = output(@() find(idx), 2);
            [~, J] = find(idx);
            pt_col = mode(J);
        else
            pt_col = NaN;
        end
    end
    
    %% or assume input are integer numbers:
    if isnan(pt_col),  pt_col = num_cols + 1;  end
    
    %% discard decimal separator from the summation:
    if (pt_col <= num_cols)
        txt(:,pt_col) = [];
        num_cols = num_cols - 1;
    end
    
    %% detect and disable negative sign:
    idx = (txt=='-');
    cnt = sum(idx,2);
    assert(all(cnt<=1))  % no more than one negative sign per number
    txt(idx) = '0';
    
    %% detect and disable missing data:
    txt(txt == ' ') = '0';
    
    %% convert each digit:
    num = char2double (txt);
    
    %% define power-of-ten factors:
    exp = pt_col - (1:1:num_cols) - 1;
    pow = 10.^exp;
    
    %% multiply and sum the contribution of each digit:
    val = sum(bsxfun(@times, num, pow), 2);
    
    %% apply negative sign:
    val(cnt>0) = -val(cnt>0);
    
    %% round output value up to input precision:
    %tmp = num_cols - pt_col - 1;  % WRONG!
    tmp = pt_col - num_cols - 1;
    val = roundn(val, tmp);
end

%!test
%! num2 = char2doublesum (['123';'406']);
%! myassert(num2, [123; 406], eps());

%!test
%! num2 = char2doublesum (['12.3';'40.6']);
%! myassert(num2, [12.3; 40.6], eps());

%!test
%! num2 = char2doublesum (['12.3';' 0.6']);
%! myassert(num2, [12.3;  0.6], eps());

%!test
%! num2 = char2doublesum (['12.3';'-0.6']);
%! num = [12.3; -0.6];
%! num2-num  % DEBUG
%! myassert(num2, num, eps());

%!test
%! num2 = char2doublesum('167571.734')
%! myassert(num2, 167571.734);

