function cs = textscanline (filepath, algo, algo2)
%TEXTSCANLINE:  Read a text file, breaking end of lines.
    if (nargin < 2) || isempty(algo),  algo = 'default';  end
    if (nargin < 3),  algo2 = [];  end
    if any(strcmp(algo, {'default','textscan','faster'}))
        %cs = loadscan(filepath, '%s', [], [], '', '', '');
        fid = fopen_error(filepath);
        cs = textscan(fid, '%s', 'Delimiter','', 'WhiteSpace','');
        cs = cs{1};
        fclose(fid);    
        return
    end
    fid = fopen_error(filepath);
    [~,lt] = fgets(fid);  lt = char(lt);  fseek(fid, 0, -1);
    text = fread(fid, Inf, '*char');
    fclose(fid);
    cs = cellstrline(text, lt, algo2);
end
