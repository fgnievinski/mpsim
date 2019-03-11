function set_default_font_size (varargin)
  switch nargin
  case 2
      [fh, fs] = varargin{:};
  case 1
      if ishandle(varargin{1}) && isvalid(varargin{1})
          fh = varargin{1};
          fs = [];
      else
          fs = varargin{1};
          fh = [];
      end
  case 0
      fh = [];
      fs = [];
  end
  %fh_default = gcf();
  fh_default = 0;
  if isempty(fh),  fh = fh_default;  end
  if isempty(fs),  fs = 'factory';  end
  set(fh, 'DefaultAxesFontSize',fs, 'DefaultTextFontSize',fs) 
end
