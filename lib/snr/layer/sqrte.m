% sqrte.m - evanescent SQRT for waves problems
%
% Usage: y = sqrte(z)
%
% z = array of complex numbers
% y = square root of z
%
% Notes: for z = a-j*b, y is defined as follows:
%                                           
%             [ sqrt(a-j*b),  if b~=0  
%         y = [ sqrt(a),      if b==0 and a>=0              
%             [ -j*sqrt(|a|), if b==0 and a<0   (i.e., the negative of what the ordinary SQRT gives)
% 
%         this definition is necessary to produce exponentially-decaying evanescent waves 
%         (under the convention exp(j*omega*t) for harmonic time dependence)
%
%         it is equivalent to the operation y = conj(sqrt(conj(a-j*b))), 
%         but it fixes a bug in the ordinary SQRT in MATLAB arising whenever the real part is negative 
%         and the imaginary part is an array with some zero elements. For example, compare the outputs:
%
%         conj(sqrt(conj(-1 - [0; 1]*j))) =      0 + 1.0000i,    sqrte(-1 - [0; 1]*j) =      0 - 1.0000i
%                                           0.4551 - 1.0987i                            0.4551 - 1.0987i
%         but
%
%         conj(sqrt(conj(-1 + 0*j))) = 0 - 1.000i,               sqrte(-1 + 0*j) = 0 - 1.000i

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function y = sqrte(z)

if nargin==0, help sqrte; return; end

y = sqrt(z);

i = find(imag(z)==0 & real(z)<0);

y(i) = -j * sqrt(abs(z(i)));

