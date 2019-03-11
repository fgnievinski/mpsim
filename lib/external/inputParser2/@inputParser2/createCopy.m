function inPar2 = createCopy (inPar2)
  inPar = inputParserStore ('pull', inPar2.counter);
  inPar2 = inputParser2 ();
  inputParserStore ('push', inPar2.counter, inPar);
end

