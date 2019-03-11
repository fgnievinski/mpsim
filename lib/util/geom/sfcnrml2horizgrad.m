function varargout = sfcnrml2horizgrad (dir_nrml)
    horiz_grad = -dir_nrml(:,1:2) ./ repmat(dir_nrml(:,3), [1,2]);
    %horiz_grad = -repmat(dir_nrml(:,3), [1,2]) ./ dir_nrml(:,1:2);  % WRONG!
    switch nargout
    case 1
        varargout{1} = horiz_grad;
    case 2
        horiz_grad = neu2xyz(horiz_grad);
        dz_dx = horiz_grad(:,1);
        dz_dy = horiz_grad(:,2);
        varargout{1} = dz_dx;
        varargout{2} = dz_dy;
    end
end

%!test
%! test('horizgrad2sfcnrml')

