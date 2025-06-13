If you are getting 'Out of memory' errors while manipulating symmetric matrices, read on. (Usage instructions are down at the bottom.)

I should say upfront that linear algebra is significantly slower (compared to full storage) because of the well-known lack of level-3 BLAS operations for packed storage; it's up to you to judge if this price is worth to pay for being able to solve larger systems before you get an 'Out of memory' error.

Symmetric matrices stored in packed format take up only (approximately) half of the memory that would be necessary to store them in full; furthermore, element-wise arithmetic operations are performed only over the non-redundant lower or upper triangular part of the matrix, and operations such as matrix transposition have zero cost.

This package adds support to matrices stored in packed format to Matlab. It provides an interface for the creation and access to such matrices. Furthermore, it extends a package called trilin for linear algebra (factorization, solution of linear systems, inversion, and estimation of conditioning number) on packed storage. (Notice that trilin doesn't implement linear algebra algorithms, only exposes LAPACK's. It is useful if you want to factorize a matrix once then re-use its result multiple times; for example, in linear least squares problems A * x = b + r one employes the same factorization of A to solve the linear system x = A'*A \ A'b, to obtain the a posteriori covariance matrix C = inv(A'*A), and to estimate its conditioning.)

I tried to follow as much as possible the design and implementation of sparse matrices in Matlab (Gilbert et al., 1992). More especifically:
- no packed matrices are created without some overt direction from the user (i.e., via class constructor packed());
- operations of packed matrices produce packed matrices unless the operator destroys structures (e.g., A(1,end) = +1; A(end,1) = -1; destroys symmetry);
- operations on a mixture of packed and non-packed matrices produce a packed result unless the operator destroys structure;
- the value of the result of an operation does not depend on the storage class of the operands, although the storage class of the result may;
- in the interest of simplicity, we rejected the possibility of packed matrices in which all the values not explicitily stored would be some scalar rather than zero (in the case of triangular matrices or the symmetric part in the case of symmetric matrices).

Known limitations are:
- the access of individual elements in packed stored matrices is expected to be more costly than in full storage, because of the more complicated indexing necessary;
- complex data is marginally supported, meaning you can create triangular or symmetric (but not Hermitian) complex matrices, but operations and functions are undefined for complex data;
- linear algebra is significantly slower (compared to full storage) because of the well-known lack of level-3 BLAS operations for packed storage; it's up to you to judge if this price is worth to pay for being able to solve larger systems before you get an 'Out of memory' error.
- this package was built before the recent release of LAPACK routines for Rectangular Full Packed format (RFPF; see Gustavson et al., 2008). Such a formulation is remarkable in the sense that it requires minimal storage while at the same time is much more efficient than the then existing packed storage LAPACK routines. It'd be great if the package offered here were adapted to offer support for RFPF in Matlab.

A few technical details:
- data types supported are
    'double', 'single', ...
    'int8', 'uint8',  ...
    'int16', 'uint16',  ...
    'int32', 'uint32',  ...
    'logical', 'char'
- ideally this package would offer a new matrix storage class (packed, in addition to full and sparse already available), instead of a user class. That being said, I've overloaded functions class and isa to evaluate its data's class, so class(packed(single(0))) will return 'single', not 'packed'; use function ispacked to check for that, like you'd use function issparse;
- I let @sparse do the error checking for size compatibility; that significantly simplifies the code;
- the routines are accompanied by an extensive test suite, which can be ran by calling test_packed.

For background on the packed format, see the relevant sections in the LAPACK User's Guide (specially sections "Matrix Storage Schemes", "Packed Storage", and "Naming Scheme").

At last, I must mention that I wrote this package a few years ago and have not used it since then, so please report any bugs that you might encounter.


Gilbert, John R., Cleve Moler, and Robert Schreiber, "Sparse Matrices in MATLAB: Design and Implementation," SIAM Journal on Matrix Analysis and Applications, Vol. 13, 1992, pp. 333-356. Available at <http://www.mathworks.com/access/helpdesk/help/pdf_doc/otherdocs/simax.pdf>.

Fred G. Gustavson, Jerzy Wasniewski, and Jack J. Dongarra. "Rectangular Full Packed Format for Cholesky's Algorithm: Factorization, Solution and Inversion." LAPACK Working Note 199, April 2008. Available at <http://www.netlib.org/lapack/lawnspdf/lawn199.pdf>.

E. Anderson, Z. Bai, C. Bischof, S. Blackford, J. Demmel, J. Dongarra, J. Du Croz, A. Greenbaum, S. Hammarling, A. McKenney, D. Sorensen, "LAPACK Users' Guide," Third Edition (Updated 22 Aug 1999); SIAM, 407 pp., 1999. Available at <http://www.netlib.org/lapack/lug/>.


HOW TO USE IT: unpack zipfile into c:\Work\fx\, then copy & paste the following in the Matlab prompt:
    addpath(genpath('c:\Work\fx\'))
    test_trilin
    test_packed
    do_myprofile

