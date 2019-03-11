function uistack2(h,opt,step)

% UISTACK2 Restacks objects.
%
%   UISTACK2(H,STACKOPT,STEP) where STACKOPT is 'up','down','top' or
%   'bottom' modifies the visual stacking order of objects with handles H.
%   STEP is the distance to move 'up' and 'down'.
%
%   UISTACK2(H,STACKOPT) use default value STEP=1
%
%   All handles, H, must have the same parent.
%
%   UISTACK2('undo') sets previous visual stacking order back. UISTACK2(H,...) 
%   must be obviously used first.
%  
%   When using array of handles H, the final ordering will always be : 
%   first element of H --> toppest moved objects, last element of H -> lowest 
%
%   UISTACK2 treats handles as individual entities. Be careful
%   when using UISTACK2 with objects created by functions that may return 
%   multiple handles (PLOT, LINE...)
%
%   UISTACK2 is based on the Matlab® UISTACK function (by Loren Dean). It solves 
%   the problem illustrated by the example below :
%
%       figure
%       subplot(2,1,1);
%       plot([1 5],[2 7]);
%       p=patch([2 4 4 2],[3 3 4 4],'r');
%       uistack(p,'bottom'); % the red patch SHOULD be placed under the blue line
%       title('UISTACK behavior')
%       subplot(2,1,2);
%       plot([1 5],[2 7]);
%       p=patch([2 4 4 2],[3 3 4 4],'r');
%       uistack2(p,'bottom'); % the red patch IS placed under the blue line
%       title('UISTACK2 behavior')

%   Author: Jérôme
%   Contact: dutmatlab@yahoo.fr
%   Version: 1.2 (07 Aug 2006)
%   Comments:
%

if nargin==0 % UISTACK2
    
    error('No enough input argument')
    
elseif nargin==1 % UISTACK2('undo')
    
    if ~strcmpi(h,'undo')
        
        error('Single input argument should be ''undo''')
        
    else h=[];
         opt='undo';

    end
    
elseif nargin==2 % UISTACK2(H,STACKOPT)
    
    step=1;
    
end

if any(~ishandle(h))
    
    error('H argument must only contained object handles');
    
end

if ~isempty(h) % UISTACK2(H,STACKOPT) or  % UISTACK2(H,STACKOPT,STEP)

    h=h(:);
    p=get(h,'parent');

	if iscell(p)
        
        p=[p{:}];
        
	end
	
    % Check for unique parent of H
	p=unique(p);
	
	if numel(p)>1
        
        error('Objects must have the same parent');
        
	end
	
	children_handles=get(p,'children');
    
    % Store data for 'undo' feature
    if isappdata(0,'uistack2undodata')
    
        temp=getappdata(0,'uistack2undodata');
       
        try
        
            setappdata(0,'uistack2undodata',[temp [p;children_handles]]);
            
        catch setappdata(0,'uistack2undodata',[p;children_handles]);
            
        end
        
    else setappdata(0,'uistack2undodata',[p;children_handles]);
        
    end

	idx=find(ismember(children_handles,h));
    
    if isempty(idx)
        
        return
        
    end   
    
else return
    
end

switch opt
    
	case 'up'
        
        n=1:length(children_handles);

		for k=1:length(idx)
            
            n(idx(k))=n(idx(k))-step-0.5-(k-1);
		
		end
            
		[noneed,n]=sort(n);
		children_handles=children_handles(n);
        
	case 'down'
        
        n=1:length(children_handles);
        
        for k=length(idx):-1:1
    
            n(idx(k))=n(idx(k))+step+0.5+(length(idx)-k);
	
		end
            
		[noneed,n]=sort(n);
		children_handles=children_handles(n);
        
	case 'bottom'
        
        children_handles(idx)=[];
        if ~isempty(children_handles)
        children_handles=[children_handles;h];
        end
        
	case 'top'
	
        children_handles(idx)=[];
        if ~isempty(children_handles)
        children_handles=[h;children_handles];
        end 
        
	case 'undo'
        
        if isappdata(0,'uistack2undodata')
            
            temp=getappdata(0,'uistack2undodata');
            p=temp(1,end);
            children_handles=temp(2:end,end);
            temp(:,end)=[];
	
            if isempty(temp)
        
                rmappdata(0,'uistack2undodata');
            
            else setappdata(0,'uistack2undodata',temp)
                
            end
            
        else error('No data stored for UNDO operation')
            
        end
        
	otherwise
        
        error('Invalid stack option for UISTACK2');
    
end

set(p,'children',children_handles)