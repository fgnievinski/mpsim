function J_out = defrontal_flat2 (J_in, varargin)
    if (nargin > 3)
        J_out = defrontal_flat2c (J_in);
        return;
    elseif (nargin > 2)
        J_out = defrontal_flat2b (J_in);
        return;
    elseif (nargin > 1)
        J_out = defrontal_flat2a (J_in);
        return;
    end

    J_out = reshape(permute(J_in, [3,1,2]), [], size(J_in,2));
end

function J_out = defrontal_flat2a (J_in)
    [num_coords, num_params, num_pts] = size(J_in);
      myassert(num_coords, 3);
    J_out = zeros(num_pts * num_coords, num_params, 1);
    for i=1:num_pts
        J_out(          i,:) = J_in(1,:,i);
        J_out(1*num_pts+i,:) = J_in(2,:,i);
        J_out(2*num_pts+i,:) = J_in(3,:,i);
    end
end

function J_out = defrontal_flat2b (J_in)
    myassert (size(J_in,1) == 3);
    J_out = [...
        squeeze(J_in(1,:,:)).';
        squeeze(J_in(2,:,:)).';
        squeeze(J_in(3,:,:)).';
    ];
end

function J_out = defrontal_flat2c (J_in)
    [m,n,o] = size(J_in);
    J_out = zeros(m*o,n);
    for i=1:m
        J_out((i-1)*o+(1:o),:) = squeeze(J_in(i,:,:)).'; 
    end
end

%!test
%! num_coords = 3;
%! num_pts = ceil(10*rand);
%! num_params = 7;
%! % this would be the parameters design matrix of a similarity transformation.
%! J_in = rand(num_coords, num_params, num_pts);
%! J_out  = defrontal_flat2 (J_in);
%! J_outa = defrontal_flat2 (J_in, []);
%! J_outb = defrontal_flat2 (J_in, [], []);
%! J_outc = defrontal_flat2 (J_in, [], [], []);
%! %J_out, J_outa, J_outb, J_outc  % DEBUG
%! myassert (J_out, J_outa);
%! myassert (J_out, J_outb);
%! myassert (J_out, J_outc);

%!test
%! num_coords = 2;
%! num_pts = ceil(10*rand);
%! num_params = 7;
%! J_in = rand(num_coords, num_params, num_pts);
%! J_out  = defrontal_flat2 (J_in);
%! %J_outa = defrontal_flat2 (J_in, []);
%! %J_outb = defrontal_flat2 (J_in, [], []);
%! J_outc = defrontal_flat2 (J_in, [], [], []);
%! %J_out, J_outc  % DEBUG
%! myassert (J_out, J_outc);

%!test
%! % complex-valued input:
%! num_coords = 3;
%! num_pts = ceil(10*rand);
%! num_params = 7;
%! % this would be the parameters design matrix of a similarity transformation.
%! J_in = rand(num_coords, num_params, num_pts);
%! J_in = complex(J_in, J_in);
%! J_out  = defrontal_flat2 (J_in);
%! J_outa = defrontal_flat2 (J_in, []);
%! J_outb = defrontal_flat2 (J_in, [], []);
%! J_outc = defrontal_flat2 (J_in, [], [], []);
%! %J_out, J_outa, J_outb, J_outc  % DEBUG
%! myassert (J_out, J_outa);
%! myassert (J_out, J_outb);
%! myassert (J_out, J_outc);


