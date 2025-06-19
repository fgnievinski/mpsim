function mysurf (X, Y, Z, C, lights)
    if (nargin < 4),  C = 0.35;  end
    if (nargin < 5),  lights = 4;  end
    if isscalar(C),  C = repmat(C, size(Z));  end
    surf(X, Y, Z, C)
    colormap(gray(256))
    set(gca, 'YDir','normal')
    shading interp    
    lighting phong
    material dull
    switch lights
    case 0
    case 1
        camlight('headlight')
    case 2
        camlight('right')
        camlight('left')
    case 3
%         lightangle(0,  90)
%         lightangle(0, -90)
        lightangle(0,   0)
        lightangle(0,  90)
        lightangle(0, 180)
        lightangle(0, 270)
    case 4
        light('Position',[1 0 0],'Style','infinite');
        light('Position',[0 1 0],'Style','infinite');
        light('Position',[0 0 1],'Style','infinite');
    end
    axis tight
    axis vis3d
    view(3)
end
