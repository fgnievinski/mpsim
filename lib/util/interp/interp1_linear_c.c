#include <stdio.h>
#include <math.h>
#include <stddef.h>
#include "mex.h"


void my_interp1_linear (const size_t nX, const double *X, const double *Z, const size_t n, const double *x, double *z, const double out_value);


/* mexFunction is the gateway routine for the MEX-file. */ 
void
mexFunction (int nlhs, mxArray *plhs[], \
             int nrhs, const mxArray *prhs[])
{
    mxArray *matX, *matZ, *matx, *matz;
    double *X, *Z, *x, *z;
    size_t nX, n;

    /* Basic input check: */
    if (nlhs > 1) 
        mexErrMsgTxt ("Number of left-hand arguments should be 1.\n");
    if (nrhs != 3)  
        mexErrMsgTxt ("Number of right-hand arguments should be 3.\n");

    /* Retrieve function arguments: */
    /* z = interp_bilinear (X, Z, x) */
    matX = prhs[0];
    matZ = prhs[1];
    matx = prhs[2];
   
    if (!mxIsDouble(matZ))
    {
        mexErrMsgTxt("Input data matrix must be of double float type.\n");
    }
    
    X = mxGetPr (matX);
    Z = mxGetPr (matZ);
    x = mxGetPr (matx);
    
    nX = mxGetNumberOfElements (matX);
    n  = mxGetNumberOfElements (matx);
    
#ifdef NO_INPUT_CHECKING
    mexWarnMsgTxt ("Input checking skipped.\n");
#else
    /* Input check, detailed: */
    /*printf("checking input...\n");*/

    if ( mxGetM(matX) != 1 && mxGetN(matX) != 1 )
        mexErrMsgTxt ("X should be a vector.");
    if (mxGetN(matZ) != nX)  
        mexErrMsgTxt ("Z should have number of columns equal to the lenght of X.");

    if ( mxGetM(matx) != 1 && mxGetN(matx) != 1 )
        mexErrMsgTxt ("x should be a vector.");
#endif
    
    if ( mxGetM(matx) == 1 )
        matz = mxCreateDoubleMatrix (1, n, mxREAL);
    else
        matz = mxCreateDoubleMatrix (n, 1, mxREAL);
    z = mxGetPr (matz);
    
    my_interp1_linear (nX, X, Z, n, x, z, mxGetNaN());
    
    plhs[0] = matz;
    return;    
}


void 
my_interp1_linear (const size_t nX, \
                   const double *X, const double *Z, \
                   const size_t n, \
                   const double *x, double *z, \
                   const double out_value)
{
    /*size_t i, iXl, iXr; WRONG! size_t is unsigned! */ 
    signed int i, iXl, iXr;
    double Xl, Xr;
    double Zl, Zr;
    const double X_min = X[0];
    const double X_delta = X[1] - X[0];
    double zl, zu;
    
    for (i=0; i<n; i++)
    {
        /*mexPrintf("%f\t%f\n", X_delta);*/

        /*************************/
        /* get indices of nearest neighbors: */
        iXl = floor( (x[i] - X_min) / X_delta );  /* X left */
        iXr =  ceil( (x[i] - X_min) / X_delta );  /* X right */
        /*mexPrintf("hw! %d\t%d\t%f\t%f\t%d\t%d\n", iXl, iXr, (double)iXl, (double)iXr, ((double)iXl < 0.0));*/
        
        /************/
        /* points out of domain: */
        /*mexPrintf("iXl: %d, iXl < 0:%d, iXr: %d, iXr > (nX-1): %d\n", \
            iXl, (iXl < 0), iXr, (iXr > (nX-1)));*/
        if ( (iXl < (signed int)0) || (iXr > (nX-1)) )
        {
            /*mexPrintf("hw! %f\t%f\n", out_value, mxGetNaN());*/
            z[i] = out_value;
            continue;  /* skip this point. */
        }
        
        /************/
        /* interpolation points coincident with sample points: */
        if (iXl == iXr)
        {
           if (iXl == 0)  iXr++;
           else if (iXr == nX)  iXl--;
           else iXl--;
        }
        /*mexPrintf("iXl = %d\tiXr = %d\n", iXl, iXr);*/

        
        /*************************/
        /* get coordinates of nearest neighbors: */
        Xl = X[iXl];  /* left */
        Xr = X[iXr];  /* right */
        /*mexPrintf("Xl = %f\tXr = %f\n", Xl, Xr);*/
        
        
        /*************************/
        /* get data value at nearest neighbors: */
        Zl = Z[iXl];  /* left */
        Zr = Z[iXr];  /* right */
        /*mexPrintf("Zl = %f\tZr = %f\n", Zl, Zr);*/

        
        /*************************/
        /* do linear interpolation:  */
        z[i] = ( (x[i] - Xl) * Zr - (x[i] - Xr) * Zl ) / X_delta;
    }

    return;
}

