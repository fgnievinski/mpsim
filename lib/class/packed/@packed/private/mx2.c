#include "matrix.h"

bool mx2IsPacked (const mxArray *A)
{
    return (mxIsClass (A, "packed"));
}

bool mx2IsSparse (const mxArray *A)
{
    if (!mx2IsPacked (A))
        return mxIsSparse (A);

    return false;
}

bool mx2IsComplex (const mxArray *A)
{
    if (!mx2IsPacked (A))
        return mxIsComplex (A);

    return mxIsComplex (mxGetField (A, 0, "data"));
}

bool mx2IsEmpty (const mxArray *A)
{
    if (!mx2IsPacked (A))
        return mxIsEmpty (A);

    return (   mxIsEmpty (mxGetField (A, 0, "data")) \
            && mxIsEmpty (mxGetField (A, 0, "type")) );
}

char mx2GetPackedType (const mxArray *A)
{
    if (!mx2IsPacked (A))
        return '\0';

    {
    mxArray *temp;
    temp = mxGetField (A, 0, "type");
    if (mxIsEmpty(temp))
        return '\0';
    else
        return (char)mxGetScalar (temp);
    }
}

char mx2GetPackedUplow (const mxArray *A)
{
    if (!mx2IsPacked (A))
        return '\0';

    {
    mxArray *temp;
    temp = mxGetField (A, 0, "uplow");
    if (mxIsEmpty(temp))
        return '\0';
    else
        return (char)mxGetScalar (temp);
    }
}

int mx2GetNumberOfDimensions (const mxArray *A)
{
    if (!mx2IsPacked (A))
        return mxGetNumberOfDimensions (A);

    return 2;
}

int mx2GetM (const mxArray *A)
{
    if (!mx2IsPacked (A))
        return mxGetM (A);

    return (int) mxGetScalar (mxGetField (A, 0, "order"));
}

int mx2GetN (const mxArray *A)
{
    if (!mx2IsPacked (A))
        return mxGetN (A);

    return (int) mxGetScalar (mxGetField (A, 0, "order"));
}

void *mx2GetData (const mxArray *A)
{
    if (!mx2IsPacked (A))
        return mxGetData (A);

    return mxGetData (mxGetField (A, 0, "data"));
}

double mx2GetScalar (const mxArray *A)
{
    if (!mx2IsPacked (A))
        return mxGetScalar (A);

    return mxGetScalar (mxGetField (A, 0, "data"));
}

char *mx2ArrayToString (const mxArray *A)
{
    if (!mx2IsPacked (A))
        return mxArrayToString (A);

    return mxArrayToString (mxGetField (A, 0, "data"));
}

int mx2GetElementSize (const mxArray *A)
{
    if (!mx2IsPacked (A))
        return mxGetElementSize (A);

    return mxGetElementSize (mxGetField (A, 0, "data"));
}

mxClassID mx2GetClassID (const mxArray *A)
{
    if (!mx2IsPacked (A))
        return mxGetClassID (A);

    return mxGetClassID (mxGetField (A, 0, "data"));
}

int mx2GetNumberOfElements (const mxArray *A)
{
    if (!mx2IsPacked (A))
        return mxGetNumberOfElements (A);

    return mxGetNumberOfElements (mxGetField (A, 0, "data"));
}

bool mx2IsScalar (const mxArray *A)
{
    return (mx2GetNumberOfElements (A) == 1);
}

