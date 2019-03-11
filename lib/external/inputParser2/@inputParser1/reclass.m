function inPar = reclass (inParOld, inParNew)
  assert(isa(inParOld, 'inputParser1'));
  if isa(inParNew, 'inputParser1')
    inPar = inParNew;
  else
    assert(isa(inParNew, 'struct'));
    inPar = class(inParNew, 'inputParser1');
  end
end

