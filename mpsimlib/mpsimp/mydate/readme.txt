Augments MATLAB's date/time library for improved handling of epochs and formats commonly used in GPS.
The base date or reference epoch is brought closer to contemporary dates for improved precision (from MATLAB's year 0 to epoch 2000.0); the base unit is also changed (from multiples of days to seconds).
Epoch values are retained as a serial scalar real number so that manipulation is easier compared to handling epoch parts separately (e.g., using intersect() to find common epochs).
File naming follows MATLAB's own as close as possible with an obvious prefix. MATLAB's own functions are used internally whenever possible.
Vector (non-scalar) input is supported.

Unzip the file into, e.g., 'c:\work\fx\mydate\'; make sure the directory structure is preserved. Then type
    addpath(genpath('c:\work\fx\mydate'))
(not to be confused with addpath(genpath('c:\work\fx\mydate\mydate')))    
Please run test_mydate to check your installation.
The first function to try is mydatenum().

Julian day conversions follow from Peter Baum's excellent "Date algorithms", available at <http://mysite.verizon.net/aesir_research/date/date0.htm>.
