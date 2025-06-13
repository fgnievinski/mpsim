function display (inPar2)
  %helper (inPar2);  % WRONG!
  inPar = inputParserStore ('pull', inPar2.counter);
  display (inPar);
end

