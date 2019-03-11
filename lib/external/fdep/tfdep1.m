%TFDEP1		FDEP test function
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
function	tfdep1

		import	java.io.*;

% put your favorite function below
		eastat;
		epar;
		foofoo;		% dummy function -> variable
% put your favorite function above
		sub_tfdep1;	% subfunction
		funh=@(x)...	% function handle
			2*cos(x)+tan(x);
		fun_nested_1
	function	fun_nested_1
			cos;
			funh(pi);
	end
		funh(2*pi);
		sin;		% ML built-in
		unique;		% ML function
		evalin;		% call to EVAL...
		evalc('');	% call to EVAL...
		d=File;		% JAVA class
		struct(d);
		tfdep2;		% call test function 2
		tfdep1;		% recursion
		end
%--------------------------------------------------------------------------------
function	sub_tfdep1
		disp;
		fieldnames;
		end
%--------------------------------------------------------------------------------
function	sub_tfdep2	%#ok
		end
function	sub_tfdep3	%#ok
		end
function	sub_tfdep4	%#ok
		end
function	sub_tfdep5	%#ok
		end
%--------------------------------------------------------------------------------