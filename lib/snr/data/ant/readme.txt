The "profile" subdirectory is the only one input by the user.  The "densemap" and "sphharm" subdirectories are produced by the routine snr_setup_ant_gain_preload.m

If the antenna code includes the forward slash character ("/"), that character is replaced for "_" in the filename -- only; the antenna model code input to the simulator remains unaltered, as it affects the antenna phase-center vector offsets.

The profile data has two formats: basic and extended (respectively,
with file extensions .dat and .datx).

The profile basic format is made of two columns: boresight angle and pseudo-gain.
The boresight angle is zero at zenith and 180-deg at nadir assuming the antenna is upright.
It is assumed that only one principal plane cut is given.
The azimuthal angle is assumed zero (normally antennas are aligned to north).
If the boresight angle is negative, it wraps around zenith and continues at the opposite azimuth;
if the boresight angle exceeds 180-deg, it wraps around nadir and continues at the opposite azimuth.
Examples:
    boresight =   -5 deg (and azim = 0 deg) is interpreted as boresight =   5 deg and azim = 180 deg; 
    boresight = -179 deg (and azim = 0 deg) is interpreted as boresight = 179 deg and azim = 180 deg;
    boresight = +181 deg (and azim = 0 deg) is interpreted as boresight = 179 deg and azim = 180 deg.

The extended profile format is made of three columns: boresight angle, azimuthal angle, and pseudo-gain.

In any case, the first line contains a scalar delta gain DG such that G = G' - DG, where G' is the pseudo-gain and G is the true gain G (typically 5 dBi at boresight for RHCP).  As an example of this relationship, for antenna TRM29659.00, G' and G at boresight for L2 RHCP are -11.26 dB and +3.74 dB, respectively.  Most commonly, the delta is the same across different polarizations (RHCP, LHCP) and different carrier frequencies (L1, L2, L5) for the same antenna model, because employ a fixed IF attenuator and RF amplifier.  If the gain delta is unknown, it is recommended that the profile data file be exported adjusting pseudo-gain values by a multiple of 5 dB such that boresight gain is approximately equal to 5.0 dB, and then enter NaN in the first file line.  Doing so will allow the simulator to warn the user not to trust absolute SNR values, while keeping SNR comparable across different polarizations and carrier frequencies (but not across different antenna models).

Normally only the antenna gain pattern is provided; 
optionally, the antenna phase pattern can be given as above, 
except that the file name suffix "gain" is 
replaced for "phase".

