frontal
These routines assist in the manipulation of matrices with same shape but different content. For example, performing the product A*b is trivial for matrix A and vector b, but what would you do if you have several such a product to form? Examples abound: rotations, Jacobians, covariances, etc. Using the frontal routines, you'd collect them all in a three-dimensional matrix or third-order tensor, with each k-th frontal panel of A(:,:,k) and b(:,:,k) storing one such a related matrix and vector. Then calling

  C = frontal_mtimes(A, b);

would do the equivalent of

  for k=1:size(A,3),  C(:,:,k) = A(:,:,k) * b(:,:,k);  end

but using internally different algorithms depending on the dimensions of A (including a C-mex option). If you like operator overloading, you can do instead:

  A = frontal(A);
  b = frontal(b);
  C = A*b;

You might want to compile the file frontal_mtimes_helper.c, but it's not required.

