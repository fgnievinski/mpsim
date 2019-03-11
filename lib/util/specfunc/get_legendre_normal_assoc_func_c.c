#include <stdio.h>
#include <math.h>
#include <stddef.h>
#include "mex.h"


void get_legendre_normal (int n_max, double t, double *all_P);
size_t sub2ind (size_t l, size_t m, size_t i, size_t j);


/* mexFunction is the gateway routine for the MEX-file. */ 
void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *t, *all_P;
    int n_max;
    mxArray *mx_n_max, *mx_t, *mx_all_P;
    mwSize num_pts, i, dims[3], s;

    if (nrhs != 2)  
        mexErrMsgTxt ("Number of right-hand arguments should be 2.\n");
    
    /* Retrieve function arguments: */
    /* all_P = get_legendre_normal_assoc_func (n_max, t) */
    mx_n_max = prhs[0];
    mx_t = prhs[1];

    if ( mxGetNumberOfElements(mx_n_max) != 1  )
        mexErrMsgTxt ("First argument should be a scalar.");
    if ( mxGetClassID(mx_n_max) != mxDOUBLE_CLASS )
        mexErrMsgTxt ("Second argument should be of type double.");

    n_max = (int) * mxGetPr (mx_n_max);
    num_pts = mxGetNumberOfElements(mx_t);

    /**/    
    dims[0] = n_max+1;
    dims[1] = n_max+1;
    dims[2] = num_pts;
    mx_all_P = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, 0);

    /**/    
    s = mxGetElementSize(mx_t);
    t = (double *) mxGetPr (mx_t);
    all_P = (double *) mxGetPr (mx_all_P);
    for (i = 0; i <= (num_pts-1); i++) {
        /* mexPrintf("t = %g\n", (double) *t); */
        get_legendre_normal (n_max, (double) *t, all_P);
        t += 1;
        all_P += (n_max+1) * (n_max+1);
    }
    
    plhs[0] = mx_all_P;
    return;    
}


void get_legendre_normal (int n_max, double t, double all_P[])
{
    int m_max = n_max;
    int num_n = n_max + 1, num_m = m_max + 1;
    int n, m;
    
    /*printf("t=%f\n", t);*/
    /*    
    % There's a recurrence formula for P_{nm}, n > (m + 1),
    % expressed in terms of previuos P_{n-1,m} and P_{n-2,m}, i.e.,
    % with varying degree n and fixed order m.
    % The seed values for the recurrence are P_{n=m,m} and P_{n=m+1,n}. 
    */
    
    /*% compute main diagonal P_{n=m,m} */
    {
        double P_00, P_11, P_m1m1, P_mm;
        
        P_00 = 1.0;
            all_P[sub2ind(num_n, num_m, 0, 0)] = P_00;
        P_11 = sqrt(3.0) * sqrt(1.0 - t*t);
            /*printf("P_11=%f\n", P_11);*/
            all_P[sub2ind(num_n, num_m, 1, 1)] = P_11;
        /*% previous diagonal element P_{n=m-1,m-1}:*/
        P_m1m1 = P_11;
        for (m=2; m<=m_max; m++)
        {
            P_mm = sqrt(1.0 - t*t) * sqrt((2.0*m +1.0)/(2.0*m)) * P_m1m1;  
            /*% Borre, eq. (13), p. 4.*/
            all_P[sub2ind(num_n, num_m, m, m)] = P_mm;
            
            P_m1m1 = P_mm;
            /*printf("m=%d P_mm=%f\n", m, P_mm);*/
        }
    }


    /*% compute second diagonal P_{n=m+1,m}*/
    {
        double P_mm, temp;
        for (m=0; m<=(m_max-1); m++)
        {
            P_mm = all_P[sub2ind(num_n, num_m, m, m)];
            
            /*
            % temp is the ratio of normalization factors
            % for P_{n=m+1,m} and P_{n=m,m}: 
            */
            temp = sqrt(2.0*m + 3.0) / (2.0*m + 1.0);
            
        all_P[sub2ind(num_n, num_m, m+1, m)] = t * (2.0*m + 1.0) * P_mm * temp;
            /*
            % The last formula above is given by Borre,
            % eq. (9), p. 3, and also by Weisstein, eq. (69),
            % except for the temp factor, which comes from the 
            % fully normalization used here.
            % To derive the formula for temp simplify the ratio
            % Z_{n=m+1,m}/Z_{n=m,m}, where Z is the normalization
            % factor Z = sqrt(k * (2*n + 1) * (n - m)! / (n + m)!)
            */
        }
    }

    
    /*% compute all other elements */
    {
        double P_nm, P_n1m, P_n2m, a_nm, b_nm;
        
        for (m=0; m<=(m_max-1); m++)
        {
            /*
            % The seed values are the diagonal P_{n=m,m}.
            % The recurrence uses two previous P in n, i.e.,
            % P_{n-1,m} and P_{n-2,m}.
            % Therefore we need to run from n==(m+2) --
            % (P_{n=m,m} P_{n=m+1,m} being already known) -- 
            % to increasing n:
            */
            for (n=(m+2); n<=n_max; n++)
            {
                P_n1m = all_P [sub2ind(num_n, num_m, n-1, m)];
                P_n2m = all_P [sub2ind(num_n, num_m, n-2, m)];
                
            a_nm = sqrt( ((2.0*n - 1.0)*(2.0*n + 1.0)) / ((n - m)*(n + m)) );
            b_nm = sqrt( ((2.0*n + 1.0)*(n + m - 1.0)*(n - m - 1.0)) / ((2.0*n - 3.0)*(n + m)*(n - m)) );

                P_nm = t * a_nm * P_n1m - b_nm * P_n2m;
                all_P[sub2ind(num_n, num_m, n, m)] = P_nm;
            }
        }
    }
    
}

    
size_t
sub2ind (size_t l, size_t m, size_t i, size_t j)
{
    return l*j + i;
}


