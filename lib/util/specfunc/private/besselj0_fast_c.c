#include "mex.h"
#include "matrix.h"

typedef float single;
typedef unsigned char byte;

double besselj0 (const double x);

/* How to compile this in Matlab:
mex -largeArrayDims -argcheck -O -outdir ./util/private/ ./util/private/besselj0_fast_c.c ./util/private/besselj0.c
*/
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    const mxArray *in;
          mxArray *out;
    const double *in_data;
          double *out_data;
    mwSize ndim, numel;
    const mwSize *dims;
    mwIndex i;
   
    if (nrhs < 1)
        mexErrMsgIdAndTxt ("MATLAB:jbessel0_fast:notEnoughInputs", \
            "Not enough input parameters.");
    if (nrhs > 2)
        mexErrMsgIdAndTxt ("MATLAB:jbessel0_fast:tooManyInputs", \
            "Too many input parameters.");
    if (nlhs > 1)
        mexErrMsgIdAndTxt ("MATLAB:jbessel0_fast:tooManyOutputs", \
            "Too many output parameters.");
    
    in = prhs[0];
    
    if (mxIsComplex (in))
        mexErrMsgIdAndTxt ("MATLAB:jbessel0_fast:complex", \
            "Complex numbers are not supported.");
    if (mxGetClassID(in) != mxDOUBLE_CLASS)
        mexErrMsgIdAndTxt ("MATLAB:jbessel0_fast:nonDouble", \
            "Non-double floating point numbers are not supported.");

    numel = mxGetNumberOfElements(in);
    ndim = mxGetNumberOfDimensions(in);
    dims = mxGetDimensions(in);

    out = mxCreateNumericArray (ndim, dims, mxDOUBLE_CLASS, mxREAL);

     in_data = mxGetData (in);
    out_data = mxGetData (out);

    for (i=0; i<numel; i++) {
        out_data[i] = besselj0 (in_data[i]);
    }

    plhs[0] = out;
}

