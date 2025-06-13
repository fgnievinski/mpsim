function ge_kmz(kmzFileName,varargin)
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_kmz.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%

AuthorizedOptions = authoptions( mfilename );


% Assign default values to parameters:
msgToScreen = false;
resourceURLs = {};
kmzTargetDir = pwd;

%p = mfilename('fullpath');
%[toolboxroot, pname, ext, versn]=fileparts(p);
tmpDir = [kmzTargetDir,filesep,'tmp'];

parsepairs %script that parses Parameter/value pairs.

resourceURLs = resourceURLs(:); %for easier debugging.

if msgToScreen
   disp(['Running ' mfilename '...']) 
end
% if ~isempty(findstr(kmzTargetDir,' '))
%     error(['Use of spaces in parameter ' 39,'kmzTargetDir',39,' is not allowed.'])
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if strcmp(kmzFileName(end-3:end),'.kmz')

    if ispc
        if exist(tmpDir,'dir')==7
           system(['del "',tmpDir,filesep,'*" /Q']);
           system(['rd "',tmpDir,'" /S /Q']);
        end
        system(['mkdir "',tmpDir,'"']);
              
        
        if msgToScreen
            disp('Retrieving kmz resources files...')
        end
        n=1;
        N=length(resourceURLs);
        
        while n<=N
            if isdir(resourceURLs{n})
                if ~isequal(resourceURLs{n}(end),filesep)
                    resourceURLs{n}=[resourceURLs{n},filesep];
                end
                
                c=dir(resourceURLs{n});
                
                for k=3:length(c)
                    resourceURLs{end+1}=[resourceURLs{n},c(k).name];
                end
                clear c
                N=length(resourceURLs);
                resourceURLs=resourceURLs([1:n-1,n+1:N]);
                N=N-1;
            end
            t = ['copy "',resourceURLs{n},'" "',tmpDir,filesep,'" /Y'];
            system(t);
            [pathstr, name, ext, versn] = fileparts(resourceURLs{n});
            resourceURLs{n}=[name,ext];
            clear pathstr name ext versn            
            n=n+1;
        end
        clear n N
        if msgToScreen
            disp('Retrieving kmz resources files...Done')
        end

        olddir=pwd;
        cd(tmpDir);
        
        for i=1:length(resourceURLs)
            if ~exist(resourceURLs{i},'file')
                error(['File: ',39,tmpDir,filesep,resourceURLs{i},39,' does not exist.',10,...
                    'Error in function <a href=',34,'matlab:edit(',39,mfilename,39,...
                    ')',34,'>',mfilename,'</a>.'])
            end
        end

        zip(kmzFileName,resourceURLs);
        system(['ren ',kmzFileName, '.zip ', kmzFileName]);
        system(['move ' kmzFileName,' "',kmzTargetDir,'"']);
   
        cd(olddir);
        system(['rd "',tmpDir,'" /S /Q']);        
        
    else
        
        system(['rm -fr ',tmpDir]);
        system(['mkdir ',tmpDir]);
        
        if msgToScreen
            disp('Retrieving kmz resources files...')
        end
        n=1;
        N=length(resourceURLs);
        while n<=N
            if isdir(resourceURLs{n})
                if ~isequal(resourceURLs{n}(end),filesep)
                    resourceURLs{n}=[resourceURLs{n},filesep];
                end
                c=dir(resourceURLs{n});
                for k=3:length(c)
                    resourceURLs{end+1}=[resourceURLs{n},c(k).name];
                end
                clear c
                N=length(resourceURLs);
                resourceURLs=resourceURLs([1:n-1,n+1:N]);
                N=N-1;
            end
            system(['cp -fr ',resourceURLs{n},' ',tmpDir,filesep])
            [pathstr, name, ext, versn] = fileparts(resourceURLs{n});
            resourceURLs{n}=[name,ext];
            clear pathstr name ext versn            
            n=n+1;
        end
        clear n N
        if msgToScreen
            disp('Retrieving kmz resources files...Done')
        end

        olddir=pwd;
        cd(tmpDir);
        
        for i=1:length(resourceURLs)
            if ~exist(resourceURLs{i},'file')
                error(['File: ',39,tmpDir,filesep,resourceURLs{i},39,' does not exist.',10,...
                    'Error in function <a href=',34,'matlab:edit(',39,mfilename,39,...
                    ')',34,'>',mfilename,'</a>.'])
            end
        end

        zip(kmzFileName,resourceURLs);
        system(['mv ',kmzFileName, '.zip ', kmzFileName])
        system(['mv ' ,tmpDir,filesep,kmzFileName,' ',kmzTargetDir])
%         for f=1:length(resourceURLs)
%             eval(['!rm ',resourceURLs{f}])
%         end
        cd(olddir);
        system(['rm -fr ',tmpDir]);

        
    end
   
else
    error(['unsupported file extension used in function: ' mfilename]);
end


if msgToScreen
   disp(['Running ' mfilename '...Done']) 
end