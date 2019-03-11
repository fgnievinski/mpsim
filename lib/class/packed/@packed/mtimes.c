#include "mex.h"
#include "matrix.h"
#include "string.h"  /* memcpy */
#include "private/mx2.h"

typedef float single;
void check_input (const mxArray *A, const mxArray *B);
mxArray *create_packed (mxArray *A, char type, char uplow);

/* How to compile this in Matlab (assuming you're using the Lcc compiler):
cd 'c:\work\m\'
mex -argcheck -g -O -outdir ./class/packed/@packed/ ./class/packed/@packed/mtimes.c './class/packed/@packed/private/mx2.c' 'c:\Program Files\MATLAB\R2007b\extern\lib\win32\lcc\libmwlapack.lib' 'c:\Program Files\MATLAB\R2007b\extern\lib\win32\lcc\libmwblas.lib'
 */

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    mxArray *A, *B, *C, *X;
    int A_m, A_n, B_m, B_n;
    mxClassID class_id;
    size_t sizeofel;
    char diag = 'N';
    char trans;
    char type, uplow;
    void *A_data, *B_data, *C_data, *temp_data;
    int j;
    
    /**********/    
    if (nrhs < 2)
        mexErrMsgIdAndTxt ("packed:mtimes:notEnoughInputs", \
            "Not enough input parameters.");
    if (nrhs > 2)
        mexErrMsgIdAndTxt ("packed:mtimes:tooManyInputs", \
            "Too many input parameters.");
    if (nlhs > 1)
        mexErrMsgIdAndTxt ("packed:mtimes:tooManyOutputs", \
            "Too many output parameters.");
    
    A = prhs[0];
    B = prhs[1];
    
    /**********/
    if (mx2IsEmpty(A) || mx2IsEmpty(B)) {
        plhs[0] = mxCreateNumericMatrix (0, 0, mxDOUBLE_CLASS, mxREAL);
        return;
    }
    else if (mx2IsScalar(A) || mx2IsScalar(B)) {
        int temp2;
        /*mxArray *temp1[] = {A, B};*/
        mxArray *temp1[2];
        temp1[0] = A;
        temp1[1] = B;
        temp2 = mexCallMATLAB (1, plhs, 2, temp1, "times");
        if (temp2 != 0)
           mexErrMsgIdAndTxt ("packed:mtimes:badCall", \
               "Error calling times.");
        return;
    }
    check_input (A, B);
    
    /**********/    
    /* BLAS makes available only packed pre-multiplication, i.e., 
     * A * B, where A must be packed.
     * If A is not packed and B is packed, we do (B' * A')'. */
    if (mx2IsPacked(A))
        trans = 'N';
    else {
        trans = 'T';
        {
        mxArray *temp1;
        int temp2;
        temp2 = mexCallMATLAB (1, &temp1, 1, &A, "transpose");
        if (temp2 != 0)
           mexErrMsgIdAndTxt ("packed:mtimes:badCall", \
               "Error calling transpose.");
        A = temp1;
        }
        {
        mxArray *temp;
        temp = A;  A = B;  B = temp;
        }
    }
    mxAssert (mx2IsPacked(A), "");

    class_id = mx2GetClassID (A);
    sizeofel = mx2GetElementSize (A);
    A_m    = mx2GetN (A);
    A_n    = mx2GetN (A);
    B_m    = mx2GetM (B);
    B_n    = mx2GetN (B);
    mxAssert (A_m == A_n, "");
    mxAssert (A_n == B_m, "");
        
    /**********/    
    if (mx2IsSparse(B) || mx2IsPacked(B)) {
        int temp2;
        temp2 = mexCallMATLAB (1, &C, 1, &B, "full");
        if (temp2 != 0)
           mexErrMsgIdAndTxt ("packed:mtimes:badCall", \
               "Error calling full.");
        C_data = mx2GetData (C);
        B_data = C_data;
        /* We need B in full. Please note that making B full 
         * is not a waste of memory -- it is exactly the 
         * amount of memory needed to hold C, and we are 
         * going to overwrite B full with C. */
    }
    else {
        B_data = mx2GetData (B);
        C_data = mxMalloc (A_m * B_n * sizeofel);
        C = mxCreateNumericMatrix (0, 0, class_id, mxREAL);
        mxSetM (C, A_m);
        mxSetN (C, B_n);
        mxSetData (C, C_data);
    }
    A_data = mx2GetData (A);
    temp_data = mxMalloc (B_m * sizeofel);
    
    /**********/    
    type  = mx2GetPackedType  (A);
    uplow = mx2GetPackedUplow (A);
    for (j=0; j<B_n; j++) {  /* for each column of B */
        void *B_col, *C_col, *temp_col;
        int one_int = 1;
        /*int temp[] = {0, j};*/
        int temp[2];
        temp[0] = 0;
        temp[1] = j;

        B_col = (void *) (((char *)B_data) + (j*B_m)*sizeofel);
        C_col = (void *) (((char *)C_data) + (j*B_m)*sizeofel);
            
        if (type == 't') {
            /* xTPMV's vector input  is in C_col 
             * xTPMV's vector output is in C_col, too. */
            if (C_col != B_col)  memcpy (C_col, B_col, B_m * sizeofel);
            if (class_id == mxSINGLE_CLASS) {
                single zero = 0.0F;
                single one  = 1.0F;
                stpmv (&uplow, &trans, &diag, &A_n,              A_data, \
                    C_col, &one_int);
            }
            else if (class_id == mxDOUBLE_CLASS) {
                double zero = 0.0;
                double one  = 1.0;
                dtpmv (&uplow, &trans, &diag, &A_n,              A_data, \
                    C_col, &one_int);
            }
        }
        else if (type == 's') {
            /* xSPMV's vector input is in B_col *
             * xSPMV's vector output is in temp_col */
            if (C_col == B_col)  temp_col = temp_data;  else  temp_col = C_col;
            if (class_id == mxSINGLE_CLASS) {
                single zero = 0.0F;
                single one  = 1.0F;
                sspmv (&uplow,                       &A_n, &one, A_data, \
                    B_col, &one_int, &zero, temp_col, &one_int);
            }
            else if (class_id == mxDOUBLE_CLASS) {
                double zero = 0.0;
                double one  = 1.0;
                dspmv (&uplow,                       &A_n, &one, A_data, \
                    B_col, &one_int, &zero, temp_col, &one_int);
            }
            if (C_col == B_col)  memcpy (C_col, temp_col, B_m * sizeofel);
        }
        else {
            mexErrMsgIdAndTxt ("packed:mtimes:unknownMatrixType", \
                "Unknown matrix type.");
        }
    }
    mxFree(temp_data);

    /**********/
    if (mx2IsPacked(A) && mx2IsPacked(B)) {
        char A_type  = mx2GetPackedType  (A);
        char A_uplow = mx2GetPackedUplow (A);
        char B_type  = mx2GetPackedType  (B);
        char B_uplow = mx2GetPackedUplow (B);
        if (   (A_type == 't' && B_type == 't' && A_uplow == B_uplow)
            || (A_type == 's' && B_type == 's') )
            C = create_packed (C, A_type, A_uplow);
    }        
    if (trans == 'T') {
        mxArray *temp1;
        int temp2;
        temp2 = mexCallMATLAB (1, &temp1, 1, &C, "transpose");
        if (temp2 != 0)
           mexErrMsgIdAndTxt ("packed:mtimes:badCall", \
               "Error calling transpose.");
        C = temp1;
    }        
    plhs[0] = C;
}


