function epoch = mydate_lim2list (epoch_min, epoch_max, epoch_step)
    if (nargin < 2) || isempty(epoch_max),  epoch_max = epoch_min;  end
    if (nargin < 3) || isempty(epoch_step),  epoch_step = mydatedayi(1);  end
    assert(~ischar(epoch_min) && ~ischar(epoch_max))
    if (epoch_max < epoch_min)
        error('mydate:lim2list:badEpoch', ...
          ['First argument must be an epoch smaller than '...
           'second argument (was "%s", "%s")'], ...
            mydatestr (epoch_min, 'yymmmdd'), ...
            mydatestr (epoch_max, 'yymmmdd'));
    end
    epoch = (epoch_min:epoch_step:epoch_max)';
end

