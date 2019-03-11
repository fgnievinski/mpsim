function out = isempty (inPar2)
  inPar = inputParserStore ('pull', inPar2.counter);
  out = isempty (inPar);
end

