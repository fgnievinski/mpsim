function inPar2 = parse (inPar2, varargin)
  inParOld = inputParserStore ('pull', inPar2.counter);
  inParNew = parse (inParOld, varargin{:});
  inPar = reclass(inParOld, inParNew);
  inputParserStore ('push', inPar2.counter, inPar);  
end

