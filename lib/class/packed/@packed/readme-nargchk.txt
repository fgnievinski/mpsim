For an overloaded function,
declared without varargin and without varargout,
with one input parameter and one output parameter,
we don't need to check the number of parameters because:
- if the # of input params is smaller than 1 that overloaded function is not called;
- if the # of input params is greater than 1 Matlab already checks and issues an error;
- if the # of output params is smaller than 1 the return value is set to the system's variable 'ans';
- if the # of output params is greater than 1 Matlab already checks and issues an error.

For an example, please see issym.m