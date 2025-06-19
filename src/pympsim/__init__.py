import sys
import os
from .logging import log

def _mpoct():
    # return a new  (or existing) octave session
    #start a new octave session
    #import lazily only when needed as the import starts a new session
    log.info("Starting Octave session, and setting paths...")
    from oct2py import Oct2Py
    mpoct_ = Oct2Py(logger=log)

    # Add the mpsimlib directory to the system path

    current_dir = os.path.dirname(os.path.abspath(__file__)).replace('src', 'mpsimlib')
     
    # # Add the parent directory to the system path
    mpsimdir = os.path.join(os.path.dirname(current_dir), 'mpsim')
    # #add the mpsim matlab code  directory to octave
    mpoct_.addpath(mpoct_.genpath(mpsimdir))
    return mpoct_

#start the Octave session and sets the appropriate paths
mpoct=_mpoct()
