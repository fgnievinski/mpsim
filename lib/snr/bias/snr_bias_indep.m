function [indep, graz, elev] = snr_bias_indep (bias, sat, geom)
    if (nargin < 3),  geom = [];  end
    if ~isempty(geom)
        graz = geom.reflection.sat_dir.sfc.elev;
        elev = geom.direct.dir.local_ant.elev;
    else
        graz = [];
        elev = sat.elev;
    end
    if ~isfieldempty(bias, 'indep'),  indep = bias.indep;  return;  end
    indep = bias.indep_fnc(elev, graz);
end
