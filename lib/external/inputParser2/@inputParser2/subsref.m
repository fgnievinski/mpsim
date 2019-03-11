function out = subsref (inPar2, idx)
  if ~strcmp(idx(1).type, '.'),  return;  end
  switch idx(1).subs
  case 'dispose'
    % make sure this matlab-incompatible syntax is not available:
    error('Invalid syntax; call dispose(...) instead');
  case {'parse','createCopy'}
    argin = {};
    if (numel(idx) > 1) && strcmp(idx(2).type, '()')
      argin = idx(2).subs;
    end
    out = feval(idx(1).subs, inPar2, argin{:});
  case {'Results', 'Parameters', 'Unmatched', 'UsingDefaults'}
    inPar = inputParserStore ('pull', inPar2.counter);
    inPar = struct(inPar);
    out = subsref (inPar, idx);
  case {'addOptional', 'addParamValue', 'addRequired'}
    inPar = inputParserStore ('pull', inPar2.counter);
    inPar = subsref (inPar, idx);
    assert(isa(inPar, 'inputParser1'))
    inputParserStore ('push', inPar2.counter, inPar);
    out = inPar2;
  end
end

