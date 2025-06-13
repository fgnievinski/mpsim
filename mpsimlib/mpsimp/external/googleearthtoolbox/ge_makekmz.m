function ge_makekmz(kmzFileName,varargin)

AuthorizedOptions = {'sources','destinations'};
parsepairs %script that parses Parameter/value pairs.


if ~exist('destinations','var')
    zip(kmzFileName,sources)
    movefile([kmzFileName,'.zip'],kmzFileName)
%     system(['ren ',kmzFileName,'.zip ',kmzFileName])
else
    try
        tmpFolderName = 'tmp';
        k=1;
        while exist(tmpFolderName,'dir')==7
            tmpFolderName = ['tmp-',num2str(k)];
            k = k + 1;
        end
        clear k

        mkdir(tmpFolderName)
        
        for k=1:numel(sources)
            if isdir(sources{k})&~ismember(sources{k}(end),'\/')
                sources{k}=[sources{k},filesep];
                if ~ismember(destinations{k}(end),'\/')
                    destinations{k}=[destinations{k},filesep];
                end
            end

            sepIndex = sort([findstr(destinations{k},'\'),findstr(destinations{k},'/')]);
            for m=sepIndex
                makeDirStr = [tmpFolderName,filesep,destinations{k}(1:m)];
                if ~(exist(makeDirStr ,'dir')==7)
                    mkdir(makeDirStr)
                end
            end
            destinationsStr = [tmpFolderName,filesep,destinations{k}];
            
            copyfile(sources{k},destinationsStr)
                        
            n1 = numel([tmpFolderName,filesep]);
            n2 = numel(destinationsStr);
            fileList{k,1} = destinationsStr(n1+1:n2);
            
        end

        oldDirStr = pwd;
        eval(['cd ',tmpFolderName])
        
        zip(kmzFileName,fileList)
        movefile([kmzFileName,'.zip'],fullfile(oldDirStr,kmzFileName))

        eval(['cd ',oldDirStr])
        rmdir(tmpFolderName,'s')
        
    catch

        rmdir(tmpFolderName,'s')

    end
end