function char = arm2char (arm, char_true, char_false)
    if (nargin < 2),  char_true  = 'Asc.';  end
    if (nargin < 3),  char_false = 'Desc.';  end
    logical = (arm == 1);
    char = logical2char(logical, char_true, char_false);
end
