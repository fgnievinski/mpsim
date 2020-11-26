function out = permittivity_soil_setup (filename_real, filename_imag, data_dir)
% See also: permittivity_soil_plot
  if (nargin < 1),  filename_real = 'soil_re.dat';  end
  if (nargin < 2),  filename_imag = 'soil_im.dat';  end
  if (nargin < 3)
    data_dir = fullfile(dirup(fileparts(which(mfilename()))), 'data', 'soil');
  end
  persistent perm
  if isempty(perm)
    perm = permittivity_soil_setup_aux (...
      fullfile(data_dir, filename_real), ...
      fullfile(data_dir, filename_imag)  ...
    );
  end
  out = perm;
  % for references, see data_dir/readme.txt
end
  
function perm = permittivity_soil_setup_aux (filename_real, filename_imag)
  type = cell(5,1);
  type{1} = 'sandy loam';
  type{2} = 'loam';
  type{3} = 'silt loam 1';
  type{4} = 'silt loam 2';
  type{5} = 'silty clay';
  % There is a duplicated entry (3 & 4):
  % The paper (doi:10.1109/JSTARS.2009.2033608) mentions that "plots were
  % presented of VWC versus for five different types [of] soil: sandy loam, loam, silt loam 1, silt loam 2, and silty clay." 
  num_soils = numel(type);
  
  perm_type = {'real', 'imag'};
  filename = {filename_real, filename_imag};
  perm = struct();
  for j=1:2
    temp = load(filename{j});
    ind = find(temp(:,1) == 0.0);
      assert(numel(ind) == num_soils)
    ind(end+1) = size(temp,1) + 1; %#ok<AGROW>
    perm.(perm_type{j}) = struct('value',[], 'moisture',[], 'type',[]);
    perm.(perm_type{j}) = repmat(perm.(perm_type{j}), [num_soils,1]);
    for i=1:num_soils
      indi = ind(i):(ind(i+1)-1);
      perm.(perm_type{j})(i).value = temp(indi,2);
      perm.(perm_type{j})(i).moisture = temp(indi,1);
      perm.(perm_type{j})(i).type = type{i};
    end
  end
end