void check_input (const mxArray *A, const mxArray *B)
{
    if ( !mx2IsPacked(A) && !mx2IsPacked(B) )
        mexErrMsgIdAndTxt ("packed:mtimes:noPackedInput", \
            "At least one of the inputs must be packed.");

    if (   mx2GetNumberOfDimensions(A) > 2 \
        || mx2GetNumberOfDimensions(B) > 2 )
        mexErrMsgIdAndTxt ("packed:mtimes:inputsMustBe2D", \
            "Input arguments must be 2-D.");

    if ( mx2GetN(A) != mx2GetM(B) )
        mexErrMsgIdAndTxt ("packed:mtimes:innerdim", \
            "Inner dimensions must agree.");

    if ( mx2GetClassID(A) != mx2GetClassID(B) )
        mexErrMsgIdAndTxt ("packed:mtimes:diffClasses", \
            "Both operands should be of the same class.");

    if (   mx2GetClassID(A) != mxDOUBLE_CLASS \
        && mx2GetClassID(A) != mxSINGLE_CLASS )
        mexErrMsgIdAndTxt ("packed:mtimes:nonFloatNotSupported", \
            "Non-floating point numbers are not supported.");

    if ( mx2IsComplex (A) || mx2IsComplex (B) )
        mexErrMsgIdAndTxt ("packed:mtimes:complexNotSupported", \
            "Complex numbers are not supported.");
}

mxArray *create_packed (mxArray *A, char type, char uplow)
{
    char *type2, *uplow2;
    mxArray *temp1;
    int temp2;
    mxArray *temp3[3];
    
    /* convert from char to null-terminated string 
     * and make type longer (min 3 char) */
    if (type  == 't') type2  = "tri";  else type2  = "sym";
    if (uplow == 'u') uplow2 = "u";    else uplow2 = "l";
    
    temp3[0] = A;
    temp3[1] = mxCreateString(type2);
    temp3[2] = mxCreateString(uplow2);
    temp2 = mexCallMATLAB (1, &temp1, 3, temp3, "packed");
    if (temp2 != 0)
       mexErrMsgIdAndTxt ("packed:mtimes:badCall", \
           "Error calling packed.");
    return temp1;
}
