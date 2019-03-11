% 
% % Please use the link below to view the documentation.

% % If you don't see the link which is automatically inserted by MATLAB, 
% % try removing the line break above, so that this help block is merged 
% % with the previous one.
% % Reference page in help browser: <a href="matlab:doc parsepairs">parsepairs</a>

for k = 1:2:length(varargin(:))
    if ~strcmp(varargin{k}, AuthorizedOptions)
        s=dbstack;
        error(['Unauthorized parameter name ' 39 varargin{k} 39 ' in ' 10,...
            'parameter/value passed to ' 39 s(end-1).name 39 '.']);
    end
    eval([varargin{k},'=varargin{',num2str(k+1),'};'])
end

if ~isempty(varargin)
    clear k
end