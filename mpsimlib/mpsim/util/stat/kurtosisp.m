function kp = kurtosisp (kurt, var, dof, p, kurt0, var0, dof0)
    if (nargin < 4),      p = [];  end
    if (nargin < 5),  kurt0 = [];  end
    if (nargin < 6),   var0 = [];  end
    if (nargin < 7),   dof0 = [];  end
    robustify = false;
    kp = kurtosispr (kurt, var, dof, p, kurt0, var0, dof0, robustify);
end
