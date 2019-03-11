function [dir_ant, optimizeit] = snr_fwd_direction_local2ant (dir_local, setup)
    ant = setup.ant;
    if ~isfield(ant, 'optimizeit'),  ant.optimizeit = [];  end
    [dir_ant, optimizeit] = snr_fwd_direction_local2 (...
        length(dir_local.elev), dir_local, ...
        ant.rot, ant.dir_nrml, ant.aspect, ant.slope, ant.axial, ant.optimizeit);
end

