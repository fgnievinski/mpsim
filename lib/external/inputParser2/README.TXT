This is a wrapper for Octave's and Matlab's inputParser routines,
so that m-code can be ran unmodified in both environments.  Code
originally written for Matlab need only append a "2" suffix to the
initial call to inputParser, i.e., p = inputParser2 (); it is also 
recommended to add a call to dispose(p) just before the end of the 
function using inputParser2(), to free up its memory resources.
Code originally written for Octave which wishes cross-compatiblity
with Matlab would need to be modified, adopting earlier the syntax
that will only become available in Octave after classdef is fully
implemented.  The input/output syntax of this wrapper is intended 
to adhere to Matlab's syntax and remain stable despite future 
changes in the Octave implementation that is called internally.
