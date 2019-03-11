function inPar2 = inputParser2 (varargin)
  if ~is_octave()
      inPar2 = inputParser(varargin{:});
      return;
  end

  if compare_versions(version(), '4.2', '>=') ...
  || (exist('inputParser') && isempty(strfind(which('inputParser'), ['@inputParser' filesep() 'inputParser.m'])))
      % use Octave core inputParser implementation:
      inPar2 = inputParser (varargin{:});
      return;
  end

  persistent counter
  if isequal(counter, [])
  %if isempty (counter)  % didn't work with Octave 3.8
    counter = 1;
  end
  %counter % DEBUG
  
  inPar = inputParser1(varargin{:});
  inputParserStore ('push', counter, inPar);
  inPar2 = struct ('counter',counter);
  inPar2 = class (inPar2, 'inputParser2');
  counter = counter + 1;
end

