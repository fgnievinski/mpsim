%TFDEP4		FDEP test function
%		this function must no be used
%		it contains raw function calls only
%
%SYNTAX
%		do not run
%
%EXAMPLE
%		do not run

% created:
%	us	01-Mar-2007
% modified:
%	us	21-Jun-2010 02:16:53

%	TFDEP4.M
%	is pcoded and the p-file is also copied to a standalone p-file
%	PFDEP4.P
%--------------------------------------------------------------------------------
function	tfdep4(varargin)

%	a private function
	try
		r=setoptn;				%#ok
	catch						%#ok pre-2008a
		disp('function <setoptn> not available');
	end
	if	~nargin
		eval('pi;');
		tfdep4(1);				% M>P-FILE recursion
		pfdep4(2);				%   P-FILE recursion
	end
end