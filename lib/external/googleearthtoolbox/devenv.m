function devEnvStr = devenv
% returns the development environment, i.e. 'matlab' or 'octave'.

try
    vM = ver('MATLAB');
    devEnvStr = lower(vM.Name);
    return
end

try
    if strcmp(license,'GNU General Public License')
        devEnvStr = 'octave';
    end
    return
end

error('Unable to identify the development environment.')

        