trilin
Facilitates the reuse of matrix factorizations in large dense least squares problems and other linear systems.
If you like the idea behind MATLAB's linsolve or Tim Davis' linfactor, you might find trilin useful as well.

Let's say you have a generalized least squares problem,

  x = C * u
  C = inv(N)

where

  N = inv(A' * inv(V) * A)
  u = A' * inv(V) * b

Matrices A and V are dense and large, and V is not diagonal. Matrix C is one of the desired final results, not just an intermediary result to obtain the vector x. Normally you'd want to use MATLAB's own lslin to solve this type of problem.

Assume further the system to be sufficiently well conditioned. In this case, the method of solution based on explicit normal equations is the method of choice, specially for large problems. That's because (1) it remains well conditioned and (2) it is much faster than, e.g., QR (that would be necessary were the system poorly conditioned).

This could be implemented using the backslash operator as follows:
  
  Vf = chol(V, 'lower');
  Ag = Vf \ A;
  bg = Vf \ b;
  N = Ag' * Ag;
  u = Ag' * bg;
  Nf = chol(N, 'lower');
  x = Nf' \ (Nf * u);
  C = Nf' \ (Nf * eye(size(N)));

Numerical analysits, don't be alarmed! As we said above, although one could do QR as in, e.g., x = Ag \ bg, here we don't want to do that because size(A,1) >> size(A,2); furthermore, this is harmless under the assumption that rcond(Ag) ~ 1.

Using MATLAB's linsolve, you would do:

  opt  = struct('LT',true);
  optt = struct('LT',true, 'TRANSA',true);
  Vf = chol(V, 'lower');
  Ag = linsolve(A, Vf, opt);
  bg = linsolve(b, Vf, opt);
  N = Ag' * Ag;
  u = Ag' * bg;
  Nf = chol(N, 'lower');
  x = linsolve(Nf, linsolve(Nf, u, opt), optt);
  C = linsolve(Nf, linsolve(Nf, eye(size(N)), opt), optt);

Using Tim Davis' linfactor, you could do better:

  opt  = struct('LT',true);
  Vf = linfactor(Vf);
  Ag = linsolve(A, Vf.L, opt);  % not Ag = linfactor(Vf, A);
  bg = linsolve(b, Vf.L, opt);  % not bg = linfactor(Vf, b);
  N = Ag' * Ag;
  u = Ag' * bg;
  Nf = linfactor(N);
  x = linfactor(Nf, u);
  C = linfactor(Nf, eye(size(N)));

Finally, using the trilin package, you would do "simply":
  
  optp = struct('type','positive-definite', 'uplow','lower');
  optt = struct('type','triangular', 'uplow','lower', 'trans','no');
  Vf = trifactor(V, optp);
  Ag = trisolve(A, Vf, optt);
  bg = trisolve(b, Vf, optt);
  N = Ag' * Ag;
  u = Ag' * bg;
  Nf = trifactor(N, optp);
  x = trisolve(u, Nf, optp);
  C = triinv(Nf, optp, true);

The advantages brought by trilin are mainly due to reduced overhead. E.g., functions need not to discover the matrix structure prior to applying a solver; also the upper/lower triangular part of the Cholesky factor needs not be zeroed out explicitly; the inverse, whenever necessary, is calculated without forming an explicit identity matrix. Although inconsequential for small problems, these few-percent improvements may amount to hours of processing for very large problems that we are concerned with here.

The "smoking gun" for trilin might be in the estimation of condition numbers. With trilin you'd do simply:

  Vc = tricond (norm(V,1), Vf, optp);
  Nc = tricond (norm(N,1), Nf, optp);

MATLAB instead would recompute the matrix factorizations Vf, Nf; moreover, it'd not exploit the strucut of V,N. (As per documentation for rcond, it computes an LU factorization of a general matrix, followed by estimation of the condition number of a general matrix.) So think of trilin as a shortcut when you already have the factorizations precomputed, with the additional benefit of using the best estimation algorithm, given the general, positive-definite, symmetric, or triangular matrix at hand.

LAPACK routines are called internally, facilitated by Tim Toolan's excellent package (slightly modified). In a sense, trilin is "just" a wrapper around the functionality already present in LAPACK (not unlike MATLAB itself in its beginning). A helpful and non-trivial one, though -- calling LAPACK directly often feels like walking on eggs, segfaults always lurking around the corner.

Complex data is not supported currently.
LAPACK's support for symmetric non postive definite matrices is exposed.
In total, the following matrix structures are supported: diagonal, triangular, symmetric, positive-definite, general.
Sparse data has poor support, meaning it won't break but there will be a performance penalty -- contributions welcome.

It comes with an extensive test suite. 
To install it, unzip the file contents to, e.g., c:\work\fx\trilin\, then do:

  addpath(genpath('c:\work\fx\trilin\'))
  lapack
  test_trilin

where the first line is NOT to be confused with

  addpath(genpath('c:\work\fx\trilin\trilin'))  % WRONG!

