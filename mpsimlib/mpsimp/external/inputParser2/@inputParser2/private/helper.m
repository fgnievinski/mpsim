function helper (inPar2, varargin)
  tmp = get_caller_name ();
  fnc = @(inPar) feval (tmp, inPar, varargin{:});
  helper_aux (inPar2, fnc);
end

function helper_aux (inPar2, fnc)
  inPar = inputParserStore ('pull', inPar2.counter);
  inPar = fnc (inPar);
  inputParserStore ('push', inPar2.counter, inPar);
end

