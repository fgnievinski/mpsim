function out = atan2d (varargin)
    out = atan2(varargin{:})*180/pi;
end

% function varargout = atan2d (varargin)
%     disp('hw!')
%     try
%         [varargout{1:nargout}] = builtin ('isequaln', varargin{:});
%     catch
%         [varargout{1:nargout}] = myatan2d(varargin{:});
%     end
% end
% 
% function out = myatan2d (varargin)
%     out = atan2(varargin{:})*180/pi;
% end
% 
