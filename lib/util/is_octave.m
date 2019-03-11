function answer = is_octave ()
    persistent theanswer
    if isempty(theanswer),  theanswer = exist ('OCTAVE_VERSION', 'builtin');  end
    answer = theanswer;
    % OCTAVE_VERSION is a built-in system constant 
    % available only in Octave, not in Matlab.

%!demo
%! if is_octave()
%!     msg = 'You are using Octave.\n';
%! else
%!     msg = 'You are NOT using Octave (probably you''re using Matlab).\n';
%! end
%! fprintf(1, msg);
