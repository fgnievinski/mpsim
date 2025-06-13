function out = inputParserStore (command, counter, in)
  #mlock()
  persistent temp
  if isempty(temp),  temp = {};  end
  #counter
  #temp
  switch command
  case 'push'
    temp{counter} = in;
  case 'pull'
    out = temp{counter};
  end
end

