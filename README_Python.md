# Python-Octave wrapper for calling MPSIM from Python
This Python module uses [oct2py](https://github.com/blink1073/oct2py) to call the Matlab/Octave code from this repository

## Installation

1. Recommended: Create a  (conda or Python virtual environment) 
2. Receommended: Activate the environment (e.g. `conda activate mpsim`)
3. Make sure you have `Octave` installed (see .e.g. [Octave installation instructions](https://www.gnu.org/software/octave/download.html) or [Octave on Anaconda](https://anaconda.org/conda-forge/octave))
4. Install the pympsim wrapper by running from the repository's root directory:

    ```
   pip install .
    ```

The installation will compile necessary mex files, and copies the matlab code to the `mpsim` directory in the virtual environment



## Usage

Syntax is similar to the Matlab/Octave code, but with Python syntax. For example:

```
from pympsim.oct import snr_settings,snr_setup,snr_fwd
settings=snr_settings()

# possibly manipulate some settings
...


snrstup=snr_setup(settings)


fwdres=snr_fwd(snrstup)


...
```






