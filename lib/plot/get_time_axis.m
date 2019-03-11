function time_axis = ...
get_time_axis (num_epochs, epoch_int, num_epochs_per_bin, time_units)

    if (nargin < 3)
        num_epochs_per_bin = 1;
    end
    if (nargin < 4)
        time_units = 3600;  % 1 hour interval
    end
        
    time_axis = epoch_int * (0:(num_epochs-1)) / time_units;

    if (num_epochs_per_bin > 1)
        time_axis = transpose( compute_statistic (...
        'mean', time_axis', num_epochs_per_bin) );
    end

return;  % end of function

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test block.

%!shared num_epochs, epoch_int, units, correct_time_axis
%! num_epochs = 6;
%! epoch_int = 900;  % seconds

%!test
%! correct_time_axis = [0 1 2 3 4 5] * 900 / 3600;
%!
%! answer_time_axis = get_time_axis (num_epochs, epoch_int);
%! 
%! myassert (answer_time_axis == correct_time_axis);

%!test
%! time_units = 60;  % 60 seconds per minute
%! correct_time_axis = [0 1 2 3 4 5] * 900 / 60;
%!
%! answer_time_axis = get_time_axis (num_epochs, epoch_int, 1, time_units);
%! 
%! myassert (answer_time_axis == correct_time_axis);

%!test
%! time_units = 1;  % 60 seconds per minute
%! correct_time_axis = [0 1 2 3 4 5] * 900 / 1;
%!
%! answer_time_axis = get_time_axis (num_epochs, epoch_int, 1, 1);
%! 
%! myassert (answer_time_axis == correct_time_axis);

%!test
%! num_epochs_per_bin = 3;
%! correct_stats_time_axis = [(0+1+2)/3 (3+4+5)/3] * 900 / 3600;
%!
%! answer_time_axis = get_time_axis (num_epochs, epoch_int, num_epochs_per_bin);
%! 
%! myassert (answer_time_axis == correct_stats_time_axis);

%!test
%! num_epochs_per_bin = 2;
%! correct_stats_time_axis = [(0+1)/2 (2+3)/2 (4+5)/2] * 900 / 3600;
%!
%! answer_time_axis = get_time_axis (num_epochs, epoch_int, num_epochs_per_bin);
%! 
%! myassert (answer_time_axis == correct_stats_time_axis);

