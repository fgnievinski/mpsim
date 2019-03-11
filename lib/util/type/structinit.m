function sout = structinit (sin, val)
    if (nargin < 2),  val = [];  end
    sout = structfun2(@(f) val, sin);
end
