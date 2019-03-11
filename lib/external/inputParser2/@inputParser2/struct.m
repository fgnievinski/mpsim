function out = struct (inPar2)
  %out = dispose (inPar2);
  inPar = inputParserStore ('pull', inPar2.counter);
  out = struct (inPar); 
end