/*
%!test
%! % Test one expression that I derived myself and is used
%! % to compute the second diagonal P_{n=m+1,m}
%! for m=0:360
%!     temp = sqrt(2*m + 3) / (2*m + 1);
%!     
%!     n = m;
%!     if (m == 0), k = 1;  else k = 2;  end
%!     Z_mm = sqrt( k * (2*n + 1) * prod(1:(n - m)) / prod(1:(n + m)) );
%!     
%!     n = m + 1;
%!     if (m == 0), k = 1;  else k = 2;  end
%!     Z_m1m = sqrt( k * (2*n + 1) * prod(1:(n - m)) / prod(1:(n + m)) );
%! 
%!     %[m, temp, Z_m1m / Z_mm, Z_m1m, Z_mm]
%!     %pause
%!     % Disable warnings because we'll get lots of division by zero,
%!     % due to floating point arithmetic underflows in either
%!     % Z_mm or Z_m1m.
%!     warning off
%!     assert ( abs(temp - (Z_m1m / Z_mm)) < eps ...
%!              || (Z_mm == 0) ...
%!              || (Z_m1m == 0) );
%!     warning on
%! end

%!test
%! % Test first few elements.
%! 
%! for x=linspace(-1, +1, 100)
%!     %x  % debug
%!     lat_sph = asin(x);
%!     
%!     % unnormalized values, including the factor (-1)^m:
%!     % given by Weisstein, eq. (70)-(85):
%!     P_00 = 1;
%!     P_10 = x;
%!     P_11 = - (1 - x^2)^(1/2);
%!     P_20 = (1/2) * (3*x^2 - 1);
%!     P_21 = - 3*x * (1 - x^2)^(1/2);
%!     P_22 = 3*(1 - x^2);
%!     P_30 = (1/2)*x * (5*x^2 - 3);
%!     P_31 = (3/2) * (1 - 5*x^2) * (1 - x^2)^(1/2);
%!     P_32 = 15*x * (1 - x^2);
%!     P_33 = -15 * (1 - x^2)^(3/2);
%!     P_40 = (1/8) * (35*x^4 - 30*x^2 + 3);
%!     P_41 = (5/2) * x * (3 - 7*x^2) * (1 - x^2)^(1/2);
%!     P_42 = (15/2) * (7*x^2 - 1) * (1 - x^2);
%!     P_43 = -105 * x * (1 - x^2)^(3/2);
%!     P_44 = 105 * (1 - x^2)^2;
%!     P_50 = (1/8) * x * (63*x^4 - 70*x^2 + 15);
%!     
%!     % calculate normalization factors
%!     % and notation factors:
%!     normal = zeros(6, 6);
%!     notation = zeros(6, 6);
%!     for n=0:5
%!         for m=0:5
%!             if (m == 0), k = 1;  else k = 2;  end
%!             Z_nm = sqrt( k * (2*n + 1) * prod(1:(n - m)) / prod(1:(n + m)) );
%!             normal(n+1, m+1) = Z_nm;
%!     
%!             notation(n+1, m+1) = 1/(-1)^m;
%!         end
%!     end
%!     P_00_normal = P_00 * notation(0+1, 0+1) * normal(0+1, 0+1);
%!     P_10_normal = P_10 * notation(1+1, 0+1) * normal(1+1, 0+1);
%!     P_11_normal = P_11 * notation(1+1, 1+1) * normal(1+1, 1+1);
%!     P_20_normal = P_20 * notation(2+1, 0+1) * normal(2+1, 0+1);
%!     P_21_normal = P_21 * notation(2+1, 1+1) * normal(2+1, 1+1);
%!     P_22_normal = P_22 * notation(2+1, 2+1) * normal(2+1, 2+1);
%!     P_30_normal = P_30 * notation(3+1, 0+1) * normal(3+1, 0+1);
%!     P_31_normal = P_31 * notation(3+1, 1+1) * normal(3+1, 1+1);
%!     P_32_normal = P_32 * notation(3+1, 2+1) * normal(3+1, 2+1);
%!     P_33_normal = P_33 * notation(3+1, 3+1) * normal(3+1, 3+1);
%!     P_40_normal = P_40 * notation(4+1, 0+1) * normal(4+1, 0+1);
%!     P_41_normal = P_41 * notation(4+1, 1+1) * normal(4+1, 1+1);
%!     P_42_normal = P_42 * notation(4+1, 2+1) * normal(4+1, 2+1);
%!     P_43_normal = P_43 * notation(4+1, 3+1) * normal(4+1, 3+1);
%!     P_44_normal = P_44 * notation(4+1, 4+1) * normal(4+1, 4+1);
%!     P_50_normal = P_50 * notation(5+1, 0+1) * normal(5+1, 0+1);
%!     
%!     % These ones are given by Torge, eq. (3.93c), p. 71, already normalized:
%!     % test the normalization done in this test:
%!     co_lat_sph = pi/2 - lat_sph;
%!     assert (P_00_normal, 1, -10*eps);
%!     assert (P_10_normal, sqrt(3)*cos(co_lat_sph), -10*eps);
%!     assert (P_11_normal, sqrt(3) * sin(co_lat_sph), -10*eps);
%!     assert (P_20_normal, (1/2)*sqrt(5)*(3*cos(co_lat_sph)^2 - 1), -10*eps);
%!     assert (P_21_normal, sqrt(15)*sin(co_lat_sph)*cos(co_lat_sph), -10*eps);
%!     assert (P_22_normal, (1/2) * sqrt(15) * sin(co_lat_sph)^2, -10*eps);
%!     
%!     all_P = get_legendre_normal_assoc_func (5, x);
%!     
%!     % Test main diagonal:
%!     assert (all_P(0+1, 0+1), P_00_normal, -10*eps);
%!     assert (all_P(1+1, 1+1), P_11_normal, -10*eps);
%!     assert (all_P(2+1, 2+1), P_22_normal, -10*eps);
%!     assert (all_P(3+1, 3+1), P_33_normal, -10*eps);
%!     assert (all_P(4+1, 4+1), P_44_normal, -10*eps);
%!     
%!     % Test second diagonal:
%!     assert (all_P(1+1, 0+1), P_10_normal, -10*eps);
%!     assert (all_P(2+1, 1+1), P_21_normal, -10*eps);
%!     assert (all_P(3+1, 2+1), P_32_normal, -10*eps);
%!     assert (all_P(4+1, 3+1), P_43_normal, -10*eps);
%!     
%!     % Test other elements:
%!     % 3rd diagonal:
%!     assert (all_P(2+1, 0+1), P_20_normal, -10*eps);
%!     assert (all_P(3+1, 1+1), P_31_normal, -10*eps);
%!     assert (all_P(4+1, 2+1), P_42_normal, -10*eps);
%!     % 4th diagonal:
%!     assert (all_P(3+1, 0+1), P_30_normal, -10*eps);
%!     assert (all_P(4+1, 1+1), P_41_normal, -10*eps);
%!     % 5th diagonal:
%!     assert (all_P(4+1, 0+1), P_40_normal, -10*eps);
%!     % loose element:
%!     assert (all_P(5+1, 0+1), P_50_normal, -100*eps);
%!     
%! end

%!test
%! % Use control equation given by Torge, Geodesy, 3rd ed., p. 71:
%! % which reads \sum_{m=0}^n \bar P_{nm} (t)^2 = 2 n + 1
%! n = floor(100*rand);
%! all_P = get_legendre_normal_assoc_func (n, rand);
%! temp1 = sum(all_P.^2, 2);
%! temp2 = 2*(0:n)' + 1;
%! %[temp2, temp1, temp1 - temp2]  % debug
%! assert (temp1, temp2, -1e-10);

%!test
%! % Our function corresponds roughly with Mathworks' legendre()
%! if ~exist('legendre', 'file'), return;  end
%! 
%! n_max = 360;
%! for x=linspace(-1, +1, 10)
%!     all_P = get_legendre_normal_assoc_func (n_max, x);
%!     for n=0:n_max
%!         N_n_allm = legendre (n, x, 'norm')';
%!         % factor is sqrt(2) for m==0 and 2 for m<>0
%!         factor = 2*ones(1, n+1);
%!         factor(0+1) = sqrt(2);
%!         %[all_P(n+1, 0+1:n+1)', (N_n_allm.*factor)'], pause  % debug
%!         assert(all_P(n+1, 0+1:n+1)', (N_n_allm.*factor)', -10000*eps);
%!     end
%! end
! 
*/
