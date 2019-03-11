bool mx2IsPacked (const mxArray *A);
bool mx2IsSparse (const mxArray *A);
bool mx2IsComplex (const mxArray *A);
bool mx2IsEmpty (const mxArray *A);
char mx2GetPackedType (const mxArray *A);
char mx2GetPackedUplow (const mxArray *A);
int mx2GetNumberOfDimensions (const mxArray *A);
int mx2GetM (const mxArray *A);
int mx2GetN (const mxArray *A);
void *mx2GetData (const mxArray *A);
double mx2GetScalar (const mxArray *A);
char *mx2ArrayToString (const mxArray *A);
int mx2GetElementSize (const mxArray *A);
mxClassID mx2GetClassID (const mxArray *A);
int mx2GetNumberOfElements (const mxArray *A);
bool mx2IsScalar (const mxArray *A);

