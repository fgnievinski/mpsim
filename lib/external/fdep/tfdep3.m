%TFDEP3		FDEP test function
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

%--------------------------------------------------------------------------------
function	r=tfdep3(varargin)

% 1)	alpha
%	- is a ML stock function
%		MLROOT\toolbox\matlab\graph3d\alpha.m
%	- is NOT initialized in TFDEP3
%	> will cause an error if used in this context
	try
		r(1)=exp(alpha);
	catch						%#ok pre-2008a
		disp('TFDEP3> error using <alpha>');
		disp(sprintf('%s\n',lasterr));		%#ok pre-2008a
	end

% 2)	beta
%	- is a ML stock function
%		MLROOT\toolbox\matlab\specfun\beta.m
%	- is initialized in TFDEP3
%	> will NOT cause an error
		beta=1;
		r(2)=exp(beta);

% 3)	FOO_GOO_HOO_XXX
%	- is NOT a function (at least in this ML setup!)
%	- is NOT initialized
%	> will cause an error
	try
		r(3)=exp(FOO_GOO_HOO_XXX);
	catch						%#ok pre-2008a
		disp('TFDEP3> error using <FOO_GOO_HOO_XXX>');
		disp(sprintf('%s',lasterr));		%#ok pre-2008a
	end

% 4)	eval assigns a variable MYVAR during runtime
%	- is NOT a function (at least in this ML setup!)
%	- is initialized in an EVAL statement
%	> will NOT cause an error
	com='MYVAR=0';
	s=evalc(com);					%#ok DANGEROUS
	r(3)=sind(MYVAR);
end