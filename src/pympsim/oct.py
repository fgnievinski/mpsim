from pympsim import mpoct
from functools import partial

def __getattr__(octfunc):
    """
    Return a partially bound octave function reference
    """
    return partial(mpoct.mpsimwrap, octfunc)


