function out = frontal (in, opt)
    if isfrontal(in)
        out = in;
        return;
    end
    persistent out0
    if isempty(out0)
        out0 = class(struct('data',[]), 'frontal');
    end
    out = out0;
    out.data = in;
    if (nargin < 2),  return;  end
    if strcmp(opt, 'pt'),  out.data = frontal_pt(out.data);  end
    % If we try to create the class from an already filled-in structure,
    % Matlab will make a copy of the data fields. To avoid duplicating
    % the data, we shall create the class from an empty but defined 
    % structure and fill it in afterwards.
end

%function out = frontal (in, opt)
%    out = class(struct('data',[]), 'frontal');
%    out.data = in;
%    if (nargin < 2),  return;  end
%    if strcmp(opt, 'pt'),  out.data = frontal_pt(out.data);  end
%    % If we try to create the class from an already filled-in structure,
%    % Matlab will make a copy of the data fields. To avoid duplicating
%    % the data, we shall create the class from an empty but defined 
%    % structure and fill it in afterwards.
%end

%function out = frontal (in, opt)
%    if (nargin < 2),  opt = [];  end
%    persistent out0
%    if isempty(out0)
%        out0 = struct('data',[]);
%        out0 = class(out0, 'frontal');
%    end
%    if strcmp(opt, 'pt'),  in = frontal_pt(in);  end
%    out = out0;
%    out.data = in;
%    % If we try to create the class from an already filled-in structure,
%    % Matlab will make a copy of the data fields. To avoid duplicating
%    % the data, we shall create the class from an empty but defined 
%    % structure and fill it in afterwards.
%end

