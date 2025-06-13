#include "mex.h"
#include "matrix.h"
#include "blas.h"

typedef float single;
typedef unsigned char byte;

#define max(a,b) ((a) >= (b) ? (a) : (b))
#define min(a,b) ((a) <  (b) ? (a) : (b))

/* How to compile this in Matlab:
- in Windows 64-bit:
mex -largeArrayDims -argcheck -O -outdir ./class/frontal/util/ ./class/frontal/util/frontal_mtimes_helper.c 'c:\Program Files\MATLAB\R2009b\extern\lib\win64\microsoft\libmwblas.lib'
- in Windows 32-bit:
mex -argcheck -O -outdir ./class/frontal/util/ ./class/frontal/util/frontal_mtimes_helper.c 'c:\Program Files (x86)\MATLAB\R2009b\extern\lib\win32\lcc\libmwblas.lib'
- in Unix 64-bit:
mex -largeArrayDims -argcheck -O -outdir ./class/frontal/util/ ./class/frontal/util/frontal_mtimes_helper.c -lmwblas
    And a little crash test:
a = rand(3,1)
b = rand(1,3)
a * b
frontal_mtimes_helper(a, b)
*/
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    const mxArray *A, *B;
          mxArray *C;
    const void *A_data, *a_data;
    const void *B_data, *b_data;
          void *C_data, *c_data;
    const mwSize *dimA, *dimB;
          mwSize dimC[3];
    mwSize mA, nA, pA, mB, nB, pB, mC, nC, pC, q;
    mwIndex sizeofel;
    mxClassID class_id;
    mwIndex kA, kB, kC;
    char transA = 'N', transB = 'N';
   
    if (nrhs < 2)
        mexErrMsgIdAndTxt ("frontal:mtimes:notEnoughInputs", \
            "Not enough input parameters.");
    if (nrhs > 2)
        mexErrMsgIdAndTxt ("frontal:mtimes:tooManyInputs", \
            "Too many input parameters.");
    if (nlhs > 1)
        mexErrMsgIdAndTxt ("frontal:mtimes:tooManyOutputs", \
            "Too many output parameters.");
    
    A = prhs[0];
    B = prhs[1];
    
    if ( mxIsComplex (A) || mxIsComplex (B) )
        mexErrMsgIdAndTxt ("frontal:mtimes:complex", \
            "Complex numbers are not supported.");
    if ( mxGetClassID(A) != mxGetClassID(B) )
        mexErrMsgIdAndTxt ("frontal:mtimes:diffClasses", \
            "Both operands should be of the same class.");
    if (   mxGetClassID(A) != mxDOUBLE_CLASS \
        && mxGetClassID(A) != mxSINGLE_CLASS )
        mexErrMsgIdAndTxt ("frontal:mtimes:nonFloat", \
            "Non-floating point numbers are not supported.");
    class_id = mxGetClassID (A);
    sizeofel = mxGetElementSize (A);
    /*{
    char temp[100];
    sprintf(temp, "%d\n", sizeofel);
    mexWarnMsgTxt(temp);
    }*/

    dimA = mxGetDimensions(A);
    mA = dimA[0];
    nA = dimA[1];
    pA = 1;
    if (mxGetNumberOfDimensions(A) == (mwSize) 3)  pA = dimA[2];

    dimB = mxGetDimensions(B);
    mB = dimB[0];
    nB = dimB[1];
    pB = 1;
    if (mxGetNumberOfDimensions(B) == (mwSize) 3)  pB = dimB[2];

    if (nA != mB)
        mexErrMsgIdAndTxt ("frontal:mtimes:innerdim", \
            "Inner dimensions must agree.");
    if (   mxGetNumberOfDimensions(A) > (mwSize) 3 \
        || mxGetNumberOfDimensions(B) > (mwSize) 3 )
        mexErrMsgIdAndTxt ("frontal:mtimes:inputsMustBe3D", \
            "Input arguments must be 3-D at most.");
    
    mC = mA;
    nC = nB; 
    pC = max(pA, pB);
    q = nA;  /* = mB; */
    /*{
    char temp[1000];
    sprintf(temp, "%d %d %d\n", mC, nC, pC);
    mexWarnMsgTxt(temp);
    }*/

    C = mxCreateNumericMatrix (0, 0, class_id, mxREAL);
    /* use mxCreateNumericMatrix instead to mxCreateNumericArray
       to avoid unnecessary data initialization to zero. */
    dimC[0] = mC;
    dimC[1] = nC;
    dimC[2] = pC;
    if (mxSetDimensions(C, dimC, (mwSize) 3) != 0)
        mexErrMsgIdAndTxt ("frontal:mtimes:badInit", \
            "Error setting dimensions of resulting matrix.");
            
    if ( mxIsEmpty(A) || mxIsEmpty(B) ) {
        /* mxIsEmpty is reliable; otherwise, checking mA, nA, pA, 
           you can obtain weird things such as size([3,1,0],3) == 1.
          
           C can still be non-empty, even if either A or B are empty, 
           e.g., zeros(2,0,3) * zeros(0,3,3) == zeros(2,3,3).
        */
        C_data = mxCalloc (mC * nC * pC, sizeofel);  /* need to zero it. */
        mxSetData (C, C_data);
        plhs[0] = C;
        return;
    }
    C_data = mxMalloc (mC * nC * pC * sizeofel);  /* need not to initialize it. */
    mxSetData (C, C_data);
    plhs[0] = C;
    /*return;  DEBUG */

    A_data = mxGetData (A);
    B_data = mxGetData (B);
    for (kC=0; kC<pC; kC++) {  /* for each frontal page. */
        /* support single frontal page in either A or B: */
        kA = min(pA-1, kC);
        kB = min(pB-1, kC);
        
        /* get pointers to each frontal page: */
        a_data = ((byte*) A_data) + kA * (mA * nA) * sizeofel;
        b_data = ((byte*) B_data) + kB * (mB * nB) * sizeofel;
        c_data = ((byte*) C_data) + kC * (mC * nC) * sizeofel;
        /*{
        char temp[100];
        sprintf(temp, "%d\n", ((int)c_data - (int)C_data)/sizeofel);
        mexWarnMsgTxt(temp);
        sprintf(temp, "%d\n", ((int)b_data - (int)B_data)/sizeofel);
        mexWarnMsgTxt(temp);
        sprintf(temp, "%d\n", ((int)a_data - (int)A_data)/sizeofel);
        mexWarnMsgTxt(temp);
        }*/

        if (class_id == mxSINGLE_CLASS) {
            single alpha = 1.0F;
            single beta  = 0.0F;
            sgemm (&transA, &transB, (mwSignedIndex*)&mC, (mwSignedIndex*)&nC, (mwSignedIndex*)&q, &alpha, \
               (single*)a_data, (mwSignedIndex*)&mA, (single*)b_data, (mwSignedIndex*)&mB, &beta, c_data, (mwSignedIndex*)&mC);
        }
        else if (class_id == mxDOUBLE_CLASS) {
            double alpha = 1.0F;
            double beta  = 0.0F;
            dgemm (&transA, &transB, (mwSignedIndex*)&mC, (mwSignedIndex*)&nC, (mwSignedIndex*)&q, &alpha, \
               (double*)a_data, (mwSignedIndex*)&mA, (double*)b_data, (mwSignedIndex*)&mB, &beta, c_data, (mwSignedIndex*)&mC);
        }
        /* "All integer variables passed into BLAS or LAPACK need to be of type mwSignedIndex." */

        /* as xgemm doesn't return any exit code, 
           so I conclude that it can never fail. */
    }
}

