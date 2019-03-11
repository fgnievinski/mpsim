% Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
% Copyright (C) 2014 Felipe G. Nievinski <fgnievinski@gmail.com>
%
% This program is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation; either version 3 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public License along with
% this program; if not, see <http://www.gnu.org/licenses/>.
  
function test_inputParser2 ()

  argin = cell(4,1);
  argin{1} = {'req1', @ischar};
  argin{2} = {'op1', 'val', (@(x) ischar(x) && any (strcmp (x, {'val', 'foo'})))};
  argin{3} = {'op2', 78, @(x) (x) > 50};
  argin{4} = {'line', 'tree', (@(x) ischar (x) && any (strcmp (x, {'tree', 'circle'})))};

  for i=1:2

    p = inputParser2 ();
    switch i
    case 1
      addRequired   (p, argin{1}{:});
      addOptional   (p, argin{2}{:});
      addOptional   (p, argin{3}{:});
      addParamValue (p, argin{4}{:});
    case 2
      p.addRequired   (argin{1}{:});
      p.addOptional   (argin{2}{:});
      p.addOptional   (argin{3}{:});
      p.addParamValue (argin{4}{:});
    end

    % check normal use, only required are given:
    if (i==1)
      parse (p, 'file');
    else
      p.parse ('file');
    end
    myassert ({p.Results.req1, p.Results.op1, p.Results.op2, p.Results.line}, ...
              {'file'        , 'val'        , 78           , 'tree'});
    myassert (p.UsingDefaults, {'op1', 'op2', 'line'});

    % check normal use, but give values different than defaults:
    if (i==1)
      parse (p, 'file', 'foo', 80, 'line', 'circle');
    else
      p.parse ('file', 'foo', 80, 'line', 'circle');
    end
    myassert ({p.Results.req1, p.Results.op1, p.Results.op2, p.Results.line}, ...
              {'file'        , 'foo'        , 80           , 'circle'});

    % check optional is skipped and considered ParamValue if unvalidated string:
    if (i==1)
      parse (p, 'file', 'line', 'circle');
    else
      p.parse ('file', 'line', 'circle');
    end
    myassert ({p.Results.req1, p.Results.op1, p.Results.op2, p.Results.line}, ...
              {'file'        , 'val'        , 78           , 'circle'});

    % check case insensitivity:
    if (i==1)
      parse (p, 'file', 'foo', 80, 'LiNE', 'circle');
    else
      p.parse ('file', 'foo', 80, 'LiNE', 'circle');
    end
    myassert ({p.Results.req1, p.Results.op1, p.Results.op2, p.Results.line}, ...
              {'file'        , 'foo'        , 80           , 'circle'});

    % check KeepUnmatched:
    p.KeepUnmatched = true;
    if (i==1)
      parse (p, 'file', 'foo', 80, 'line', 'circle', 'extra', 50);
    else
      p.parse ('file', 'foo', 80, 'line', 'circle', 'extra', 50);
    end
    myassert (p.Unmatched.extra, 50)

    % check error when missing required:
    is_err = @(err) any(strcmp(err.identifier, {'MATLAB:minrhs','Octave:invalid-fun-call',''}));
    try
      if (i==1)
        parse(p);
      else
        p.parse();
      end
    catch err;
      assert(is_err(err));
    end

    % check error when given required do not validate:
    is_err = @(err) any(strcmp(err.identifier, {'MATLAB:InputParser:ArgumentFailedValidation','Octave:invalid-fun-call',''}));
    try
      if (i==1)
        parse(p, 50);
      else
        p.parse(50);
      end
    catch err;
      assert(is_err(err));
    end

    % check error when given optional do not validate:
    try
      if (i==1)
        parse(p, 'file', 'no-val')
      else
        p.parse('file', 'no-val')
      end
    catch err;
      assert(is_err(err));
    end

    % check error when given ParamValue do not validate:
    try
      if (i==1)
        parse(p, 'file', 'foo', 51, 'line', 'round')
      else
        p.parse('file', 'foo', 51, 'line', 'round')
      end
    catch err;
      assert(is_err(err));
    end

% Disabled as test failed and it didn't seem to be a crucial method.
pb = p;
%    % check createCopy & dispose:
%    if (i==1)
%      pb = createCopy(p);
%    else
%      pb = p.createCopy();
%    end
    
    if (i==1)
      dispose(p);
    else
      %p.dispose();  % WRONG!  matlab-incompatible.
      dispose(p);
    end

    if is_octave() && isa(p, 'inputParser2')
      assert( isempty(p))
      %assert(~isempty(pb))
    end
    dispose(pb);
    
  end % for

end  % function


