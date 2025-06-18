# Roelof Rietbroek (r.rietbroek@utwente.nl), 2025
#



from setuptools import setup, Extension
from setuptools.command.build_ext import build_ext
from glob import glob
import subprocess
import pathlib
import os

class MexExtension(Extension):
    def __init__(self, name):
        # don't invoke the original build_ext for this special extension
        super().__init__(name, sources=[])


#Helper to build in place mex files
class BuildMex(build_ext):
    def run(self):
        # Compile the MEX files
        for ext in self.extensions:
            if isinstance(ext, MexExtension):
                self.mexcompile(ext)
            else:
                raise ValueError("Only MexExtension is supported")

    def mexcompile(self, ext):
        mexout=pathlib.Path(self.build_lib)/ext.name.replace('.c', '.mex').replace("mpsimlib/", "")
        
        if not os.path.exists(mexout.parent):
            #this is an inplace build
            mexout=ext.name.replace('.c', '.mex')
        # Compile the MEX files
        try:
            subprocess.run(["mkoctfile", "--mex",'-o',mexout,ext.name])
        except Exception as e:
            raise RuntimeError(f"Error compiling {ext.name}: is octave installed?")

def listmex():
    exts=[]
    cfiles=glob('mpsimlib/mpsim/util/**/*.c',recursive=True)
    #note currently not compiling the mex functions in classes (need blas include paths)
    for cfile in cfiles:
        exts.append(MexExtension(cfile))
    return exts

setup(ext_modules=listmex(),
      cmdclass={'build_ext':BuildMex})


