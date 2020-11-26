function [out, pos, siz] = loadscan (filepath, format, fieldname, ...
ReturnOnError, CommentStyle, Delimiter, Whitespace, MultipleDelimsAsOne, varargin)
    isemptynonchar = @(in) isempty(in) && ~ischar(in);
    if (nargin < 2) || isempty(format),  format = '%f';  end
    if (nargin < 3),  fieldname = [];  end
    if (nargin < 4) || isempty(ReturnOnError),  ReturnOnError = false;  end
    if (nargin < 5) || isemptynonchar(CommentStyle),  CommentStyle = '%';  end
    if (nargin < 6) || isemptynonchar(Delimiter),  Delimiter = ' ';  end
    if (nargin < 7),  Whitespace = [];  end    
    if (nargin < 8) || isempty(MultipleDelimsAsOne),  MultipleDelimsAsOne = true;  end    
    if isemptynonchar(CommentStyle),  CommentStyleOpt = {};  else, CommentStyleOpt = {'CommentStyle',CommentStyle};  end
    if isemptynonchar(Delimiter),  DelimiterOpt = {};  else, DelimiterOpt = {'Delimiter',Delimiter};  end
    if isemptynonchar(Whitespace),  WhitespaceOpt = {};  else, WhitespaceOpt = {'Whitespace',Whitespace};  end
    MultipleDelimsAsOneOpt = {'MultipleDelimsAsOne',MultipleDelimsAsOne};
    
    opt = ['ReturnOnError',ReturnOnError, CommentStyleOpt DelimiterOpt WhitespaceOpt MultipleDelimsAsOneOpt];
%     fid = fopen_error(filepath);
%     str = fread(fid, Inf, '*char');
%     fclose(fid);    
%     out = textscan(str, format, opt{:}, varargin{:});
% % the above is slower
    fid = fopen_error(filepath);
    [out, pos] = textscan(fid, format, opt{:}, varargin{:});
    fseek(fid, 0, 'eof');  siz = ftell(fid);
    fclose(fid);    
    if ~isempty(fieldname)
        out = cell2struct(out, fieldname, 2);
    elseif iscell(out) && isscalar(out) && iscellstr(out{1})
        out = out{1};
    else
        try
            out = cell2mat(out);
        catch me
            if strcmp(me.identifier, 'MATLAB:cell2mat:MixedDataTypes')
                return
            else
                rethrow(me)
            end
        end
    end
end

