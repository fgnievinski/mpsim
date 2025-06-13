function [idx, idx_all] = is_in_period (epoch, limit, algorithm, check_for_equality)
%IS_IN_PERIOD:  Check if epochs are within delimited periods.

  if (nargin < 3) || isempty(algorithm),  algorithm = 1;  end
  if (nargin < 4) || isempty(check_for_equality),  check_for_equality = true;  end
  
  assert(isvector(epoch))
  assert(iscolvec(epoch))
  if isempty(limit),  limit = reshape(limit, [0 2]);  end
  [num_periods, num_cols] = size(limit);
  assert(num_cols==2 || (num_periods==0))
  limit_lower = limit(:,1);
  limit_upper = limit(:,2);
  if check_for_equality
    lw = @le;
  else
    lw = @lt;
  end
  switch algorithm
  case 1
    idx_all = bsxfun(lw, limit_lower', epoch) ...
            & bsxfun(lw, epoch, limit_upper');
    idx = any(idx_all, 2);
  case 2
    % sparser
    f = @(epochi, indj) lw(limit_lower(indj), epochi) ...
                      & lw(epochi, limit_upper(indj));
    idx_all = bsxfun(f, sparse(epoch), sparse(1:num_periods));
    idx = any(idx_all, 2);
    idx = full(idx);  % it is dense normally
  otherwise
    idx = false(size(epoch));
    for i=1:num_periods
      idxi = lw(limit_lower(i), epoch) & lw(epoch, limit_upper(i));
      idx = idx | idxi;
    end
    idx_all = [];
  end
  
  num_epochs = numel(epoch);
  if ( (num_periods==0) && (num_epochs~=0) )
    idx = false(num_epochs,1);
  end
end
