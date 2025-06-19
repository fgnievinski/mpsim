#include "mex.h"
#include "matrix.h"
#include "string.h"

typedef float single;
single slansp ();
single dlansp ();
single slantp ();
single dlantp ();
void check_input (mxArray *array);
mxClassID get_int_mxclassid (void);

/* How to compile this in Matlab (assuming you're using the Lcc compiler):
cd 'c:\work\m\'
mex -argcheck -g -O -outdir ./class/packed/@packed/private/ -output call_lapack.dll ./class/packed/@packed/private/call_lapack.c 'c:\Program Files\MATLAB\R2006a\extern\lib\win32\lcc\libmwlapack.lib'
 */
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    char *matrix_type, *op_name;
    matrix_type = mxArrayToString (prhs[0]);
    op_name   = mxArrayToString (prhs[1]);
    
    if (!strcmp (op_name, "trf")) {
        char uplow;
        int n;
        mxArray *array;
        size_t temp;
        void *data;
        mxClassID class_id;
        int info;
        mxArray *array2;
        int *ipiv;
        
        uplow = (char) mxGetScalar (prhs[2]);
        n     = (int)  mxGetScalar (prhs[3]);
        array = prhs[4];
        
        check_input(array);
        
        temp = mxGetNumberOfElements (array) * mxGetElementSize (array);
        data = mxMalloc (temp);
        memcpy (data, mxGetData (array), temp);
        if (!strcmp(matrix_type, "sp"))
            ipiv = mxMalloc (n * sizeof(int));

        class_id = mxGetClassID (array);
        if      ( (class_id == mxSINGLE_CLASS) && !strcmp(matrix_type, "sp") )
            ssptrf (&uplow, &n, data, ipiv, &info);
        else if ( (class_id == mxDOUBLE_CLASS) && !strcmp(matrix_type, "sp") )
            dsptrf (&uplow, &n, data, ipiv, &info);
        else if ( (class_id == mxSINGLE_CLASS) && !strcmp(matrix_type, "pp") )
            spptrf (&uplow, &n, data,       &info);
        else if ( (class_id == mxDOUBLE_CLASS) && !strcmp(matrix_type, "pp") )
            dpptrf (&uplow, &n, data,       &info);
        else 
            mexErrMsgIdAndTxt ("packed:call_lapack:unknownMatrixType", \
                "Unknown matrix type.");

        if (info < 0) {
            char msg[100];
            sprintf (msg, \
                "Error calling LAPACK routine, internal input parameter #%d.", \
                -info);
            mexErrMsgIdAndTxt ("packed:call_lapack:badInput", msg);
        }
        
        array2 = mxCreateNumericMatrix (0, 0, class_id, mxREAL);
        mxSetData (array2, data);
        mxSetM (array2, mxGetM (array));
        mxSetN (array2, mxGetN (array));
        
        plhs[0] = mxCreateDoubleScalar (info);
        plhs[1] = array2;

        if (!strcmp(matrix_type, "sp")) {
            mxArray *array3;
            mxClassID int_class_id;

            int_class_id = get_int_mxclassid ();
            array3 = mxCreateNumericMatrix (0, 0, int_class_id, mxREAL);
            mxSetData (array3, ipiv);
            mxSetM (array3, n);
            mxSetN (array3, 1);
            
            plhs[2] = array3;
        }
    }
    else if (!strcmp (op_name, "tri")) {
        char uplow;
        int n;
        mxArray *array;
        size_t temp;
        void *data;
        mxClassID class_id;
        int info;
        mxArray *array2;
        int *ipiv;
        void *work;
        char is_unit_tri = 'N';
        
        uplow = (char) mxGetScalar (prhs[2]);
        n     = (int)  mxGetScalar (prhs[3]);
        array = prhs[4];
 
        check_input(array);
        
        temp = mxGetNumberOfElements (array) * mxGetElementSize (array);
        data = mxMalloc (temp);
        memcpy (data, mxGetData (array), temp);
        if (!strcmp(matrix_type, "sp")) {
            ipiv  = (int *) mxGetData (prhs[5]);
            work = mxMalloc (n * sizeof(double));
        }

        class_id = mxGetClassID (array);
        if      ( (class_id == mxSINGLE_CLASS) && !strcmp(matrix_type, "sp") )
            ssptri (&uplow, &n, data, ipiv, work, &info);
        else if ( (class_id == mxDOUBLE_CLASS) && !strcmp(matrix_type, "sp") )
            dsptri (&uplow, &n, data, ipiv, work, &info);
        else if ( (class_id == mxSINGLE_CLASS) && !strcmp(matrix_type, "pp") )
            spptri (&uplow, &n, data, &info);
        else if ( (class_id == mxDOUBLE_CLASS) && !strcmp(matrix_type, "pp") )
            dpptri (&uplow, &n, data, &info);
        else if ( (class_id == mxSINGLE_CLASS) && !strcmp(matrix_type, "tp") )
            stptri (&uplow, &is_unit_tri, &n, data, &info);
        else if ( (class_id == mxDOUBLE_CLASS) && !strcmp(matrix_type, "tp") )
            dtptri (&uplow, &is_unit_tri, &n, data, &info);
        else 
            mexErrMsgIdAndTxt ("packed:call_lapack:unknownMatrixType", \
                "Unknown matrix type.");

        if (!strcmp(matrix_type, "sp")) {
            mxFree(work);
        }

        if (info < 0) {
            char msg[100];
            sprintf (msg, \
                "Error calling LAPACK routine, internal input parameter #%d.", \
                -info);
            mexErrMsgIdAndTxt ("packed:call_lapack:badInput", msg);
        }
        
        array2 = mxCreateNumericMatrix (0, 0, class_id, mxREAL);
        mxSetData (array2, data);
        mxSetM (array2, mxGetM (array));
        mxSetN (array2, mxGetN (array));
        
        plhs[0] = mxCreateDoubleScalar (info);
        plhs[1] = array2;
    }
    else if (!strcmp (op_name, "trs")) {
        char uplowL;
        int nL;
        int nB;
        void *L;
        mxArray *mxB;
        int mB;
        void *B;
        size_t temp;
        void *data;
        int *ipiv;
        mxClassID class_id;
        int info;
        mxArray *mxX;
        char trans = 'N';
        char is_unit_tri = 'N';

        uplowL = (char)   mxGetScalar (prhs[2]);
        nL     = (int)    mxGetScalar (prhs[3]);
        nB     = (int)    mxGetScalar (prhs[4]);
        L      = (void *) mxGetData   (prhs[5]);
        ipiv   = (int *)  mxGetData   (prhs[6]);
        mxB    = prhs[7];
        mB     = (int)    mxGetScalar (prhs[8]);

        check_input(mxB);
        
        B      = (void *) mxGetData(mxB);
        temp = mxGetNumberOfElements (mxB) * mxGetElementSize (mxB);
        data = mxMalloc (temp);
        memcpy (data, B, temp);

        class_id = mxGetClassID (mxB);
        if      ( (class_id == mxSINGLE_CLASS) && !strcmp(matrix_type, "sp") )
            ssptrs (&uplowL,                       &nL, &nB, L, ipiv, data, &mB, &info);
        else if ( (class_id == mxDOUBLE_CLASS) && !strcmp(matrix_type, "sp") )
            dsptrs (&uplowL,                       &nL, &nB, L, ipiv, data, &mB, &info);
        else if ( (class_id == mxSINGLE_CLASS) && !strcmp(matrix_type, "pp") )
            spptrs (&uplowL,                       &nL, &nB, L,       data, &mB, &info);
        else if ( (class_id == mxDOUBLE_CLASS) && !strcmp(matrix_type, "pp") )
            dpptrs (&uplowL,                       &nL, &nB, L,       data, &mB, &info);
        else if ( (class_id == mxSINGLE_CLASS) && !strcmp(matrix_type, "tp") )
            stptrs (&uplowL, &trans, &is_unit_tri, &nL, &nB, L,       data, &mB, &info);
        else if ( (class_id == mxDOUBLE_CLASS) && !strcmp(matrix_type, "tp") )
            dtptrs (&uplowL, &trans, &is_unit_tri, &nL, &nB, L,       data, &mB, &info);
        else 
            mexErrMsgIdAndTxt ("packed:call_lapack:unknownMatrixType", \
                "Unknown matrix type.");

        if (info < 0) {
            char msg[100];
            sprintf (msg, \
                "Error calling LAPACK routine, internal input parameter #%d.", \
                -info);
            mexErrMsgIdAndTxt ("packed:call_lapack:badInput", msg);
        }
        
        mxX = mxCreateNumericMatrix (0, 0, class_id, mxREAL);
        mxSetData (mxX, data);
        mxSetM (mxX, mB);
        mxSetN (mxX, nB);
            
        plhs[0] = mxCreateDoubleScalar (info);
        plhs[1] = mxX;
    }
    else if (!strcmp (op_name, "con")) {
        char uplowL;
        int nL;
        mxArray *mxL;
        int *ipiv;
        void *normA;
        void *L;
        void *work;
        int *iwork;
        mxClassID class_id;
        void *rcond;
        int info;
        mxArray *temp;
        char norm_type = '1';
        char is_unit_tri = 'N';
        
        uplowL = (char) mxGetScalar (prhs[2]);
        nL     = (int)  mxGetScalar (prhs[3]);
        mxL    = prhs[4];
        ipiv   = (int *) mxGetData (prhs[5]);
        normA  = mxGetData (prhs[6]);
        L = mxGetData(mxL);

        check_input(mxL);
        
        work  = mxMalloc (3*nL*mxGetElementSize(mxL));
        iwork = (int *) mxMalloc (nL*sizeof(int));
        rcond = mxMalloc (mxGetElementSize(mxL));
        
        class_id = mxGetClassID (mxL);
        if      ( (class_id == mxSINGLE_CLASS) && !strcmp(matrix_type, "sp") )
            sspcon (            &uplowL,               &nL, L, ipiv, normA, rcond, work, iwork, &info);
        else if ( (class_id == mxDOUBLE_CLASS) && !strcmp(matrix_type, "sp") )
            dspcon (            &uplowL,               &nL, L, ipiv, normA, rcond, work, iwork, &info);
        else if ( (class_id == mxSINGLE_CLASS) && !strcmp(matrix_type, "pp") )
            sppcon (            &uplowL,               &nL, L,       normA, rcond, work, iwork, &info);
        else if ( (class_id == mxDOUBLE_CLASS) && !strcmp(matrix_type, "pp") )
            dppcon (            &uplowL,               &nL, L,       normA, rcond, work, iwork, &info);
        else if ( (class_id == mxSINGLE_CLASS) && !strcmp(matrix_type, "tp") )
            stpcon (&norm_type, &uplowL, &is_unit_tri, &nL, L,              rcond, work, iwork, &info);
        else if ( (class_id == mxDOUBLE_CLASS) && !strcmp(matrix_type, "tp") )
            dtpcon (&norm_type, &uplowL, &is_unit_tri, &nL, L,              rcond, work, iwork, &info);
        else 
            mexErrMsgIdAndTxt ("packed:call_lapack:unknownMatrixType", \
                "Unknown matrix type.");

        if (info < 0) {
            char msg[100];
            sprintf (msg, \
                "Error calling LAPACK routine, internal input parameter #%d.", \
                -info);
            mexErrMsgIdAndTxt ("packed:call_lapack:badInput", msg);
        }
        
        mxFree (work);
        mxFree (iwork);
        
        plhs[0] = mxCreateDoubleScalar (info);
        temp = mxCreateNumericMatrix (1, 1, class_id, mxREAL);
        mxSetData (temp, rcond);
        plhs[1] = temp;
    }
    else if (!strcmp (op_name, "lan")) {
        mxArray *mxA;
        int nA;
        char uplowA;
        void *normA;
        void *work;
        char norm_type;
        void *A;
        mxArray *temp;
        mxClassID class_id;
        char is_unit_tri = 'N';

        norm_type = (char) mxGetScalar (prhs[2]);
        uplowA    = (char) mxGetScalar (prhs[3]);
        nA        = (int)  mxGetScalar (prhs[4]);
        mxA       = prhs[5];

        check_input(mxA);
        
        work  = mxMalloc (nA*mxGetElementSize(mxA));
        A = mxGetData(mxA);
        normA = mxMalloc (mxGetElementSize(mxA));
        
        class_id = mxGetClassID (mxA);
        /*{
            char msg[100];
            sprintf (msg, "ClassName: %s.\n", mxGetClassName (mxA));
            mexWarnMsgIdAndTxt ("packed:call_lapack:badInput", msg);
        }*/

        if      ( (class_id == mxSINGLE_CLASS) && !strcmp(matrix_type, "sp") ){
            single temp;
            temp = slansp (&norm_type, &uplowA, &nA, A, work);
            memcpy (normA, &temp, sizeof(single));
        }
        else if ( (class_id == mxDOUBLE_CLASS) && !strcmp(matrix_type, "sp") ){
            double temp;
            temp = dlansp (&norm_type, &uplowA, &nA, A, work);
            memcpy (normA, &temp, sizeof(double));
        }
        else if ( (class_id == mxSINGLE_CLASS) && !strcmp(matrix_type, "tp") ){
            single temp;
            temp = slantp (&norm_type, &uplowA, &is_unit_tri, &nA, A, work);
            memcpy (normA, &temp, sizeof(single));
        }
        else if ( (class_id == mxDOUBLE_CLASS) && !strcmp(matrix_type, "tp") ){
            double temp;
            temp = dlantp (&norm_type, &uplowA, &is_unit_tri, &nA, A, work);
            memcpy (normA, &temp, sizeof(double));
        }
        else {
            mexErrMsgIdAndTxt ("packed:call_lapack:unknownMatrixType", \
                "Unknown matrix type.");
        }

        mxFree (work);
        
        temp = mxCreateNumericMatrix (1, 1, class_id, mxREAL);
        mxSetData (temp, normA);
        plhs[0] = temp;
    }
    else {
        mexErrMsgIdAndTxt ("packed:call_lapack:unknownOpName", \
            "Unknown operation name.");
    }
}

void check_input (mxArray *array)
{   
    mxClassID class_id;

    if (mxIsComplex (array))
        mexErrMsgIdAndTxt ("packed:call_lapack:complexNotSupported", \
            "Complex numbers are not supported.");
    
    class_id = mxGetClassID (array);
    if (class_id != mxDOUBLE_CLASS && class_id != mxSINGLE_CLASS)
        mexErrMsgIdAndTxt ("packed:call_lapack:nonFloatNotSupported", \
            "Non-floating point numbers are not supported.");
}

mxClassID get_int_mxclassid (void)
{
    if (sizeof(int) == (16/8))
        return mxINT16_CLASS;
    else if (sizeof(int) == (32/8))
        return mxINT32_CLASS;
    else if (sizeof(int) == (64/8))
        return mxINT64_CLASS;
    else
        mexErrMsgIdAndTxt ("call_lapack:unknownIntSize", \
            "Unknown int size.");
}

