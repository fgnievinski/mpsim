function varargout = get_rotation_matrix2_local (dira, dirb, normalized)
    if (nargin < 3) || isempty(normalized),  normalized = [];  end
    [varargout{1:nargout}] = get_rotation_matrix2(dira, dirb, normalized);  % CORRECT
    %[varargout{1:nargout}] = get_rot_neu2xyz2neu(get_rotation_matrix2(neu2xyz(dira), neu2xyz(dirb), normalized));  % CORRET BUT UNNECESSARILY COMPLICATED
    %[varargout{1:nargout}] = get_rot_neu2xyz2neu(get_rotation_matrix2(dira, dirb, normalized);  % WRONG!
end

%!test
%! % R such that all(dirb == (R * dira(:).').'), for 
%! % dira, dirb unit and R orthogonal.
%! dira = normalize_pt(rand(1,3));
%! dirb = normalize_pt(rand(1,3));
%! dird = normalize_pt(rand(1,3));
%! 
%! R2 = get_rotation_matrix2_local (dira, dirb);
%! R3 = get_rot_neu2xyz2neu(get_rotation_matrix2(neu2xyz(dira), neu2xyz(dirb)));
%! dirb2 = (R2 * dira.').';
%! dirb3 = (R3 * dira.').';
%! dire2 = (R2 * dird.').';
%! dire3 = (R3 * dird.').';
%! 
%! [dirb; dirb2; dirb2 - dirb]  % DEBUG
%! [dirb; dirb3; dirb3 - dirb]  % DEBUG
%! [dire3; dire2; dire3 - dire2]  % DEBUG
%! 
%! myassert(dirb2, dirb, -100*eps())
%! myassert(dirb3, dirb, -100*eps())
%! myassert(dire3, dire2, -100*eps())

