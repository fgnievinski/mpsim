function str = deg2str (ddeg, type, sec_prec)
    if (nargin == 1) && (size(ddeg,2) >= 2)
        str = cell(1,2);
        str{1} = deg2str (ddeg(:,1), 'lat');
        str{2} = deg2str (ddeg(:,2), 'lon');
        return;
    end       
    myassert (nargin >= 2 && any(strcmp(type, {'lat', 'lon'})) )
    if (nargin < 3),  sec_prec = 5;  end

    n = numel(ddeg);
    hemisph = repmat(' ', n, 1);
    if strcmp(type, 'lat')
        hemisph(:) = 'N';
        hemisph(ddeg < 0) = 'S';
        deg_places = 2;
    elseif strcmp(type, 'lon')
        hemisph(:) = 'E';
        hemisph(ddeg < 0) = 'W';
        deg_places = 3;
    end

    mat = abs(deg2mat(ddeg));
    mat(:,end) = [];
    
    format = sprintf('%%0%ddº%%02d''%%0%d.%df"%%c', ...
        deg_places, sec_prec+3, sec_prec);
    temp = sprintf(format, [mat double(hemisph)]');
    siz = [numel(ddeg), numel(sprintf(format, 1, 1, 1, 'N'))];
    %format, mat, hemisph, temp, siz  % DEBUG
    str = transpose(reshape(temp, siz(2), siz(1)));
end
