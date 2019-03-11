A GPS/GNSS MULTIPATH SIMULATOR IN MATLAB/OCTAVE

Nievinski, F.G. and Larson, K.M. (2014)
   "Forward modeling of GPS multipath for near-
   surface reflectometry and positioning 
   applications", GPS Solut., 18(2):309-322.
   <http://doi.org/10.1007/s10291-013-0331-y>

Nievinski, F.G. and Larson, K.M. (2014)
   "An open source GPS multipath simulator 
   in Matlab/Octave", GPS Solut., 18(3):473-481.
   <http://doi.org/10.1007/s10291-014-0370-z>


1) Installation

    1.A) In Matlab, drag the file "init.m" 
    and drop it into its main command window;
    this will initialize the search path.

    1.B) Alternatively, if running Octave (where 
    drag/drop may not be available), enter:

        run('~/mpsim/init.m')

    modifying the ~ path to reflect your install.
    Furthermore, for greater Matlab compatibility, 
    it is recommended to start Octave with the 
    option "--traditional".

    1.C) In Octave, you might want to try different
    graphics toolkits availabe -- it's a tradeoff 
    between quality and reliability:
       graphics_toolkit('gnuplot')
       graphics_toolkit('qt')


2) The simplest simulation run can be achieved 
entering the following command:

    snr_fwd


3) Usage examples: available in sub-directory 
"script", which contains driver scripts named 
after each figure in the articles above.

3.1) The original figure images are saved in 
sub-directory "image"; please compare to 
those generated as you run the script examples.


4) A tutorial is available in file "snr_demo.html", 
which can be viewed with any Web browser.


5) Documentation for the input/output syntax of 
the main functions can be accessed from within 
Matlab/Octave, by entering any of the following
commands:

    help snr_fwd
    help snr_setup
    help snr_settings
    help get_permittivity

