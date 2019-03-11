#include <stdio.h>
#include <math.h>
#include <stddef.h>
#include "mex.h"


void my_interp2_linear (const size_t nX, const size_t nY, const double *X, const double *Y, const double *Z, const size_t n, const double *x, const double *y, double *z, const double out_value);


/* mexFunction is the gateway routine for the MEX-file. */ 
void
mexFunction (int nlhs, mxArray *plhs[], \
             int nrhs, const mxArray *prhs[])
{
    mxArray *matX, *matY, *matZ, *matx, *maty, *matz;
    double *X, *Y, *Z, *x, *y, *z;
    size_t nX, nY, n;

    /* Basic input check: */
    if (nlhs > 1) 
        mexErrMsgTxt ("Number of left-hand arguments should be 1.\n");
    if (nrhs != 5)  
        mexErrMsgTxt ("Number of right-hand arguments should be 5.\n");

    /* Retrieve function arguments: */
    /* z = interp_bilinear (X, Y, Z, x, y) */
    matX = prhs[0];
    matY = prhs[1];
    matZ = prhs[2];
    matx = prhs[3];
    maty = prhs[4];
   
    if (!mxIsDouble(matX) \
    ||  !mxIsDouble(matY) \
    ||  !mxIsDouble(matZ) \
    ||  !mxIsDouble(matx) \
    ||  !mxIsDouble(maty) \
    )
    {
        mexErrMsgTxt("Input data matrix must be of double float type.\n");
    }
    
    X = mxGetPr (matX);
    Y = mxGetPr (matY);
    Z = mxGetPr (matZ);
    x = mxGetPr (matx);
    y = mxGetPr (maty);
    
    nX = mxGetNumberOfElements (matX);
    nY = mxGetNumberOfElements (matY);
    n = mxGetNumberOfElements (matx);
    
#ifdef NO_INPUT_CHECKING
    mexWarnMsgTxt ("Input checking skipped.\n");
#else
    /* Input check, detailed: */
    /*printf("checking input...\n");*/

    if ( mxGetM(matX) != 1 && mxGetN(matX) != 1 )
        mexErrMsgTxt ("X should be a vector.");
    if ( mxGetM(matY) != 1 && mxGetN(matY) != 1 )
        mexErrMsgTxt ("Y should be a vector.");
    if (mxGetN(matZ) != nX)  
        mexErrMsgTxt ("Z should have number of columns equal to the lenght of X.");
    if (mxGetM(matZ) != nY)
        mexErrMsgTxt ("Z should have number of rows equal to the lenght of Y.");

    if (n != mxGetNumberOfElements (maty))
        mexErrMsgTxt ("x and y should have the same number of elements.");
    if ( mxGetM(matx) != 1 && mxGetN(matx) != 1 )
        mexErrMsgTxt ("x should be a vector.");
    if ( mxGetM(maty) != 1 && mxGetN(maty) != 1 )
        mexErrMsgTxt ("y should be a vector.");
#endif
    
    if ( mxGetM(matx) == 1 )
        matz = mxCreateDoubleMatrix (1, n, mxREAL);
    else
        matz = mxCreateDoubleMatrix (n, 1, mxREAL);
    z = mxGetPr (matz);
    
    my_interp2_linear (nX, nY, X, Y, Z, n, x, y, z, mxGetNaN());
    
    plhs[0] = matz;
    return;    
}


void 
my_interp2_linear (const size_t nX, const size_t nY, \
                   const double *X, const double *Y, const double *Z, \
                   const size_t n, \
                   const double *x, const double *y, double *z, \
                   const double out_value)
{
    size_t i, iXl, iXr, iYl, iYu;
    double Xl, Xr, Yl, Yu;
    double Zll, Zlr, Zul, Zur;
    const double X_min = X[0], Y_min = Y[0];
    const double X_delta = X[1] - X[0], Y_delta = Y[1] - Y[0];
    double zl, zu;
    
    for (i=0; i<n; i++)
    {
        /*mexPrintf("%f\t%f\n", X_delta, Y_delta);*/

        /*************************/
        /* get indices of nearest neighbors: */
        iXl = floor( (x[i] - X_min) / X_delta );  /* X left */
        iXr =  ceil( (x[i] - X_min) / X_delta );  /* X right */
        iYl = floor( (y[i] - Y_min) / Y_delta );  /* Y lower */
        iYu =  ceil( (y[i] - Y_min) / Y_delta );  /* Y upper */
        
        /************/
        /* points out of domain: */
        /*mexPrintf("iXl: %d, iXl < 0:%d, iXr: %d, iXr > (nX-1): %d\n", \
            iXl, (iXl < 0), iXr, (iXr > (nX-1)));*/
        if (   iXl < 0 || iXr > (nX-1) \
            || iYl < 0 || iYu > (nY-1) )
        {
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
        if (iYl == iYu)
        {
           if (iYl == 0)  iYu++;
           else if (iYu == nY)  iYl--;
           else iYl--;
        }
        /*mexPrintf("iYl = %d\tiYu = %d\n", iYl, iYu);*/

        
        /*************************/
        /* get coordinates of nearest neighbors: */
        Xl = X[iXl];  /* left */
        Xr = X[iXr];  /* right */
        /*mexPrintf("Xl = %f\tXr = %f\n", Xl, Xr);*/
        
        Yl = Y[iYl];  /* lower */
        Yu = Y[iYu];  /* upper */
        /*mexPrintf("Yl = %f\tYu = %f\n", Yl, Yu);*/
        
        
        /*************************/
        /* get data value at nearest neighbors: */
        /* (x (y) corresponds to columns (lines)): */
        Zll = Z[iYl + iXl * nY];  /* lower left */
        Zlr = Z[iYl + iXr * nY];  /* lower right */
        Zul = Z[iYu + iXl * nY];  /* upper left */
        Zur = Z[iYu + iXr * nY];  /* upper right */
        /*mexPrintf("Zll = %f\tZlr = %f\n", Zll, Zlr);*/
        /*mexPrintf("Zul = %f\tZur = %f\n", Zul, Zur);*/

        
        /*************************/
        /* do bi-linear interpolation:  */
        /* z lower: */
        zl =   ( (x[i] - Xl) * Zlr - (x[i] - Xr) * Zll ) / X_delta;
        /* z upper: */
        zu =   ( (x[i] - Xl) * Zur - (x[i] - Xr) * Zul ) / X_delta;
        /*mexPrintf("zl = %f\tzu = %f", zl, zu);*/
        /* z: */
        z[i] = ( (y[i] - Yl) * zu  - (y[i] - Yu) * zl  ) / Y_delta;
    }

    return;
}

