%FDEP	to show a function's dependencies
%
%	FDEP dissects a MATLAB (ML) file and iteratively looks for
%	all user defined functions (modules), which are used
%	during runtime
%
%	FDEP retrieves for each module the exacty syntax of its
%		- main function
%		- subfunctions
%		- nested functions
%		- anonymous functions
%		- eval class calls
%		- unresolved calls
%	   and all
%		- ML stock functions
%		- ML built-in functions
%		- ML classes
%		- ML toolboxes
%	   that it uses
%
%	runtime options and returned macros create user-friendly,
%	comprehensible, and interactive GUIs, which
%		- list the results in various panels
%		- plot a full dependency matrix
%
%	in essence, FDEP is a wrapper for DEPFUN and MLINT;
%	however, due to an efficient pruning engine
%	it is considerably faster
%
%	see also: depfun, depdir, ckdepfun, mlint, which
%		  and the accompanying HTML file
%
%SYNTAX
%-------------------------------------------------------------------------------
%		P = FDEP(FNAM);
%		P = FDEP(FNAM,OPT1,OPT2,...);
%
%INPUT
%-------------------------------------------------------------------------------
% FNAM	:	M-file (function or script) or P-file
%		- only ML entities can be extracted from
%		  standalone P-files, which do NOT have a
%		  corresponding M-file
%
% OPT	:	description
% --------------------------------------------
% -q	:	do NOT show runtime processing
% -l	:	show module list
% -m	:	show dependency matrix
%
%OUTPUT
%-------------------------------------------------------------------------------
% P		a structure, which returns all information from the lex parser;
%		fields, which are of common interest, are these macros
%
% P.macro()		call macro with default args
% P.macro(arg,...)	call macro with arguments arg1,...
%
%		arg	description
%		--------------------------------------------------------
%  .help	()	show help for the listing panels in a window
%		1	- show help in the command window
%  .list	()	create the GUI that lists the results
%		M	- activate module M
%  .find	M1,...	show the synopsis of modules M1,...
%  .get		M1,...	retrieve all data of modules M1,...
%  .mhelp	M1,...	show all data of module M1,... in a window
%  .mplot	()	create the GUI that shows the dependency matrix
%		N1,...	- show nodes N1,...
%			  numeric input syntax ([M#column/M#row],...)
%			  only valid nodes are shown with guiding lines
%  .tplot	()	show the runtime and modules tree in a window
%
%		Mx	may be numeric or the name of an existing module
%			or cells with any combination of the above
%
%		for more help, see the accompanying HTML file
%
%EXAMPLE
%-------------------------------------------------------------------------------
%		p=fdep('myfile');
%		p.list();	% show module list
%		p.mplot();	% show dependency matrix
%		p.find(2);	% show summary of module #2
%		p.mhelp(3,'m');	% show synopsis of modules #3 and 'm'
%		d=p.get('n');	% retrieve data of module <n>

% for software developers
%
%		mn=2;				% module number
% access module data
%		p.fun(mn)			% module name
%		p.fun(p.mix{mn})		% calls	TO
%		p.fun(p.cix{mn})		% calls	FROM
% access ML data
%		fn=1				% stock	function group
%		p.mlfun{fn}(p.mlix{sn,fn})

%{
	TEST	r2007a
		[z{1:8,1}]=depfun(p.module(v),'-toponly','-quiet');
		z{1}
		mlint(p.module(v),'-a','-calls')
%}


% created:
%	us	07-Mar-2006
% modified:
%	us	21-Jun-2010 02:16:53	/ FEX R2008a

%-------------------------------------------------------------------------------
function	po=fdep(varargin)

		magic='FDEP';
		ver='21-Jun-2010 02:16:53';
		dopt={
			'-toponly'
			'-quiet'
		};
		mopt={
			'-m3'
			'-calls'
		};

	if	nargout
		po=[];
	end
	if	~nargin
	if	nargout
		po=FDEP_ini_engine(ver,magic,dopt,mopt,varargin{:});
		return;
	else
		help(mfilename);
		clear po;
	end
		return;
	end

		[p,par]=FDEP_ini_engine(ver,magic,dopt,mopt,varargin{:});
	if	isempty(par)
		return;
	end

		tim=clock;
		[p,par]=FDEP_get_dep(p,par,p.fun{1});
		p.runtime(1)=etime(clock,tim);

		tim=clock;
		[p,par]=FDEP_end_engine(p,par);
		p.runtime(2)=etime(clock,tim);

% needed to make sure all macros contain the latest parameters!
		tim=clock;
		p=FDEP_flib(magic,p,2);
	if	par.opt.lflg
		p=p.list();
		p=FDEP_flib(magic,p,1);			% needed!
	end
	if	par.opt.mflg
		p=p.mplot();
		p=FDEP_flib(magic,p,1);			% needed
	end

		p.runtime(3)=etime(clock,tim);
% no user-defined dependencies
	if	~p.ncall				&&...
		~par.opt.qflg
		disp(sprintf('\n-------------  NO USER-DEFINED DEPENDENCIES FOUND'));
		r=FDEP_dfind(p.magic,p,false,1);
		disp(char(r.rm));
	elseif	~par.opt.qflg
		ntbx=numel(p.toolbox);
		disp(sprintf('\n%9s: %-1d','toolboxes',ntbx));
	for	i=1:ntbx
		disp(sprintf('%9s: %-1d   %s',' ',i,p.toolbox{i}));
	end
	end

	if	nargout
		po=p;
	end
end
%-------------------------------------------------------------------------------
function	[p,par]=FDEP_ini_engine(ver,magic,dopt,mopt,varargin)

% retrieve current FARG parameter templates
		fap=farg;

		F=false;
		T=true;
		p=[];
		par=[];

% create output structure
		p.magic=magic;
		p.([magic,'ver'])=ver;
		p.([fap.magic,'ver'])=fap.([fap.magic,'ver']);
		p.MLver=version;
		p.section_10='---------- ENGINE  ------------';
		p.rundate=datestr(clock);
		p.runtime=[0,0,0];
		p.par=[];
		p.section_20='---------- INPUT   ------------';
		p.afile={};
		p.file='';
		p.section_30='---------- OUTPUT  ------------';
		p.ncall=0;
		p.nfun=0;
		p.module={};
		p.fun={};
		p.froot={};
		p.sub={};
		p.mix={};				% calls    to
		p.cix={};				% called   from
		p.mlix={};				% system   calls
		p.tix=[];				% function type
		p.depth=[0,0];
		p.nmlcall=zeros(1,6);
		p.mlfun={};
		p.toolbox={};
		p.modbix={};
		p.modbox=[];
		p.tree={};
		p.rtree={};
		p.caller={};
		p.mat=int8([]);
		p.section_31='---------- macros   -----------';
		p.lib=[];
		p.help=[];
		p.get=[];
		p.find=[];
		p.list=[];
		p.mhelp=[];
		p.mplot=[];
		p.tplot=[];
		p.smod=[];
	if	isempty(varargin)
		return;
	end

% output parameters
% - description	.TIX				0	1
%----------------------------------------------------------------
	desc.t={
		0	'C'	'caller		no	yes'
		1	'R'	'recursive	no	yes'
		2	'E'	'evals		no	yes'
		3	'S'	'type		script	function'	
		4	'F'	'type		M-file	P-file'
	};

% - description .SUB().n
%------------------------------------------------------------
	desc.s={
		1	'U'	'functions outside the scope'
		2	'S'	'subfunctions'
		3	'N'	'nested functions'
		4	'A'	'anonymous functions'
		5	'UD'	'user defined functions'
		6	'MS'	'ML stock functions'
		7	'MB'	'ML built-in functions'
		8	'CE'	'calls to eval..'
		9	'MC'	'ML classes'
		10	'OC'	'other classes'
		11	'TB'	'ML tbx'
		12	'X'	'unresolved calls'
	};
%
% - description .CALL{x,n}
%-------------------------------------------------------
	desc.c={
		1	'UD'	'user defined functions'
		2	'MS'	'ML stock functions'
		3	'MB'	'ML built-in functions'
		4	'MC'	'ML classes'
		5	'OC'	'other classes'
		6	'TB'	'ML tbx'
	};

% start engine

% - check file name

	if	~ischar(varargin{1})
		disp(sprintf('%s> input not a string: class <%s>',magic,class(varargin{1})));
		return;
	end
		fnam=varargin{1};

% - select file name
%   this is NOT as trivial as it seems...

		[fpat,frot,fext]=fileparts(fnam);	%#ok
	if	isempty(fext)
		fext='.m';
	end

		afnam=which(fnam,'-all');
	if	isempty(afnam)
		disp(sprintf('%s> file not found or not a valid MATLAB file <%s>',magic,varargin{1}));
		return;
	end

		[apat,arot,aext]=cellfun(@fileparts,afnam,'uni',false);	%#ok
		ix=	strcmp(arot,frot)		&...
			strcmp(aext,fext);
	if	~any(ix)
		disp(sprintf('%s> file not valid <%s>',magic,varargin{1}));
		disp(sprintf('%s> files %8d\n',magic,numel(afnam)));
		disp(char(afnam));
		return;
	else
		fnam=afnam{find(ix,1,'first')};
	end

	if	~exist(fnam,'file')
		disp(sprintf('%s> file not found <%s> = %s',magic,varargin{1},fnam));
		return;
	end

% - simple option parser
		opt.qflg=false;
		opt.lflg=false;
		opt.mflg=false;
		opt.dflg=false;				% hidden flag
	if	nargin > 4
	for	i=1:numel(varargin)
	switch	varargin{i}
	case	'-q'
		opt.qflg=true;
	case	'-l'
		opt.lflg=true;
	case	'-m'
		opt.mflg=true;
	case	'-d'
		opt.dflg=true;
	end
	end
	end

		par.farg=fap;
		par.opt=[];
		par.desc=[];
		par.enum=[];
% - macros
		par.macro.sr=@(t) strrep(t,'\','/');
		par.macro.range=@(x) max(x)-min(x);	% replacement for <stats tbx>

% - engine parameters
		[fpat,frot]=fileparts(fnam);
		fnam=par.macro.sr(fnam);

		par.mlroot=[matlabroot,filesep,'toolbox'];
		par.opt=opt;
		par.dopt=dopt;
		par.mopt=mopt;
		par.x=0;				% loop counter
		par.xx=1;				% entry
		par.c=0;				% depth
		par.e=0;
		par.fix=[];
		par.ac={sprintf('%-4d: * %s',0,frot)};
		par.am={fnam};
		par.nn=12;
		par.nc=6;
		par.call=cell(1,6);

% - templates
		par.rexcls='^\w';			% module class
		par.rexmod='\w+$';			% module
		par.rexmod='(\w+$)|(\d+$)';
		par.rextbx='\w+';			% find toolboxes
		par.rexmbi='(?<=\().+(?=\))';		% full path to built-in
		par.rexscr='(?<=\\)\w+(?=\.[mp]$)';	% file roots

		par.spec=[0,0,0,0];
		par.dspec='RESP';

		par.fdes={'FUNCTION','SCRIPT'};
		par.rdes={'no','yes','not known'};
		par.edes={'not used','used','not known'};

%   unique program id for the module manager
		par.tagpid=sprintf('%s.%s.module.',magic,num2hex(rand));
		par.tagid={
			'PIDhelp      > '
			'PIDlist      > '
			'PIDmatrix    > '
			'PIDsynopsis  > '
			'PIDmanager   > '
			'PIDtree      > '
		};
		par.tagid=strrep(par.tagid,'PID',par.tagpid);
		par.tag={
			@(varargin) sprintf('%s%s',par.tagid{1,1},varargin{1})
			@(varargin) sprintf('%s%s',par.tagid{2,1},varargin{1})
			@(varargin) sprintf('%s%s',par.tagid{3,1},varargin{1})
			@(varargin) sprintf('%s%s',par.tagid{4,1},varargin{1})
			@(varargin) sprintf('%s%s',par.tagid{5,1},varargin{1})
			@(varargin) sprintf('%s%s',par.tagid{6,1},varargin{1})
		};

		par.ixbi=5;				% MLINT calls
		par.ixsub={...
%		call M-file (ML)
			'C',{2,T,	'ML   M  %s'}
%		built-in
			'B',{5,F,	'        built-in'}
%		call P-file (ML)
			'P',{6,T,	'ML   P  %s'}
%		call P-file (user)
			'D',{7,T,	'CALL P  %s'}
%		recursion
			'R',{-1,F,	'------  RECURSION'}
%		call M-file (user)
			'M',{-5,T,	'CALL M  %s'}
%		subfunction
			'S',{-100,F,	'------  SUBFUNCTION'}
%		nested
			'N',{-101,F,	'------  NESTED FUNCTION'}
%		anonymous
			'A',{-102,F,	'------  ANONYMOUS FUNCTION'}
%		f/eval...
			'E',{-400,F,	'------  EVAL'}
%		unresolved
			'X',{-500,F,	'--**--  NOT FOUND'}
		}.';

%   descriptor: module
		par.mtag={
			'@@@UNRESOLVED@@@'
			'@@@TOOLBOX@@@'
		};

		par.mktxtm=@(a,b,ix) {
		sprintf('M-FILE       : %s',a.sub(ix).M)
		sprintf('P-FILE       : %s',a.sub(ix).P)
		sprintf('MODULE  #%4d: %s',ix,a.module{ix})
		sprintf('type         : %s',b.fdes{a.tix(ix,4)+1})
		sprintf('created      : %s',b.date)
		sprintf('size         : %-1d bytes',b.size)
		sprintf('lines        : %-1d',a.sub(ix).l)
		sprintf('comments     : %-1d',a.sub(ix).cl)
		sprintf('empty        : %-1d',a.sub(ix).el)
		sprintf('recursive    : %s',b.rdes{a.tix(ix,2)+1})
		sprintf('f/eval..     : %s',b.edes{a.tix(ix,3)+2*max([0,(a.tix(ix,5)-a.sub(ix).mp(1))])+1})
		sprintf('unresolved   : %s',b.rdes{double(a.sub(ix).n(b.enum.s.X)~=0)+isinf(a.sub(ix).n(b.enum.s.X))+1});
		sprintf('calls    TO  : %5d  user defined',numel(a.mix{ix}))
		sprintf('called   FROM: %5d  user defined',numel(a.cix{ix}))
		sprintf('calls in FILE: %5d              ',a.sub(ix).n(b.enum.s.U))
		sprintf('subfunctions : %5d  inside  file',a.sub(ix).n(b.enum.s.S))
		sprintf('nested       : %5d              ',a.sub(ix).n(b.enum.s.N))
		sprintf('anonymous    : %5d              ',a.sub(ix).n(b.enum.s.A))
		sprintf('f/eval..     : %5d              ',a.sub(ix).n(b.enum.s.CE))
		sprintf('unresolved   : %5d              ',~isinf(a.sub(ix).n(b.enum.s.X))*a.sub(ix).n(b.enum.s.X));
		par.mtag{1,1}
		sprintf('ML      stock: %5d              ',numel(a.mlix{ix,1}))
		sprintf('ML  built-ins: %5d              ',numel(a.mlix{ix,2}))
		sprintf('ML    classes: %5d              ',numel(a.mlix{ix,3}))
		sprintf('OTHER classes: %5d              ',numel(a.mlix{ix,4}))
		sprintf('ML  toolboxes: %5d              ',numel(a.mlix{ix,5}))
		par.mtag{2,1}
		};

%   descriptor: main program
		par.mktxtf=@(a,b,ix) {
		sprintf('ROOT         : %s',a.module{1})
		sprintf('type         : %s',b.fdes{a.tix(1,4)+1})
		sprintf('recursive    : %s',b.rdes{a.tix(1,2)+1})
		sprintf('f/eval..     : %s',b.edes{a.tix(1,3)+2*max([0,(a.tix(1,5)-a.sub(1).mp(1))])+1})
		sprintf('FDEP  version: %s',a.FDEPver);
		sprintf('ML    version: %s',a.MLver)
		sprintf('ML      stock: %5d',a.nmlcall(1))
		sprintf('ML  built-ins: %5d',a.nmlcall(2))
		sprintf('ML    classes: %5d',a.nmlcall(3))
		sprintf('OTHER classes: %5d',a.nmlcall(4))
		sprintf('ML  toolboxes: %5d',numel(a.mlfun{5}))
		sprintf('runtime      : %10.4f sec',sum(a.runtime(1)));
		};

%   MLINT templates
		par.ftmpl='M0';
		par.stmpl={
			'U'	3	F	@(x) regexp(x,par.rexmod,'match')
			'S'	3	T	@(x) regexp(x,par.rexmod,'match')
			'N'	3	T	@(x) regexp(x,par.rexmod,'match')
			'A'	[1,4]	T	''
			'E'	0	F	''
		};
		par.stmplf=fap.par.stmplf;	% latest FARG
		par.stmpla.M=[];
		par.stmpla.P=[];
		par.stmpla.mp=[];
		par.stmpla.l=0;
		par.stmpla.cl=0;
		par.stmpla.el=0;
		par.stmpla.nn=par.nn;
		par.stmpla.des={};
		par.stmpla.n=[];
	for	i=1:size(par.stmpl,1)
		fn=par.stmpl{i,1};
		par.stmpla.(fn)=par.stmplf{i,2};
	end

%   DEPFUN templates
		par.mlfield={
			'MLfunction'
			'MLbuiltin'
			'MLclass'
			'OTHERclass'
			'MLtoolbox'
			'MLtoolbox'			% KEEP THIS!
		};

%   link templates
		par.sn={
%			fieldname	cell	sort
			'module'	F	F
			'fun'		F	F
			'sub'		F	F
			'mix'		T	T
			'cix'		T	T
			'mlix'		F	F
			'tix'		F	F
			'depth'		F	F
		};

		par.ixsub=struct(par.ixsub{:});
		par.call(1,1)={par.macro.sr(fnam)};

% - graphics
%{
	original color scheme
		par.mcol=[.75,1,1];			% color: modules
		par.fcol=[1,1,.75];			% color: module
		par.pcol=[.85,1,.85];			% color: main pg
%}
%	john d'errico adjustment
		par.mcol=[.85,1,1];			% color: modules
		par.fcol=[1,1,.85];			% color: module
		par.pcol=[.95,1,.95];			% color: main pg
		par.tcol=[0,0,1];			% color: text
		par.rcol=[1,.95,.95];			% color: tree

		ss=get(0,'screensize');
		par.lwin=[.3*ss(3),100,.7*ss(3)-20,ss(4)-160];
		par.hwin=[10,50,.5*ss(3)-20,ss(4)-80];

% output structure
		p.afile=afnam;
		p.file=fnam;

% user defined functions
		p.module={frot};
		p.fun={fnam};
		p.froot={[fpat,filesep,frot]};
		p.sub=par.stmpla;

% descriptors/enumerators
		fn=fieldnames(desc);
	for	i=1:numel(fn)
		cf=fn{i};
		par.desc.(cf)=desc.(cf);
		par.enum.(cf)=desc.(cf)(:,[2,1]).';
		par.enum.(cf)=struct(par.enum.(cf){:});
	end
end
%-------------------------------------------------------------------------------
function	[p,par]=FDEP_end_engine(p,par)

% stop engine
		p.nfun=numel(p.fun);
		p.par=par;

	for	i=1:p.nfun
		p.fun=par.macro.sr(p.fun);
		p.froot=par.macro.sr(p.froot);
	end

		ml=max(cellfun('length',par.ac));
		cm=[num2cell(1:numel(par.ac));par.ac.';par.am.'];
		fmt=sprintf('%%-4d %%-%ds -> %%s\n',ml+2);
		p.tree=sprintf(fmt,cm{:});
		p.tree=strread(p.tree,'%s','delimiter','','whitespace','');

		txt=sprintf('%-9.9s: > %s','ROOT',p.file);
		p.rtree=[[{txt},{''}];p.rtree];

		p.rtree=[char(p.rtree(:,1)),repmat('   ',size(p.rtree,1),1),char(p.rtree(:,2))];
	
		t=strrep(p.mlfun{1},par.macro.sr([matlabroot,filesep,'toolbox',filesep]),'');
		p.mlfun{5}=unique(regexp(t,par.rextbx,'match','once'));
		ntbx=numel(p.mlfun{5});
		tf=true(ntbx,1);
		tnam=cell(ntbx,1);
	for	i=1:ntbx
		tver=ver(p.mlfun{5}{i});
	if	~isempty(tver)
		tnam{i}=sprintf('%s (%s) [%s]',tver.Name,tver.Version,p.mlfun{5}{i});
	else
		tf(i)=false;
	end
	end
		p.mlfun{5}=p.mlfun{5}(tf);
	if	any(tf)
		p.mlfun{6}=tnam(tf);
		p.toolbox=tnam(tf);
	else
		p.mlfun{6}={};
		p.toolbox=[];
	end

		p.cix=cell(p.nfun,1);
		p.mlix=cell(p.nfun,6);

	for	i=1:p.nfun
		ix=ismember(p.fun,par.call{i,1});
		ix=par.fix(ix);
		p.mix{i,1}=ix.';
		p.cix(ix,1)=cellfun(@(x) [x,i],p.cix(ix,1),'uni',false);
	for	j=1:5
		ix=ismember(p.mlfun{j},par.call{i,j+1});
		p.mlix{i,j}=find(ix);
		p.nmlcall(j)=numel(ix);
	end
		p.mlix{i,j+1}=p.mlix{i,j};
		p.nmlcall(j+1)=p.nmlcall(j);
	end
		p=FDEP_fsort(p,par);
		p=FDEP_cmp_depmat(p);
		p=FDEP_parse_modules(p,par);
		p=FDEP_get_modtbx(p);
end
%-------------------------------------------------------------------------------
function	p=FDEP_flib(magic,p,nr)

% assign FDEP functions
% - do NOT change this tedious assingment!
% - requires a lot of time!
	for	i=1:nr
		p.lib=@()		FDEP_flib(magic,p,2);
		p.help=@(varargin)	FDEP_manager([],[],mfilename,p,'p',varargin{:});
		p.get=@(varargin)	FDEP_dget(magic,p,varargin{:});
		p.find=@(varargin)	FDEP_dfind(magic,p,true,varargin{:});
		p.list=@(varargin)	FDEP_dlist(magic,p,varargin{:});
		p.mhelp=@(varargin)	FDEP_mlist(magic,p,varargin{:});
		p.mplot=@(varargin)	FDEP_dplot(magic,p,varargin{:});
		p.tplot=@(varargin)	FDEP_rtree(magic,p,varargin{:});
	if	~isfield(p,'smod')
		p.smod=[];
	end
	end
end
%-------------------------------------------------------------------------------
function	[p,par]=FDEP_get_dep(p,par,fnam)

		par.x=par.x+1;
		par.c=par.c+1;

		fnam=which(fnam);
		[fpat,frot]=fileparts(fnam);		%#ok

		[p,par,dtmp,dmlf,dmod,dmcl,docl]=FDEP_get_fun(p,par,fnam,frot);
		wtmp=dtmp;

		mltbx=strrep(dmlf,[matlabroot,filesep,'toolbox',filesep],'');
		mltbx=unique(regexp(mltbx,par.rextbx,'match','once'));
		par.call(par.xx,:)={
			par.macro.sr(dtmp(2:end))
			par.macro.sr(dmlf)
			par.macro.sr(dmod)
			par.macro.sr(dmcl)
			par.macro.sr(docl)
			par.macro.sr(mltbx)
		};

	if	par.x > 1
		p.mlfun={
			unique([p.mlfun{1};par.call{par.xx,2}])
			unique([p.mlfun{2};par.call{par.xx,3}])
			unique([p.mlfun{3};par.call{par.xx,4}])
			unique([p.mlfun{4};par.call{par.xx,5}])
			unique([p.mlfun{5};par.call{par.xx,6}])
			unique([p.mlfun{5};par.call{par.xx,6}])
		};
	else
		p.mlfun=par.call(1,2:end).';
	end

		tmpd=cellfun(@(x) x(1:find(x=='.',1,'last')-1),...
			dtmp,...
			'uni',false);
		ix=ismember(tmpd,p.froot);
		dtmp(ix)=[];
		ndtmp=numel(dtmp)-1;
		p.ncall=p.ncall+ndtmp+1;

	if	numel(dtmp) < 2
		m={'()'};
	else
		m=dtmp(2:end);
	end
		c=repmat({
			sprintf('%-4d: %s| %s',...
				par.x,repmat(' ',1,2*(par.c-1)),frot)
			},...
			numel(m),1);
		par.ac=[par.ac;c];
		par.am=[par.am;m];

		p.tix(par.x,:)=[1,par.spec];
	if	~numel(dtmp)
		ix=ismember(p.fun,wtmp(2:end));
		ofix='';
		p.tix(par.x,1)=0;
	if	any(ix)
		p.tix(par.x,1)=1;
		ofix=par.fix(ix);
		ofix=sprintf('%-1d ',ofix);
		ofix(end)='';
	end
		fnum=numel(find(ix));
		[p,par]=FDEP_show_entry(p,par,frot,fnum,ofix);
	else

		keep=par.c;
		par.e=keep;
	for	i=1:numel(dtmp)
		[dpat,drot]=fileparts(dtmp{i});
		tmpd=[dpat,filesep,drot];
		ix=ismember(tmpd,p.froot);
	if	~any(ix)
		p.fun=[p.fun;dtmp{i}];
		p.froot=[p.froot;{tmpd}];
		p.module=[p.module;{drot}];
	if	i == 1
		[p,par]=FDEP_show_entry(p,par,frot,1,dtmp{i});
	end
		[p,par]=FDEP_get_dep(p,par,dtmp{i});
	end
		par.e=keep;

	end
	end
		par.c=par.c-1;
end
%-------------------------------------------------------------------------------
function	[p,par,dtmp,dmlf,dmod,dmcl,docl]=FDEP_get_fun(p,par,fnam,frot)

% DEPFUN	arg	description		FDEP		r2008a
%		------------------------------------
%		1	trace list		dtmp
%		2	built-in list		dmod
%		3	ML classes		dmcl
%		4	problem list		n/u
%		5	not used		n/u
%		6	eval strings		n/u
%		7	called from list	docx
%		8	other classes		docl

		[dtmp,dmod,dmcl,docx,docx,docx,docx,docl]=depfun(fnam,par.dopt{:});	%#ok
		im=strncmp(par.mlroot,dtmp,numel(par.mlroot));
		dmlf=dtmp(im);
		dtmp(im)=[];

% FARG
% - resolve calls inside the function file

		[fa,fap]=farg(fnam,'-s','-d');

		senum=par.enum.s;
		tenum=par.enum.t;
							% tix : CRESP
		par.spec=[0,0,0,0];			% spec:  RESP

		dtmp{1}=fap.wnam;
	if	fap.mp(1)
		p.fun{end}=fap.wnam;
		dtmp{1}=fap.wnam;
	elseif	fap.mp(2)
		p.fun{end}=fap.pnam;
		dtmp{1}=fap.pnam;
	else
		p.fun{end}=fap.wnam;
	end
		fap.U=fap.UU;				% reset to ALL U

		ex=cellfun(@exist,fap.U.fn);
		dmod=unique([dmod;fap.U.fn(ex==par.ixbi)]);
		par.spec(tenum.F)=+fap.mp(2);		% spec: M/P

		sub=par.stmpla;
		sub.M=par.macro.sr(fap.wnam);		% - M-file name
		sub.P=par.macro.sr(fap.pnam);		% - P-file name
		sub.mp=fap.mp;				% - M/P indicator
		sub.l=fap.par.nlen;			% - #lines
		sub.cl=fap.par.ncom;			% - #comments
		sub.el=fap.par.nemp;			% - #empty lines
		sub.des=par.desc.s(:,2).';		% - index descriptors
		sub.n=zeros(1,sub.nn);
		sub.n(1,size(par.stmpl,1):end)=...
			[numel(dtmp)-1,numel(im),numel(dmod),0,numel(dmcl),numel(docl),0,0];

		sub.E.fn={};
		sub.E.bx=fap;
		sub.E.ex=ex;

	if	isempty(fa)
	if	fap.par.mp(2)
		sub.l=nan;
		sub.n([senum.U,senum.CE])=nan;		% - no MAIN
		sub.n(senum.X)=inf;
	end
	if	~isempty(docx{1})
		par.spec(tenum.R)=1;			% spec: R
	end
		p.sub(par.xx,1)=sub;
		return;
	end
		sub.n(senum.U:senum.A)=fap.n([6,2:4]);

	if	~fap.par.nlen
		par.spec(tenum.S)=1;			% spec: S
		dmlf={};
		dmod={};
		dmcl={};
		docl={};
		p.sub(par.xx,1)=sub;
		return;
	end

	for	i=1:size(par.stmpl,1)
	if	par.stmpl{i,2}
		fn=par.stmpl{i,1};
		sub.(fn)=fap.(fn);
	end
	end
		sub.S.fn=fap.sub;
	if	fap.M.nx
		sub.S.fd=[fap.M.fn;fap.S.fn];
		sub.n(senum.S)=sub.n(senum.S)+1;
		sub.S.nx=sub.S.nx+1;
		sub.S.bx=[fap.M.bx,sub.S.bx];
	end

		c=fap.par.call;
		sx=strmatch(par.stmpl{1,1},c);
		c=c(sx);
		f=regexp(c,par.rexmod,'match');
		f=[f{:}].';
		sub.E.fn=f;
		sub.n(senum.X)=0;
		sub.E.bx=fap;
		sub.E.ex=ex;

% script
	if	~fap.par.mfun
		par.spec(tenum.S)=1;			% spec: S
		f=[frot;f];
		m=regexp(dtmp,par.rexscr,'match');
		m=[m{:}].';
		is=ismember(m,f);
		dtmp=dtmp(is);
	end

		[sub,par]=FDEP_parse_calls(frot,sub,par);
		p.sub(par.xx,1)=sub;
end
%-------------------------------------------------------------------------------
function	[sub,par]=FDEP_parse_calls(module,sub,par)
% resolve calls
% - subroutines

		f=sub.E.fn;
		ex=sub.E.ex;
		fap=sub.E.bx;
		senum=par.enum.s;
		tenum=par.enum.t;

% f/eval..
		ir=	strncmp('eval',fap.par.ltok(:,2),4)	|...
			strncmp('feval',fap.par.ltok(:,2),5);
	if	any(ir)
		par.spec(tenum.E)=1;			% spec: E
		sub.n(senum.CE)=numel(find(ir));
		ir=	strncmp('eval',fap.U.fn,4)	|...
			strncmp('evalc',fap.U.fn,5)	|...
			strncmp('evalin',fap.U.fn,6)	|...
			strncmp('feval',fap.U.fn,5);
		ex(ir)=par.ixsub(1).E;
	end

% resolved
		fu=sub.U.fn;
	if	sub.n(senum.S)
		ir=ismember(fu,sub.S.fd);
		ex(ir)=par.ixsub(1).S;
	end
	if	sub.n(senum.N)
		ir=ismember(fu,sub.N.fn);
		ex(ir)=par.ixsub(1).N;
	end

% unresolved
		fx=find(ex==0);
		sub.E.fn=fap.U.fn(~ex);
		ns=numel(sub.S.fd);
		ne=numel(sub.E.fn);
	if	all([ns,ne])				&&...
		any(fx)

		fu=sub.E.fn;
	if	sub.n(senum.S)
		ir=ismember(fu,sub.S.fd);
		ex(fx(ir))=par.ixsub(1).S;
	end
	if	sub.n(senum.N)
		ir=ismember(fu,sub.N.fn);
		ex(fx(ir))=par.ixsub(1).N;
	end

	end

% recursion
		ir=strcmp(module,f);
	if	any(ir)
		par.spec(1)=1;				% spec: R
		ex(ir)=par.ixsub(1).R;
	end

		sub.n(senum.X)=sum(~ex);
		sub.E.fn=fap.U.fn(~ex);
		ex(~ex)=par.ixsub(1).X;
		sub.E.ex=ex;
	if	sub.U.nx
		sub.E.bx=sub.U.bx(1,ex==par.ixsub(1).X);
	else
		sub.E.bx=[];
	end
end
%-------------------------------------------------------------------------------
function	[p,par]=FDEP_parse_modules(p,par)

% resolve calls
% - external modules

		p.fun=par.macro.sr(p.fun);
		p.froot=par.macro.sr(p.froot);

	for	i=1:p.nfun
		sub=p.sub(i,1);

	if	~isempty(sub.E.ex)

		ex=sub.E.ex;
		sub.U.fd=repmat({''},size(sub.U.fn));

% P-files
		ir=find(ex==par.ixsub(1).P);
	if	any(ir)
		sub.U.fd(ir)=cellfun(@(x) par.macro.sr(which(x)),...
			sub.U.fn(ir),...
			'uni',false);
		a=ismember(sub.U.fn(ir),p.module);
		ex(ir(a))=par.ixsub(1).D;
	end

% user-defined functions
		ir=find(ex==par.ixsub(1).C);
	if	any(ir)
		[a,b]=ismember(sub.U.fn(ir),p.module);
	if	any(a)
		sub.U.fd(ir(a))=p.fun(b(b>0));
		ex(ir(a))=par.ixsub(1).M;
	end

% ML stock functions
		ir=ir(~a);
	if	any(ir)
		sub.U.fd(ir)=cellfun(@(x) par.macro.sr(which(x)),...
			sub.U.fn(ir),...
			'uni',false);
	end
	end
		sub.E.ex=ex;
	end
		p.sub(i,1)=sub;
	end
end
%-------------------------------------------------------------------------------
function	p=FDEP_cmp_depmat(p)

		tix=(p.tix(:,1)~=0 | p.tix(:,2)~=0).';
		p.caller=p.module(tix);			% functions
		nc=(1:sum(tix)).';
		p.mat=zeros(p.nfun,'int8');
	for	i=1:p.nfun
		p.mat(p.mix{i},i)=1;
	if	p.tix(i,2)
		p.mat(i,i)=-1;
	end
	end
		p.mat(:,~tix)=[];
		p.mat=p.mat(:,nc);
end
%-------------------------------------------------------------------------------
function	[p,par]=FDEP_show_entry(p,par,frot,fnum,fnam)

		par.fix(par.xx,1)=par.xx;
		p.depth(par.xx,1)=par.e;
		p.depth(par.xx,2)=par.c;

		sp=repmat(' ',1,2*(par.c-1));
	if	par.e > 0				&&...
		par.e < par.c
		sp(2*(par.e)-1)='.';
	end
		spec=repmat(' ',1,numel(par.dspec));
		spec(par.spec~=0)=par.dspec(par.spec~=0);

		cc=sprintf('%-4d %-4d: %s| %s',...
			par.xx,par.c,...
			sp,...
			frot);
		cm=sprintf('%4.4s %-1d: %s',...
			spec,fnum,fnam);
		p.rtree(par.xx,:)={cc,cm};
		par.xx=par.xx+1;

	if	~par.opt.qflg
	if	par.xx == 2
		disp(sprintf('%-7.7s: > %s','ROOT',p.file));
	end
		disp([cc,sprintf('\t'),cm]);
	end
end
%-------------------------------------------------------------------------------
function	p=FDEP_fsort(p,par)

		ns=size(par.sn,1);
		[ix,ix]=sort(p.module(2:end));		%#ok
		ix=[1;ix+1];
		[is,is]=sort(ix);			%#ok
	for	i=1:ns
		fn=par.sn{i,1};
	if	par.sn{i,2}
	for	j=1:numel(p.(fn))
		p.(fn){j}=sort(is(p.(fn){j}).');
	end
	end
		p.(fn)=p.(fn)(ix,:);
	end

end
%-------------------------------------------------------------------------------
function	rm=FDEP_set_ent(p,cix,rm)

		io=strfind(rm{1},':');
		io=io(1);
% 		fmt=[repmat(' ',1,io-1),': %s'];
		fmt=[repmat(' ',1,io-1),': %+5d  %s'];

% ML toolboxes
		ix=find(strcmp(rm,p.par.mtag{2,1}));
		val=p.mlix{cix,end};
	if	~isempty(val)
		ne=numel(val);
		tmp=cell(ne,1);
		tbx=p.toolbox(val);
	for	i=1:ne
		tmp{i,1}=sprintf(fmt,i,tbx{i});
	end
		tmp=char(tmp);
		rm(ix)={tmp};
	else
		rm(ix)=[];
	end

% unresolved calls
		ix=find(strcmp(rm,p.par.mtag{1,1}));
		val=p.sub(cix).E.fn;
	if	~isempty(val)
		ne=numel(val);
		tmp=cell(ne,1);
	for	i=1:ne
		tmp{i,1}=sprintf(fmt,i,p.sub(cix).E.fn{i});
	end
		tmp=char(tmp);
		rm(ix)={tmp};
	else
		rm(ix)=[];
	end
end
%-------------------------------------------------------------------------------
function	p=FDEP_get_modtbx(p)

		mrk1='@#@#@#';
		mrk2='&#&#&#';

		nt=numel(p.toolbox);
		ix=false(p.nfun,nt);
		tbx=cell(nt,4);
		txt=cell(nt,1);
	for	i=1:nt
		ix(:,i)=cellfun(@(x) any(x==i),p.mlix(:,5));
		ixs=sum(ix(:,i));
		ixm=find(ix(:,i));
		tt=[{
			mrk1
			sprintf('%s',p.toolbox{i})
			mrk2
			}
			cellfun(@(x,y,z) sprintf('%6d/%6d:   %s',x,y,z),...
				num2cell(1:ixs).',...
				num2cell(ixm),...
				p.fun(ix(:,i)),'uni',false)
		];
		tbx(i,1)={p.toolbox(i)};
		tbx(i,2)={p.fun(ix(:,i))};
		tbx{i,3}=tt;
		tbx{i,4}=find(ix(:,i));
		txt{i,1}=tt;
	end

	if	nt
		txt=cat(1,txt{:});
		ml=max(cellfun(@numel,txt));
		txt=strrep(txt,mrk1,repmat('=',1,ml));
		txt=strrep(txt,mrk2,repmat('-',1,ml));
		p.modbix=tbx(:,end);
		p.modbox=txt;
	end
end
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
% OUTPUT utilities
%	- dget
%	- dfind
%	- dlist
%	- dplot
%	- mhelp
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
function	tf=FDEP_chkpar(magic,p)

		tf=false;
	if	isstruct(p)				&&...
		isfield(p,'magic')			&&...
		strmatch(magic,p.magic)
		tf=true;
		return;
	end
		disp(sprintf('%s> not a valid FDEP structure',magic));
end
%-------------------------------------------------------------------------------
function	r=FDEP_dget(magic,p,varargin)

		r=[];
	if	nargin < 3
		disp(sprintf('%s> usage: P.get(M1,...)',magic));
	if	~nargout
		clear r;
	end
		return;
	end

	if	isstruct(varargin{1})			&&...
		isfield(varargin{1},'ix')
		p=varargin{1};				% MHELP!
	else
		p=FDEP_dfind(magic,p,false,varargin{:});
	end

		senum=p.par.enum.s;

	if	~isempty(p.ix)
	for	i=1:numel(p.ix)
		ix=p.ix(i);
		tix=p.tix(ix,:);
		del=repmat('-',1,max([numel(p.fun{ix}),numel(p.file)]));

	if	~isempty(p.sub(ix).M)
		ac=p.sub(ix).U.fn;

% check unassigned calls
	if	~isnan(p.sub(ix).n(senum.U))			&&...
		p.sub(ix).n(senum.U)

		mu=max(cellfun(@numel,p.sub(ix).U.fn));
		fmt=sprintf('%%5d    %%-%d.%ds  >  %%s',mu,mu);
		ac=cell(p.sub(ix).n(senum.U),1);
		ex=p.sub(ix).E.ex;

		mod=p.par.ixsub(1);
		tfmt=p.par.ixsub(3);
		nf=fieldnames(p.par.ixsub);
	for	j=1:numel(nf)
		cf=nf{j};
		ir=ex==mod.(cf);
	if	any(ir)
		cu=p.sub(ix).U.fn(ir);			% module name
		cd=p.sub(ix).U.fd(ir);			% module file
		cb=num2cell(p.sub(ix).U.bx(1,ir)).';	% line

		g2=cellfun(@(a,b,c) sprintf(tfmt.(cf),a),...
			cd,...
			'uni',false);
		ac(ir)=cellfun(@(a,b,c) sprintf(fmt,a,b,c),...
			cb,cu,g2,...
			'uni',false);
	end
	end
	end

% ID
		rtmp.magic=[p.magic,'module'];
		rtmp.([magic,'ver'])=p.([magic,'ver']);
		rtmp.MLver=p.MLver;
		rtmp.rundate=p.rundate;
% module(s) content
		rtmp.MODULE_DESCRIPTION___________=del;
		rtmp.module=p.module{ix};
		rtmp.file=p.fun{ix};
		rtmp.parent=p.file;
		rtmp.index=ix;
		rtmp.type=p.par.fdes{tix(4)+1};
		rtmp.isscript=tix(4);
		rtmp.ispfile=isnan(p.sub(ix).l);
		rtmp.isrecursive=tix(2);
		rtmp.haseval=tix(3);
		rtmp.hasunresolved=~((double(p.sub(ix).n(senum.X)~=0)+isinf(p.sub(ix).n(senum.X))-1)~=0);
		rtmp.hascalls=numel(p.fun(p.mix{ix}));
		rtmp.iscalled=numel(p.fun(p.cix{ix}));
		rtmp.synopsis=p.rs{i};
		rtmp.MODULE_FUNCTIONS___________=del;
		rtmp.calls=ac;
		rtmp.subfunction=p.sub(ix).S.fn;
		rtmp.nested=p.sub(ix).N.fd;
		rtmp.anonymous=p.sub(ix).A.fd;
		rtmp.unresolved=p.sub(ix).E.fn;
		rtmp.callsTO=p.fun(p.mix{ix});
		rtmp.callsFROM=p.fun(p.cix{ix});
		rtmp.ML_FUNCTIONS___________=del;
	for	j=1:size(p.par.mlfield,1)
		fn=p.par.mlfield{j,1};
		rtmp.(fn)=p.mlfun{j}(p.mlix{ix,j});
	end
	if	i==1
		clear	r;
		r=rtmp;
		r(numel(p.ix))=rtmp;			% allocate
	else
		r(i)=rtmp;				%#ok
	end
	end
	end
	end

end
%-------------------------------------------------------------------------------
function	po=FDEP_dfind(magic,p,dflg,varargin)

	if	nargin < 3
		disp(sprintf('%s> usage: P.find(M1,...)',magic));
	if	~nargout
		clear p;
	end
		return;
	end
	if	~FDEP_chkpar(magic,p)
	if	nargout
		po=p;
	end
		return;
	end

		hdr='-------------';
		srch={
			'module'	true
			'fun'		false
		};

		ic=cellfun('isclass',varargin,'cell');
		narg=numel(varargin);
		nmod=sum(cellfun(@numel,varargin));

		p.ix=[];
		p.ry={};
		p.rm={};
		p.rf={};
		p.rs=cell(nmod,1);

		nm=0;
	for	i=1:narg
	if	ic(i)
		varg=varargin{i};
	else
		varg=varargin(i);
	end
		nvarg=numel(varg);

	for	j=1:nvarg
		ix=[];

		carg=varg{j};
	if	ischar(carg)
	for	k=1:size(srch,1)
		fn=srch{k,1};
	if	srch{k,2}
		ix=strmatch(carg,p.(fn),'exact');
	else
		ix=strmatch(carg,p.(fn));
	end
	if	~isempty(ix)
		break;
	end
	end

	elseif	isnumeric(carg)
		ix=carg(carg>0 & carg<=p.nfun);
	end

		p.ix=[p.ix;ix(:)];
	for	k=1:numel(ix)
		nm=nm+1;
		cix=ix(k);
	if	~isempty(cix)
		fdir=dir(p.fun{cix});
		p.par.date=fdir.date;
		p.par.size=fdir.bytes;
		rm=p.par.mktxtm(p,p.par,cix);
		p.ry=rm;
		rm=FDEP_set_ent(p,cix,rm);
		p.rm=[p.rm;rm];
		p.rf=[p.rf;rm;{hdr}];
		p.rs{nm,1}=rm;
	if	cix == 1
		rf=p.par.mktxtf(p,p.par,cix);
		p.rf=[p.rf;rf;{hdr}];

	end
	end	% K
	end	% J
	end	% I
	end

	if	~isempty(p.ix)
		p.rf(end)=[];
	end

	if	dflg
		disp(char(p.rf));
	end

	if	nargout
		po=p;
	end
end
%-------------------------------------------------------------------------------
function	p=FDEP_dlist(magic,p,varargin)

	if	~FDEP_chkpar(magic,p)
		return;
	end
		par=p.par;

		n=1;
		mrg=.01;
		l3=1/3;					% l = <el>!
		l4=1/5-mrg/5;
		xoff=0;
		yoff=mrg;
		ylen=l4-mrg-.02;
		xle2=2*l3-mrg;
		LB='listbox';
		fs=8;
		xpos=linspace(.5,1-mrg,6);
		dx1=xpos(2)-xpos(1);
		dx1=dx1-.01*dx1;

		ftag=p.par.tag{2}(p.module{1});
		fh=findall(0,'tag',ftag);
	if	isempty(fh)
		fh=figure;
	else
		figure(fh);
		shg;
		lh=get(fh,'userdata');
	if	numel(varargin)				&&...
		~isempty(varargin{1})
	if	ischar(varargin{1})
		p=FDEP_dfind(magic,p,false,varargin{1});
	if	~isempty(p.ix)
		n=p.ix;
	end
	else
		n=varargin{1};
	end
		FDEP_cb_list(lh(1),[],p,par,lh,lh(end),n);
	end
		FDEP_manager(fh,'dlist','dlist',p,'w',false);
		figure(fh);
		return;
	end
		ss=get(0,'screensize');
		fp=[.25*ss(3),50,.75*ss(3)-20,ss(4)-80];
		set(fh,'position',fp);
		fcol=get(fh,'color');

% macros
% - text position
			spos=@(x) [x(1:2)+[0,x(4)+.003],.75*x(3),.02];

		pos={
%		tag	position			description
%----------------------------------------------------------------------------
		'M'	[mrg,yoff+2*l4,1/3-2*mrg,1-(yoff+2*l4)-1*mrg-.02],...
			'modules'
		'F'	[xoff+l3,yoff+3*l4,xle2,ylen],...
			'calls  TO'
		'F'	[xoff+l3,yoff+2*l4,xle2,ylen],...
			'called FROM'
		'S'	[xoff+l3,yoff+1*l4,xle2,ylen],...
			'subfunctions'
		'S'	[xoff+l3,yoff+0*l4,xle2,ylen],...
			'nested / anonymous functions'
		'SM'	[mrg,yoff+1*l4,1/3-2*mrg,ylen],...
			'main function'
		'MT'	[mrg,yoff+0*l4,1/3-2*mrg,ylen],...
			'toolboxes'
		'T'	[xoff+l3,yoff+4*l4,xle2,ylen],...
			'module summary'
		};

		mpos={
%----------------------------------------------------------------------------
			[xpos(5),yoff+4*l4+ylen+.0025,dx1,.025],...
			'EDIT',...
			{@FDEP_cb_edit},...
			par.fcol
			[xpos(3),yoff+4*l4+ylen+.0025,dx1,.025],...
			'font -',...
			{@FDEP_cb_fs,-1},...
			par.pcol
			[xpos(4),yoff+4*l4+ylen+.0025,dx1,.025],...
			'font +',...
			{@FDEP_cb_fs,1},...
			par.pcol
		};

		v=num2cell(1:p.nfun).';
		tix=p.tix(:,2:5)~=0;
		des=repmat(p.par.dspec,size(tix,1),1);
		des(~tix)='.';
		des=cellstr(des);

		maxs=max(cellfun(@numel,p.module))+3;
		fmt=sprintf('%%%dd: %%-%ds %%s',fix(log10(p.nfun))+1,maxs);
		flst=cellfun(@(x,y,z) sprintf(fmt,x,y,z),v,p.module,des,'uni',false);
		flst{1}=[flst{1},'   [MAIN]'];

		np=size(pos,1);
		lh=zeros(np,1);
		th=zeros(np,1);
		uh=zeros(2,1);
	for	i=np:-1:1
			cp=pos{i,2};
		lh(i)=uicontrol(...
			'tag',pos{i,1},...
			'units','normalized',...
			'position',cp,...
			'style',LB,...
			'userdata',1);
		th(i)=uicontrol(...
			'tag',[pos{i,1},'text'],...
			'units','normalized',...
			'position',spos(cp),...
			'style','text',...
			'string',pos{i,3},...
			'horizontalalignment','left',...
			'fontname','courier new',...
			'fontsize',11,...
			'fontweight','bold',...
			'backgroundcolor',fcol);
	end
		set(lh,...
			'callback',{@FDEP_cb_list,p,par,lh,lh(end)},...
			'max',1,...
			'horizontalalignment','left',...
			'fontname','courier new',...
			'fontsize',fs,...
			'backgroundcolor',par.fcol,...
			'foregroundcolor',par.tcol);
		set(lh(1),'string',flst,...
			'backgroundcolor',par.mcol);
		set(lh(6),'string',par.mktxtf(p,par));
		set(lh(7),'string',p.toolbox,...
			'max',2);
		set(lh(6:7),...
			'backgroundcolor',par.pcol);
		set(lh(1:3),...
			'tooltipstring','*** click an ENTRY to show its content ***');
		set(lh(4:5),...
			'tooltipstring','*** click an ENTRY to open the module at the function ***');
		set(lh(6),...
			'tooltipstring','*** click anywhere to show the MAIN module ***');
		set(lh(8),...
			'tooltipstring','*** click the first LINE to show full module content ***');
		set(lh(7),...
			'hittest','off');

	for	i=1:size(mpos,1)
		uh(i)=uicontrol(...
			'callback',{mpos{i,3}{:},p,lh,LB},...
			'units','normalized',...
			'position',mpos{i,1},...
			'string',mpos{i,2},...
			'fontname','courier new',...
			'fontsize',11,...
			'fontweight','bold',...
			'backgroundcolor',mpos{i,4});	%#ok r2008b
	end

			uctrl={'quit','help','manager','matrix','tree'};
			FDEP_set_ctrl(p,fh,lh(8),uctrl,-17,12,2,1.5);

		set(fh,...
			'closerequestfcn',{@FDEP_manager,fh,p,'wd',false},...
			'deletefcn',{@FDEP_manager,fh,p,'wd',false},...
			'tag',ftag,...
			'userdata',lh,...
			'toolbar','none',...
			'menubar','none',...
			'numberTitle','off',...
			'name',['MODULE LIST:   ',...
				p.par.macro.sr(p.file)],...
			'color',fcol);

	if	numel(varargin)				&&...
		~isempty(varargin{1})
	if	ischar(varargin{1})
		p=FDEP_dfind(magic,p,false,varargin{1});
	if	~isempty(p.ix)
		n=p.ix;
	end
	else
		n=varargin{1};
	end
	end
		FDEP_manager(fh,'dlist','dlist',p,'w',false);
		FDEP_cb_list(lh(1),[],p,par,lh,lh(end),n);
		figure(fh);
		shg;

	if	~nargout
		clear p;
	else
		p.smod=@(ix) FDEP_cb_list(lh(1),[],p,par,lh,lh(end),ix);
	end
end
%-------------------------------------------------------------------------------
% CALLBACK functions
%	- dlist
%-------------------------------------------------------------------------------
function	FDEP_cb_map(h,e,p,lh,ix)		%#ok

		FDEP_dplot(p.magic,p);
end
%-------------------------------------------------------------------------------
function	FDEP_cb_edit(h,e,p,lh,ix)		%#ok

		v=get(lh(1),'userdata');
	try
		edit(p.fun{v});
	catch						%#ok
	end
end
%-------------------------------------------------------------------------------
function	FDEP_cb_sedit(h,e,p,par,ix,lh)		%#ok

		ud=get(h,'userdata');
	if	isempty(ud)
		return;
	end
		v=get(h,'value');
		opentoline(p.fun{ix},ud(v));
end
%-------------------------------------------------------------------------------
function	FDEP_cb_fs(h,e,mode,p,par,ix,lh)	%#ok

		lh=findall(gcf,'style',ix);
		cfs=get(lh(1),'fontsize');
		set(lh,'fontsize',cfs+mode);
end
%-------------------------------------------------------------------------------
function	FDEP_cb_help(h,e,p,lh,ix)		%#ok
		FDEP_manager([],'help',mfilename,p,'p',false);
end
%-------------------------------------------------------------------------------
function	FDEP_cb_list(h,e,p,par,lh,lht,v)	%#ok

	if	~all(ishandle([h;lh;lht]))
		disp(sprintf('%s> handles invalid',p.magic));
		return;
	end
	if	nargin < 7
		v=get(h,'value');
	elseif	v <= 0					||...
		v > p.nfun
		disp(sprintf('%s> index out of range: %-1d [1:%-1d]',...
			p.magic,v,p.nfun));
		return;
	end
		t=get(h,'tag');
	if	isempty(v)				||...
		numel(v) > 1
		return;
	end

		senum=p.par.enum.s;

	switch	t
	case	'M'
		set(h,'max',1);
	case	'F'
		s=cellstr(get(h,'string'));
	if	v <= 0 || v > numel(s)
		disp(sprintf('ERROR %5d',v));
		disp(s);
		return;
	end
		v=strmatch(s(v),p.fun,'exact');
	if	isempty(v);
		return;
	end
	case	'SM'
		v=1;
	case	'TB'
	case	'T'
		s=get(h,'string');
		m=get(lh(1),'value');
	if	v == 1
		p.ix=m;
		p.rs=s;
		FDEP_manager([],'synopsis',mfilename,p,'m',true,m,s);
	end
		return;
	case	'MT'
	if	v && v <= size(p.modbix,1)
		vx=p.modbix{v,end};
		set(lh(1),'max',2);
		set(lh(1),'value',vx);
	end
		return;
	otherwise
		return;
	end

		set([lh(4:5);lht],...
			'userdata',[],...
			'string','');
		set(lh(2:end),'value',1);
		set(lh(1),...
			'max',1,...
			'value',v);
		set(lht,'listboxtop',1);

		set(lh(2),'string',p.fun(p.mix{v}));
		set(lh(3),'string',p.fun(p.cix{v}));
	if	p.sub(v).n(senum.S)
		tmpt=cellfun(@(x,y) sprintf('S(%5d): %s',y,x),p.sub(v).S.fn,num2cell(p.sub(v).S.bx(1,:)).','uni',false);
		tmpt{1}(1)='M';
		set(lh(4),...
			'userdata',p.sub(v).S.bx(1,:).',...
			'string',tmpt);
	end
		txtn={''};
		ln=[];
	if	p.sub(v).n(senum.N)
		txtn=cellfun(@(x,y) sprintf('N(%5d): %s',y,x),p.sub(v).N.fd,num2cell(p.sub(v).N.bx(1,:)).','uni',false);
		ln=p.sub(v).N.bx(1,:).';
	end
	if	p.sub(v).n(senum.A)
		tmpt=cellfun(@(x,y) sprintf('A(%5d): %s',y,x),p.sub(v).A.fd,num2cell(p.sub(v).A.bx(1,:)).','uni',false);
		txtn=[txtn;tmpt];
		ln=[ln;p.sub(v).A.bx(1,:).'];
	end
	if	isempty(txtn{1})
		txtn=txtn(2:end);
	end
	if	numel(txtn)
		[ln,lnx]=sort(ln);
		set(lh(5),...
			'userdata',ln,...
			'string',txtn(lnx));
	end
		set(lh(4:5),...
			'callback',{@FDEP_cb_sedit,p,par,v,lh}');

		set(lh(7),'value',p.mlix{v,5});

		fdir=dir(p.fun{v});
		par.date=fdir.date;
		par.size=fdir.bytes;
		txt=par.mktxtm(p,par,v);
	for	i=1:size(p.par.mtag,1)
		txt=txt(~strcmp(txt,p.par.mtag{i}));
	end
		set(lht,'string',txt);
		set(lh(1),'userdata',v);
end
%-------------------------------------------------------------------------------
function	p=FDEP_dplot(magic,p,varargin)

	if	~FDEP_chkpar(magic,p)
			return;
	end
			ftag=p.par.tag{3}(p.module{1});

% one instance only
			fh=findall(0,'tag',ftag);
		if	~isempty(fh)
			figure(fh);
			FDEP_manager(fh,'plot','plot',p,'w',false);
			figure(fh);
			shg;
			return;
		end

% common parameters
			mrks=5;
			cbtag='CALLBACK';
			fs=9;					% font size
			fn='courier new';			% font name
			afs=8;
			afn='arial';

			cs=sum(abs(p.mat~=0),1);
			ms=sum(abs(p.mat~=0),2);

			xv=linspace(0,1,numel(p.caller)+2);
			yv=linspace(0,1,numel(p.module)+2);
			apos=[.25,.1,.65,.65];
			xoff=-.02;
			yoff=1.02;
			lh=nan(length(p.caller),length(p.module));

			fh=figure;
			set(fh,...
				'position',p.par.lwin,...
				'tag',ftag);
			shg;
			ah=axes;
			set(ah,...
				'position',apos,...
				'xlim',[0,1],...
				'ylim',[0,1],...
				'fontname',afn,...
				'fontsize',afs);

% CALLERS
	for	i=1:numel(p.caller)
			com=sprintf('edit(''%s'')',p.caller{i});
			th=text(xv(i+1),yoff,p.caller{i},...
				'units','normalized',...
				'rotation',90,...
				'verticalalignment','middle',...
				'fontsize',fs,'fontname',fn,...
				'interpreter','none',...
				'buttondownfcn',com,...
				'tag','f');
	if	i == 1
			set(th,'color',[1 0 0]);
	end
			set(th,'tag','c');
	for	j=1:numel(p.module)
			mcol=[0 0 1];
			ix=strcmp(p.caller{i},p.module{j});
	if	p.mat(j,i) > 0
			mrk='+';
			mrkc=[0 0 1];
	elseif	p.mat(j,i) < 0
			mrk='o';
			mrkc='none';
	elseif	ix
			mrk='diamond';
			mrkc=[0 0 1];
	else
			mrk='';
	end
	if	p.tix(j,4)
			mrkc=[1 0 0];
			mcol=mrkc;
	end
	if	mrk
			um=uicontextmenu(...
				'tag','f',...
				'callback',{@FDEP_cb_pos,p,i,j,cbtag,'m'},...
				'userdata',[]);
			lh(i,j)=line(i,j,...
				'tag','f',...
				'uicontextmenu',um,...
				'buttondownfcn',{@FDEP_cb_pos,p,i,j,cbtag,'m'},...
				'marker',mrk,...
				'markersize',mrks,...
				'markerfacecolor',mrkc,...
				'linestyle','none',...
				'color',mcol,...
				'userdata',[]);
	end
	end
	end

% MODULES
			yv=fliplr(yv);
	for	i=1:numel(p.module);
			tcol=[0 0 0];
			smod='     ';
			mod=p.module{i};
			ix=~any(strcmp(mod,p.caller));
	if	p.tix(i,3)
			smod(4)='E';
	end
	if	p.tix(i,4)
			smod(3)='S';
	end
			mod=sprintf('%s%s>',mod,smod);
	if	~ix
			mod(end)='+';
	end
			com=sprintf('edit(''%s'')',p.module{i});
			text(xoff,yv(i+1),mod,...
				'units','normalized',...
				'tag','m',...
				'buttondownfcn',com,...
				'horizontalalignment','right',...
				'fontsize',fs,'fontname',fn,...
				'interpreter','none',...
				'color',tcol,...
				'userdata',i);
	end
			set(ah,...
				'buttondownfcn',{@FDEP_cb_ax,cbtag,'f'},...
				'xlim',[0 length(p.caller)+1],...
				'xtick',1:length(p.caller),...
				'xticklabel',cs,...
				'ydir','reverse',...
				'ylim',[0 length(p.module)+1],...
				'ytick',1:length(p.module),...
				'yaxislocation','right',...
				'yticklabel',ms,...
				'color','none');
			box on;
			axis square;

			xt=sprintf('%-1d caller(s)\n[+: link',size(p.mat,2));
			xt=[xt '  \o: recursive'];
			xt=[xt '  \diamondsuit: caller=module]'];
			yt=sprintf('%-1d module(s)\n',size(p.mat,1));
			yt=[yt '[+: a caller  >: not a caller  S: a script (red)  E: calls f/eval..]'];
			xlabel(xt,'fontsize',afs+2);
			ylabel(yt,'fontsize',afs+2);

			set(fh,...
				'closerequestfcn',{@FDEP_manager,fh,p,'wd',false},...
				'deletefcn',{@FDEP_manager,fh,p,'wd',false},...				'toolbar','none',...
				'menubar','none',...
				'numberTitle','off',...
				'name',['DEPENDENCY MATRIX:   ',...
					p.par.macro.sr(p.file)],...
				'color',p.par.mcol);
			shg;

	if	nargin > 2
			pause(0);			% redraw!
	for	i=1:numel(varargin)
			d=varargin{i};
	if	numel(d) == 2				&&...
		isnumeric(d)				&&...
		ishandle(lh(d(1),d(2)))
			FDEP_cb_pos(lh(d(1),d(2)),[],p,d(1),d(2),cbtag,'m');
	end
	end
	end

		uh=uicontrol(...
			'units','normalized',...
			'position',[0,0,1,1],...
			'style','listbox');
		uctrl={'quit','help','manager','list','tree'};
		FDEP_set_ctrl(p,fh,uh,uctrl,-17,12,2,1.5,-100,[]);
		delete(uh);
		FDEP_manager(fh,'plot','plot',p,'w',false);
		figure(fh);

	if	~nargout
		clear p;
	end
end
%-------------------------------------------------------------------------------
% CALLBACK functions
%	- dplot
%-------------------------------------------------------------------------------
function	FDEP_cb_pos(h,e,p,xd,yd,tag1,tag2)	%#ok

		ud=get(h,'userdata');
	if	isempty(ud)
		th=findall(gca,'tag',tag2,'userdata',yd);
		txt=get(th,'string');
		is=find(isspace(txt));
		txt(is(1))=':';
		txt(is(2:end))='';
		fs=get(th,'fontsize');
		xlim=get(gca,'xlim');
		ylim=get(gca,'ylim');
		xh=line(xlim.',[yd;yd],[-10,-10],'tag',tag1);
		yh=line([xd;xd],ylim.',[-10,-10],'tag',tag1);
		set([xh,yh],'color',.9*[1,1,1]);
		txt=sprintf('%s\n%s',p.caller{xd},txt);
		th=text(xd+.01*p.par.macro.range(xlim),yd,10*ones(size(yd)),txt,...
			'tag',tag1,...
			'fontsize',fs+1,...
			'color',[1,0,0]);
		ud=[xh,yh,th];
	else
		delete(ud);
		ud=[];
	end
		set(h,'userdata',ud);
end
%-------------------------------------------------------------------------------
function	FDEP_cb_ax(h,e,tag1,tag2)		%#ok

		th=findall(h,'tag',tag1);
	if	isempty(th)
		return;
	end
		delete(th);
		th=findall(h,'tag',tag2);
		set(th,'userdata',[]);
end
%-------------------------------------------------------------------------------
function	s=FDEP_manager(hdl,evc,fnam,p,mode,dflg,varargin)	%#ok

% NOTE
% - dual role of manager
%	- callback		:	{@FDEP_manager,fnam,p,...}
%	- regular subfunction	:	s=FDEP_manager(hdl,evc,fnam,p,...)

	if	nargin < 6
		mode='p';		% help window		[def]
		dflg=false;		% create window		[def]
	end
		isman=false;		% calls manager windows
		hasfile=false;		% reads file
		hasctrl=false;		% wants controls

		fh=[];
		fs=9;
		fpos=p.par.hwin;

	switch	mode
% tree
%---------------------------------------
	case	'r'
		dflg=false;
		hasctrl=true;
		htag=p.par.tag{6}(p.module{1});
		s=varargin{2};
		c=double(~strcmp(s,varargin{3}));
		ix=find(c==0);
		c([1:3,ix])=[-300,-400,0,300].';
		s(ix)=s(2);
		s{1}=sprintf('%s     (*)=jump to section / click an entry to open its module synopsis',s{1});
		s{2}=sprintf('%s     (*)=jump to section / click an entry to open its module synopsis',s{2});
		ftit='FDEP RUNTME TREE';
		ucol=p.par.rcol;
		m=[];
		mx=[];
		ip=3;

% full module synopsis
%---------------------------------------
	case	'm'
		dflg=false;
		hasctrl=true;
		ucol=p.par.fcol;
		[s,c,m,mx,htag,ftit]=FDEP_get_module(p,varargin{:});
	if	isempty(ftit)
		return;
	end
		ip=find(c==0);

% listing panels' help
%---------------------------------------
	case	'p'
		htag=p.par.tag{1}(p.module{1});
		fh=findall(0,'tag',htag);
	if	~isempty(fh)
		figure(fh);
		uistack(fh,'top');
		shg;
		return;
	end
		hasfile=true;
		hasctrl=true;
		c=[-100,0];
		m=[];
		mx=[];
		ip=2;
		tb='%@LISTHELP_BEG';
		te='%@LISTHELP_END';
		ftit='FDEP HELP';
% FDEP windows manager
%---------------------------------------
	case	{'w','wd'}
		isman=true;
	if	p.par.opt.dflg

		disp(sprintf('MANAGER call  : %s',mode));
	if	ishandle(hdl)
		disp(sprintf('- hdl = %7d %s',hdl,get(hdl,'tag')));
	end
	end
		
% - caller:	fdep windows manager
		htag=p.par.tag{5}(p.module{1});
		fh=findall(0,'tag',htag);

% - caller:	callback closing
%		no manager
	if	strcmp(mode,'wd')			&&...
		ishandle(hdl)
		set(hdl,...
			'closerequestfcn','',...
			'deletefcn','');
		delete(hdl);
	if	isempty(fh)
		return;
	end
	end

% - caller:	callback create
%		has manager
		mh=findall(0,'type','figure');
		s=get(mh,'tag');
	if	~iscell(s)
		s={s};
	end
		s=s(strncmp(p.par.tagpid,s,numel(p.par.tagpid)));
		is=strcmp(htag,s);
	if	any(is)
		s(is)=[];
	end
		s=sort(s);
		s=strrep(s,p.par.tagpid,'');

	if	isempty(s)				&&...
		~isempty(is)				&&...
		ishandle(mh(is))
	if	p.par.opt.dflg
		disp(sprintf('MANAGER delete: empty manager'));
	end
		set(mh(is),...
			'closerequestfcn','',...
			'deletefcn','');
		delete(mh(is));
		return;
	elseif	isempty(is)
		return;
	end
%   start manager only if at least two windows are open
	if	numel(s) == 1				&&...
		isempty(fh)
		return;
	end

		fpos=[fpos(1),fpos(2)+.75*fpos(4),.5*fpos(3),.25*fpos(4)];
		ucol=p.par.pcol;
		fs=10;
		c=-200;
		m=[];
		mx=[];
		ip=1;
		ftit=sprintf('FDEP %s (%s)',p.module{1},p.([p.magic,'ver']));

% - invalid ID
	otherwise
		disp(sprintf('FDEP> invalid HELP id'));
		return;
	end

% read help section
%---------------------------------------
	if	hasfile
		ucol=p.par.pcol;
		s=p.par.farg.par.fh([fnam,'.m'],1);	% TEXTREAD replacement
		ib=find(strcmp(tb,s));
		ie=find(strcmp(te,s));
		s=detab(s(ib+1:ie-1));
	end

% create controls
%---------------------------------------
	if	~dflg
	if	isempty(fh)
		fh=figure(...
			'toolbar','none',...
			'tag',htag,...
			'position',fpos,...
			'numbertitle','off',...
			'menu','none',...
			'name',ftit);
	elseif	ishandle(fh)
		figure(fh);
		ch=findall(fh,'type','uicontrol');
		delete(ch);
	else
		return;
	end
		uh=uicontrol(...
			'units','normalized',...
			'position',[0,0,1,1],...
			'style','listbox',...
			'horizontalalignment','left',...
			'max',2,...
			'value',ip,...
			'string',s,...
			'fontname','courier new',...
			'fontsize',fs,...
			'backgroundcolor',ucol,...
			'foregroundcolor',p.par.tcol,...
			'callback',{@FDEP_cb_mlist,p,mx,m,s,c});
		pause(.05);
		set(uh,...
			'listboxtop',1);

	if	hasctrl
			FDEP_set_ctrl(p,fh,uh,[],-17,12,2,1.5,c,mx);
	end

		set(fh,...
			'closerequestfcn',{@FDEP_manager,fh,p,'wd',false},...
			'deletefcn',{@FDEP_manager,fh,p,'wd',false});

	if	~isman
	if	p.par.opt.dflg
		disp(sprintf('MANAGER load  : %s',get(fh,'tag')));
	end
		FDEP_manager(fh,'manager','manager',p,'w',false);
		figure(fh);
	elseif	isman					&&...
		ishandle(hdl)				&&...
		strcmp('figure',get(hdl,'type'))	% KEEP THIS!
		figure(hdl);
	else
		figure(fh);
	end

	else
		disp(char(s));
	end
	if	~nargout
		clear s;
	end
end
%-------------------------------------------------------------------------------
function	FDEP_mlist(magic,p,varargin)

	if	nargin < 3
		return;
	end

	for	i=1:numel(varargin)
	if	~iscell(varargin{i})
		carg=varargin(i);
	else
		carg=varargin{i};
	end

	for	j=1:numel(carg)
		arg=carg{j};
		argc=class(arg);
	switch	argc
	case	'char'
		p=FDEP_dfind(magic,p,false,arg);
		FDEP_manager([],[],[],p,'m',true,p.ix,p.ry);
	case	'struct'
	for	k=1:numel(arg)
		FDEP_manager([],[],[],p,'m',true,arg(k).index,arg(k).synopsis);
	end
	otherwise
	if	isnumeric(arg)
	for	k=1:numel(arg)
		p=FDEP_dfind(magic,p,false,arg(k));
		FDEP_manager([],[],[],p,'m',true,p.ix,p.ry);
	end
	else
		disp(sprintf('FDEP> invalid MHELP class [%s]',argc));
	end
	end
	end
	end
end
%-------------------------------------------------------------------------------
function	FDEP_rtree(magic,p,varargin)		%#ok

		htag=p.par.tag{6}(p.module{1});
		fh=findall(0,'tag',htag);
	if	~isempty(fh)
		figure(fh);
		uistack(fh,'top');
		shg;
	else
		ctag='@@@CALLER@@@';
		s=[
		{
			'RUNTIME    TREE'
			'MODULES    TREE'
			''
		}
			cellstr(p.rtree)
			{ctag}
			p.tree
		];
		FDEP_manager([],[],[],p,'r',true,1,s,ctag);
	end
end
%-------------------------------------------------------------------------------
function	[s,c,m,mx,htag,ftit]=FDEP_get_module(p,varargin)

% retrieve callback association from latest synopsis output
%
%	s=p.get(1);
%	n=num2cell(-1:-1:-size(s.synopsis,1)).';
%	c=cellfun(@(a,b) sprintf('%5d %s',a,b),n,s.synopsis,'uni',false)	

		TT=repmat(sprintf('\t'),1,2);
		COM='(click entry to open module)';
		COF='(click entry to open MODULE at call)';
		JTS=[TT,'(*)'];
		nof=2;

	mlst={
%		fieldname	descriptor	callback-ix	help
%		----------------------------------------------------
		'subfunction'	'MAIN function / subfunctions',...
			101	-14-nof,...
			COF	JTS
		'nested'	'nested functions',...
			102	-15-nof,...
			COF	JTS
		'anonymous'	'anonymous functions',...
			103	-16-nof,...
			COF	JTS
		'unresolved'	'unresolved functions',...
			104	-18-nof,...
			COF	JTS
		'callsTO'	'calls  TO   modules',...
			105	-11-nof,...
			COM	[JTS,'=jump to section']
		'callsFROM'	'called FROM modules',...
			105	-12-nof,...
			COM	JTS
		'MLtoolbox'	'ML toolboxes',...
			100	-23-nof,...
			''	JTS
		'MLfunction'	'ML stock functions',...
			105	-19-nof,...
			COM	JTS
		'MLbuiltin'	'ML built-in functions',...
			100	-20-nof,...
			''	JTS
		'MLclass'	'ML classes',...
			105	-21-nof,...
			COM	JTS
		'OTHERclass'	'OTHER classes',...
			100	-22-nof,...
			''	JTS
		'calls'		'calls in FILE',...
			110	-13-nof,...
			COF	JTS
	};

		c=[];
		m=[];
		mx=[];
		htag=[];
		ftit=[];

		s=varargin{2};
	for	i=1:size(p.par.mtag,1)
		s=s(~strcmp(s,p.par.mtag{i}));
	end
		d=FDEP_dget(p.magic,p,p);
	if	isempty(d)
		return;
	end

		m=d.file;
		mx=d.index;
		htag=p.par.tag{4}(d.module);
		otag=findall(0,'tag',htag);
	if	~isempty(otag)
		figure(otag);
		return;
	end

		nlst=size(mlst,1);
		nmax=max(cellfun(@numel,mlst(:,2)));
		fmt=sprintf('----- %%-%d.%ds: %%d\\t\\t%%s',nmax,nmax);

		ss=size(s,1);
		s{end+1}='-';
		ch=-14*nan(size(s));
		ch(-[mlst{:,4}])=[mlst{:,4}];
		c=num2cell(ch);

	for	i=1:nlst
		s{-mlst{i,4}}=sprintf('%s%s',s{-mlst{i,4}},mlst{i,6});
		ts=d.(mlst{i,1});
		ts=ts(~cellfun(@isempty,ts));
		ns=numel(ts);
	if	ns
		s{end+1}=sprintf(fmt,mlst{i,2},ns,mlst{i,5});	%#ok
	else
		s{end+1}=sprintf(fmt,mlst{i,2},ns,'');		%#ok
	end
		c(end+1)=mlst(i,4);				%#ok

	if	ns
		tn=num2cell(1:ns).';
	if	i < nlst
		s(end+1:end+ns)=cellfun(@(a,b) sprintf('%4d:          %s',a,b),tn,ts,'uni',false);
		c(end+1:end+ns)=mlst(i,3);
	else
		s(end+1:end+ns)=cellfun(@(a,b) sprintf('%4d: %s',a,b),tn(:),ts(:),'uni',false);
		c(end+1:end+ns)=mlst(i,3);
	end
	end
		s(end+1)={''};					%#ok
		c(end+1)={nan};					%#ok
	end

		c=[c{:}].';
		c(1:numel(ch))=ch;
		c(ss+1)=0;

		n=max(cellfun(@numel,s(1:ss)));
		s{ss+1}=repmat('-',1,n);
		s=detab(s);

		ftit=sprintf('MODULE SYNOPSIS:   %s   >   %s',p.module{1},d.module);
end
%-------------------------------------------------------------------------------
function	FDEP_set_ctrl(p,fh,uh,ix,xoff,xlen,yoff,ylen,varargin)

	uc={
%		descriptor	callback	color		tip
%		----------------------------------------------------------
		'quit'		'quit'		p.par.pcol	'quit this window'
		'font -'	'fontm'		p.par.pcol	'make fontsize smaller'
		'font +'	'fontp'		p.par.pcol	'make fontsize bigger'
		'help'		'help'		p.par.pcol	'show the help window'
		'manager'	'manager'	p.par.pcol	'show the window manager'
		'list'		'list'		p.par.pcol	'show the module list'
		'matrix'	'matrix'	p.par.pcol	'show the dependency matrix'
		'tree'		'tree'		p.par.pcol	'show the runtime tree'
		'home'		'home'		p.par.pcol	'go to start of synopsis'
	};

	if	isempty(ix)
		ix=1:size(uc,1);
	elseif	iscell(ix)
		[ix,ix]=ismember(ix,uc(:,1));		%#ok
	end
		uc=uc(ix,:);

		set(uh,'units','characters');
		pos=get(uh,'position');
		set(uh,'units','normalized');
	for	i=1:size(uc,1)
		npos=[pos(1)+pos(3)+xoff,pos(2)+pos(4)-i*ylen-yoff,xlen,ylen];
		uicontrol(...
			'units','characters',...
			'position',npos,...
			'string',uc{i,1},...
			'tooltipstring',uc{i,4},...
			'callback',{@FDEP_cb_mbutton,p,uc{i,2},fh,uh,varargin{:}},...
			'backgroundcolor',.99*uc{i,3});	%#ok r2008b
	end
end
%-------------------------------------------------------------------------------
% CALLBACK functions
%	- mhelp
%-------------------------------------------------------------------------------
function	FDEP_cb_mlist(h,e,p,mx,m,s,c)		%#ok

		v=get(h,'value');
	if	numel(v) > 1
		return;
	end

% help window
	if	c(1) == -100
		return;
	end

% tree window
	if	c(1) == -300
	if	v == 2
		v=find(c==300);
		set(h,'listboxtop',v);
	elseif	v == 1
		v=4;
		set(h,'value',v);
	else
		ix=strfind(s{v},'|');
	if	~isempty(ix)
		m=regexp(s{v}(ix+1:end),'(?<=|)\w+(?=\s*)','match','once');
	end
		p.mhelp(m);
	end
		return;
	end

% manager window
	if	c(1) == -200
		v=get(h,'value');
	if	~isempty(v)
		cs=get(h,'string');
	if	~isempty(cs)
		cs=[p.par.tagpid,cs{v}];
		fh=findall(0,'tag',cs);
		set(h,'value',v);
	if	~isempty(fh)				&&...
		numel(fh) == 1				&&...
		ishandle(fh)				% KEEP THIS!
		figure(fh);
	end
	elseif	ishandle(h)
		delete(h);
	end
	elseif	ishandle(h)
		delete(h);
	end
		return;
	end

% mhelp windows
		cn=c(v);
	if	cn == 0
		return;
	end
	if	isnan(cn)
		return;					% -1: home
	elseif	cn > 100
		cn=c(v)-100;
	elseif	v <= -min(c)
		ix=find(c==cn,1,'last');
		set(h,'value',ix);
		pause(.05);
		set(h,'listboxtop',ix);
		return
	end
		cs=s{v};

	switch	cn
	case	{1,2,3,4}
		ml={'S','N','A','E'};
		[r,nr,er]=sscanf(cs,'%d:%s',[1,2]);	%#ok
	if	er
		return;
	end
		opentoline(m,p.sub(mx).(ml{cn}).bx(1,r(1)));
	case	5
		[r,nr,er]=sscanf(cs,'%d:%s',[1,2]);	%#ok
	if	er
		return;
	end
		f=char(r(2:end));
	if	exist(f,'file')
		opentoline(f,1);
	end
	case	10
		[r,nr,er]=sscanf(cs,'%d:%d%s',[1,3]);	%#ok
	if	er
		return;
	end
		opentoline(m,r(2));
	case	501
		p.list();
	case	502
		p.list();
	case	503
		p.list();
	case	-1
		set(h,'value',find(c==0));
		pause(.05);
		set(h,'listboxtop',1);
	otherwise
	end
end
%-------------------------------------------------------------------------------
function	FDEP_cb_mbutton(h,e,p,cb,fh,uh,c,mx)	%#ok

	switch	cb
	case	'help'
		p.help();
		return;
	case	'list'
		p.list(mx);
		return;
	case	'matrix'
		p.mplot();
		return;
	case	'tree'
		p.tplot();
		return;
	case	'home'
		set(uh,'value',find(c==0));
		pause(.05);
		set(uh,'listboxtop',1);
		return;
	case	'quit'
		delete(fh);
	case	'manager'
		mh=findall(0,'tag',p.par.tag{5}(p.module{1}));
	if	~isempty(mh)
		figure(mh);
		return;
	end
	case	'fontm'
		cfs=get(uh,'fontsize');
		set(uh,'fontsize',cfs-1);
		return;
	case	'fontp'
		cfs=get(uh,'fontsize');
		set(uh,'fontsize',cfs+1);
		return;
	otherwise
	end
		FDEP_manager(fh,'button','button',p,'w',false);
end
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%
% FARG		a FEX file
% created:
%	us	02-Jan-2005
%
% download the latest standalone including help/comments from
% http://www.mathworks.com/matlabcentral/fileexchange/15924
%
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%$SSC_INSERT_BEG   21-Jun-2010/02:16:53   F:/usr/matlab/tmp/fex/afarg/ver2010/farg.m
%-------------------------------------------------------------------------------
% SSC automatic file insertion utility
%     - us@neurol.unizh.ch [ver 26-Apr-2010/00:48:30]
%     - all empty spaces and comments are stripped for brevity
%     - original code available upon request
%-------------------------------------------------------------------------------
function	[p,pp]=farg(varargin)
		magic='FARG';
		fver='21-Jun-2010 02:16:38';
	if	~nargin
	if	nargout
		[p,pp]=FARG_ini_par(magic,fver,mfilename,'-d');
	else
		help(mfilename);
	end
		return;
	end
		[p,par]=FARG_ini_par(magic,fver,varargin{:});
	if	~par.flg
		[p,par]=FARG_set_text(p,par,1);
		[p,par]=FARG_get_file(p,par);
	if	~par.flg
		[p,par]=FARG_get_calls(p,par);
	if	~par.flg
		[p,par]=FARG_get_entries(p,par);
	end
	end
		[p,par]=FARG_set_text(p,par,2);
	end
	if	nargout
		pp=p;
		pp.hdr=par.hdr;
		pp.res=par.res;
	if	~par.opt.dflg				&&...
		isfield(pp,'par')
		pp=rmfield(pp,'par');
	else
		pp.par=par;
	end
		p=par.res;
	else
		clear p;
	end
end
function	[p,par]=FARG_ini_par(magic,fver,varargin)
		narg=nargin-2;
		F=false;
		T=true;
		p.magic=magic;
		p.([magic,'ver'])=fver;
		p.MLver=version;
		p.rundate=datestr(now);
		p.fnam='';
		p.pnam='';
		p.wnam='';
		p.dnam='';
		p.ftyp='';
		p.mp=[true,true,false];			% M P O
		p.hdr='';
		p.res='';
		p.def={};
		p.sub={};
		p.ixm=[];
		par=p;
		par.txt={};
		par.opt=[];
		par.fh=@FARG_read;
		par.mopt={
			'-m3'
			'-calls'
		};
		par.lopt={
			'-m3'
			'-lex'
		};
		par.opt.dflg=false;
		par.opt.eflg=false;
		par.opt.hflg=false;
		par.opt.line=true;
		par.opt.sflg=true;
		par.opt.Sflg=false;			% hidden option
		par.opt.wflg=false;
	if	narg > 1
	for	i=1:narg
	switch	varargin{i}
	case	'-d'
		par.opt.dflg=true;
	case	'-e'
		par.opt.eflg=true;
	case	'-h'
		par.opt.hflg=true;
	case	'-l'
		par.opt.line=false;
	case	'-s'
		par.opt.sflg=false;
	case	'-S'
		par.opt.Sflg=true;
		par.opt.dflg=true;
	case	'-w'
		par.opt.wflg=true;
	end
	end
	end
		par.fmtnoop='%10d';
		par.fmtopen='<a href="matlab:opentoline(''%s'',%d)">NUMDIG</a>';
		par.fmtopen=strrep(par.fmtopen,'NUMDIG',par.fmtnoop);
		par.fmtmark=sprintf('__&&@@%s@@&&__',par.rundate);	% unique marker
		par.fmtcmp='%1d';
		par.rexlex='(?<=(:.+:\s+)).+$';
		par.rexmod='(\w+$)|(\d+$)';
		par.lexerr='<LEX_ERR>';
		par.rexcmp='(?<='').*(?='')|(?<=(\s))\d+(?=(\.)$)';
		par.rexcyc='The McCabe complexity of';
		par.rexeva='(^feval$)|(^evalc$)|(^evalin$)|(^eval$)';
		par.rexfh=@(x) regexp(x,par.rexmod,'match');
		par.ftok={
			'+'	' '		% M: main function
			'-'	' '		% S: subroutine
			'.'	'    '		% N: nested
			'@'	'       '	% A: anonymous
			'?'	'          '	% X: unresolved
			' '	'          '	% U: ML stock functions
			'!'	'       '	% E: eval
			'+'	' '		% R: recursion
			
		};
		par.lexstp={			% @ stop conditions
			'<EOL>'
			''';'''
			''','''
		};
		par.lexbrb={			% @ REVERSE search!
			'''('''
			'''{'''
			'''['''
		};
		par.lexbre={			% @ REVERSE search!
			''')'''
			'''}'''
			''']'''
		};
		par.lent={			% function delimiters
			'FUNCTION'	2
			'<EOL>'		2
		};
		par.scom=...
			@(x) textscan(x,'%d/%d(%d):%[^:]:%s');
		par.mext='.m';
		par.pext={
			'.miss'		0	F
			'.var'		1	F
			'.m'		2	T
			'.mex'		3	T
			'.mdl'		4	T
			'.builtin'	5	T
			'.p'		6	T
			'.folder'	7	F
			'.java'		8	F
		};
		par.mlroot=[matlabroot,filesep,'toolbox'];
		par.ftyp={'SCRIPT','FUNCTION','CLASS'};
		par.stmpl={
			'M'	1	3	true	par.rexfh
			'S'	2	3	false	par.rexfh
			'N'	3	3	true	par.rexfh
			'A'	4	[1,4]	true	par.rexfh
			'X'	5	0	false	''
			'U'	6	3	false	par.rexfh
			'E'	7	0	false	''
			'R'	8	0	false	''
			'O'	9	0	false	''
			'UU'	16	0	false	''
		};
		par.stmplf={
			'fn'	{}	1
			'fd'	{}	1
			'nx'	0	0
			'bx'	[]	2
			'ex'	[]	2
			'lx'	[]	0
			'dd'	[]	1
		};
		par.stmpla.n=zeros(1,size(par.stmpl,1));
		par.senum=par.stmpl(:,1:2).';
		par.senum=struct(par.senum{:});
		par.flg=true;
		par.fver=fver;
		par.rt=0;
		par.shdr=3;
		par.ooff=10-3;				% memo: opentoline offset - n*%+1
		par.crlf=sprintf('\n');
		par.wspace=[' ',sprintf('\t')];
		par.bol='%';
		par.deflin='';
		p.des=par.stmpl(:,1).';
		p.n=par.stmpla.n;
	for	i=1:size(par.stmpl,1)
		fn=par.stmpl{i,1};
	for	j=1:size(par.stmplf,1)
		fm=par.stmplf{j,1};
		par.stmpla.(fn).(fm)=par.stmplf{j,2};
	end
		p.(fn)=par.stmpla.(fn);
	end
		flg=false;
		par.fnam=varargin{1};
		ftype=exist(par.fnam,'file');
		[fpat,frot,fext]=fileparts(par.fnam);	%#ok
	if	isempty(fext)				||...
		ftype ~= par.pext{3,2}
		par.fnam=[frot,par.mext];
	end
	if	ftype ~= par.pext{3,2}
		par.pnam=varargin{1};
	end
		par.pnam=which(par.pnam);
	if	isempty(par.pnam)
		par.mp(2)=false;
	end
		par.wnam=which(par.fnam);
		wtype=exist(par.wnam,'file');
	if	isempty(par.wnam)			||...
		wtype ~= par.pext{3,2}
		flg=true;
		par.mp(1)=false;
	if	par.opt.sflg
		disp(sprintf('%s> ERROR   M-file not found',p.magic));
		disp(sprintf('-----------   %s',varargin{1}));
	end
	end
		par.dnam=dir(par.wnam);
	if	~flg
		par.dnam.ds=strread(par.dnam.date,'%s','whitespace',' ');
	end
	if	par.mp(2)				&&...
		~par.pext{ftype+1,3}
		par.mp=[false,false];
	end
		p.fnam=par.fnam;
		p.pnam=par.pnam;
		p.wnam=par.wnam;
		p.dnam=par.dnam;
		p.mp=par.mp;
		par.nlen=0;
		par.nlex=0;
		par.nfun=0;
		par.mfun=0;
		par.ncom=0;
		par.nemp=0;
		par.file={};
		par.call={};
		par.mlex={};
		par.comt={};
		par.lex={};
		par.ltok={};
		par.lint={};
		par.flg=flg;
		p.par=par;
		p.s=[];
end
function	[s,nl]=FARG_read(fnam,mode)
		s='';
	if	mode <= 1
		fp=fopen(fnam,'rt');
	if	fp > 0
		s=fread(fp,inf,'*char').';
		fclose(fp);
	end
		ie=[strfind(s,sprintf('\n')),numel(s)+1];
		nl=numel(ie);
	end
	if	mode >= 1
	if	mode == 2
		s=fnam;
	end
		s=strread(s,'%s','delimiter','','whitespace','');
		nl=size(s,1);
	end
end
function	[p,par]=FARG_get_file(p,par)
		[par.file,par.nlen]=par.fh(par.wnam,0);
		par.call=mlintmex(par.wnam,par.mopt{:});
		par.call=par.fh(par.call,2);
		par.lex=mlintmex(par.wnam,par.lopt{:});
		par.mlex=par.fh(par.lex,2);
		ix=	~cellfun(@isempty,strfind(par.mlex,'%:'))	|...
			~cellfun(@isempty,strfind(par.mlex,'%{:'))	|...
			~cellfun(@isempty,strfind(par.mlex,'%}:'));
		par.comt=par.mlex(ix);
		par.ncom=sum(ix);
		ix=ismember(par.lex,par.wspace);
		par.lex(ix)='';
		par.lex=par.scom(par.lex);
		par.ltok=[par.lex{:,4},par.lex{:,5}];
		par.lex=cat(2,par.lex{1:3});
		par.nlex=size(par.ltok,1);
		par.nemp=sum(accumarray(par.lex(:,1),par.lex(:,3))==1);
		par=FARG_chk_lint(par);
end
function	par=FARG_chk_lint(par)
		par.lint.ferr=false;
		par.lint.nerr=0;
		par.lint.err={};
		par.lint.serr=[];
		par.lint.mcyc=nan;
		par.lint.ncyc=[];
		par.lint.cyc={};
		err=mlint(par.wnam,'-all');
	if	~isempty(err)
	if	~par.opt.line
		fmt=par.fmtnoop;
		fnc=@(x,y,z) sprintf(['%s %5d>',fmt,': %s'],...
				par.bol,x(1),y(1),z(1,:));
	else
		fmt=par.fmtopen;
		fnc=@(x,y,z) sprintf(['%s %5d>',fmt,': %s'],...
				par.bol,x(1),par.wnam,y(1),y(1),z(1,:));
	end
		par.lint.nerr=numel(err);
		par.lint.serr=err;
		par.lint.err=cellfun(@(x,y,z) fnc(x,y,z),...
			num2cell(1:numel(err)),...
			{err.line},...
			{err.message},...
			'uni',false).';
	end
		cyc=mlint(par.wnam,'-cyc');
		cyc={cyc.message}.';
		ix=strncmp(cyc,par.rexcyc,numel(par.rexcyc));
	if	any(ix)
		cyc=regexp(cyc(ix),par.rexcmp,'match');
		cyc=[cyc{:}]';
		par.lint.cyc=reshape(cyc.',2,[])';
		par.lint.ncyc=cellfun(@(x) sscanf(x,'%d'),par.lint.cyc(:,2));
		par.lint.mcyc=max(par.lint.ncyc);
		ncmp=max([1,ceil(log10(par.lint.mcyc))]);
		par.fmtcmp=sprintf('%%%ds',ncmp);
	end
		lerr=sum(strcmp(par.ltok,par.lexerr),2);
	if	any(lerr)
		par.file=par.fh(par.file,2);
		par.lint.ferr=true;
		par.flg=true;
		par.opt.sflg=true;
		ix=find(lerr);
		nx=numel(ix);
		par.txt=[
			par.txt
			'DONE'
			{
			sprintf('%s LEX errors%6d',par.bol,nx)
			'LINE'
			}
		];
	for	i=1:nx
			nl=par.lex(ix(i),:);
	if	par.opt.line
			el=sprintf(par.fmtopen,par.wnam,nl(1),nl(1));
	else
			el=sprintf(par.fmtnoop,nl(1));
	end
			nl(2)=min([nl(2),numel(par.file{nl(1)})]);
			to=par.file{nl(1)}(nl(2));
		par.txt=[
			par.txt
			{
			sprintf('%s line  %s:   %-1d = <%s>\n',par.bol,el,nl(2),to)
			}
			par.lint.err
		];
	end
		par.txt(4,1)={
			sprintf('%s %s\n',par.bol,repmat('-',1,size(char(par.txt(1:3)),2)-3))
		};
	end
end
function	[p,par]=FARG_get_calls(p,par)
		[p,par]=FARG_get_class(p,par,1);
		ic=find(~cellfun(@isempty,par.stmpl(:,end))).';
	for	i=ic
		fn=par.stmpl{i,1};
		v.(fn)=[];				%#ok
		ix=~cellfun('isempty',regexp(par.call,['^',fn],'match'));
	if	any(ix)
		vtmp=par.stmpl{i,5}(par.call(ix));
		bx=cellfun(@(x) sscanf(x,'%*2s %d %d %*s'),par.call(ix),'uni',false);
		ex=bx;
	if	par.stmpl{i,4}
		ex=cellfun(@(x) sscanf(x,'%*2s %d %d %*s'),par.call(find(ix)+1),'uni',false);
	end
		p.n(i)=sum(ix);
		p.(fn).fn=[vtmp{:}].';
		p.(fn).nx=p.n(i);
		p.(fn).bx=[bx{:}];
		p.(fn).ex=[ex{:}];
		p.(fn).lx=cellfun(@numel,p.(fn).fn);
	end
	end
		p.UU=p.U;
		par.nfun=sum(p.n(1:3));			% M S N [A X U E R]
		par.mfun=par.nfun;			% M S N
	if	par.mp(3)				&&...
		p.M.nx > 1
		par.lint.ferr=true;
		par.flg=true;
		par.opt.sflg=true;
		par.txt=[
			par.txt
			'DONE'
			{
			sprintf('%s FATAL ERROR',par.bol)
			'LINE'
			}
			par.lint.err
		];
		par.txt(4,1)={
			sprintf('%s %s\n',par.bol,repmat('-',1,size(char(par.txt(1:3)),2)-3))
		};
	end
end
function	[p,par]=FARG_get_class(p,par,mode)
	switch	mode
	case	1
		ich=find(strncmp('CLASSDEF',par.ltok(:,1),numel('CLASSDEF')));
		ic=ich;
	if	strcmp(par.ltok(ic+1,1),'''(''')
		ic=ic+1;
	while	ic < par.nlex
		ic=ic+1;
	if	strcmp(par.ltok(ic,1),''')''')
		break;
	end
	end
	end
	if	any(ich)
		par.ltok(ich,:)=strrep(par.ltok(ich,:),'CLASSDEF','FUNCTION');
		par.call=[
			{
			sprintf('M%-1d %-1d %-1d %s',0,par.lex(ic+1,1:2),par.ltok{ic+1,2})
			sprintf('E%-1d %-1d %-1d %s',0,par.lex(ic+1,1:2),par.ltok{ic+1,2})
			}
			par.call
		];
		par.mp(3)=1;
		return;
	end
	case	2
	if	par.mp(3)
		fn=cell(par.nfun,1);
	for	i=1:3
		ix=p.ixm(:,2)==i;
	switch	i
	case	1
		fn(ix)=p.M.fn;
	case	2
		fn(ix)=p.S.fn;
	case	3
		fn(ix)=p.N.fn;
	end
	end
	if	~isempty(par.lint.cyc)
		cyc=par.lint.cyc(:,2);
	else
		cyc={};
	end
		tcyc=[
			repmat({'c'},par.nfun-numel(par.lint.ncyc),1)
			cyc
		];
		ncyc=[
			repmat(-1,par.nfun-numel(par.lint.ncyc),1)
			par.lint.ncyc
		];
		par.lint.cyc=[fn,tcyc];
		par.lint.ncyc=ncyc;
		par.lint.mcyc=max(abs(par.lint.ncyc));
		ncmp=max([2,ceil(log10(par.lint.mcyc))]);
		par.fmtcmp=sprintf('%%%ds',ncmp);
	end
	end
end
function	[p,par]=FARG_get_entries(p,par)
		ixt=false(par.nlex,2);
	for	i=1:size(par.lent,1)
		ctok=par.lent{i,1};
		nmatch=par.lent{i,2};
		ixt(:,i)=sum(strcmp(ctok,par.ltok),2)==nmatch;
	end
		lix=strcmp(par.ltok(:,1),'%');
		ltmp=par.ltok(lix,2);
		par.ltok(lix,2)={''};
		ixb=[];
		sr={};
	if	par.nfun
		p.ixm=zeros(par.nfun,3);
		ixb=zeros(par.nfun,1);
		ixe=zeros(par.nfun,1);
		ixc=zeros(par.nfun,1);
		ixl=zeros(par.nfun,1);
		sr=cell(size(p.ixm,1),1);
	if	p.N.nx
		nix=p.N.bx(1,:);
		nex=p.N.ex(1,:);
	end
	if	par.mfun
		ixb(1:par.mfun,1)=find(ixt(:,1)==1);
	for	i=1:par.mfun
		ixl(i)=find(ixt(ixb(i)+1:end,2)==1,1,'first');
		sr{i}=par.ltok(ixb(i):ixb(i)+ixl(i),2);
		sr{i}=regexprep(sr{i},'^''','');
		sr{i}=regexprep(sr{i},'''$','');
		ixe(i)=par.lex(ixb(i)+ixl(i),1);
		ixb(i)=par.lex(ixb(i),1);
		ixc(i)=par.lex(ixb(i),2);
		sr{i}=sprintf('%s',sr{i}{2:end-1});
		p.ixm(i,:)=[ixb(i),min([i,2]),ixc(i)];
	if	p.N.nx					&&...
		numel(nex)
	if	any(ixe(i)<=nex(1))			&&...
		any(ixe(i)>=nix(1))
		p.ixm(i,2)=3;
		nex(1)=[];
		nix(1)=[];
	end
	end
	end
	end
		ixb=p.ixm(:,1);
	end
		[p,par]=FARG_get_class(p,par,2);
		[p,par]=FARG_chk_entries(p,par);
	if	p.A.nx
		p=FARG_get_context(p,par,'A',false);
		ss=FARG_set_context(p,par,'A');
		p.A.fn=ss;
		p.A.fd=ss;
		[p,par,sr,ixb]=FARG_add_entries(p,par,sr,'A',ixb);
	end
		[p,par,sr,ixb]=FARG_add_entries(p,par,sr,'X',ixb);
	if	p.R.nx
		p=FARG_get_context(p,par,'R',true);
		ss=FARG_set_context(p,par,'R');
		p.R.fd=ss;
		[p,par,sr,ixb]=FARG_add_entries(p,par,sr,'R',ixb);
	end
	if	p.E.nx					&&...
		par.opt.eflg
		p=FARG_get_context(p,par,'E',true);
		ss=FARG_set_context(p,par,'E');
		p.E.fd=ss;
		[p,par,sr,ixb]=FARG_add_entries(p,par,sr,'E',ixb);
	end
	for	i=1:size(par.stmpl,1)
		cf=par.stmpl{i,1};
		cx=par.stmpl{i,2};
	if	par.nfun
		ix=p.ixm(:,2)==cx;
	if	any(ix)
		p.(cf).fd(1:sum(ix),1)=sr(ix);
	end
		p.n(i)=p.(cf).nx;
	end
	end
		p.ftyp=par.ftyp{sign(par.mfun)+1};
		p.s=@(varargin) FARG_show_entries(p,varargin{:});
	if	par.opt.Sflg
		return;
	end
		[p,par,s]=FARG_set_text(p,par,3);
		par.hdr=s{1};
	if	~par.opt.hflg
		[p,par]=FARG_set_entries(p,par,s,sr,ixb);
	else
		par.res=par.hdr;
	end
		par.ltok(lix,2)=ltmp;
end
function	[p,par]=FARG_chk_entries(p,par)
		ie=cellfun(@exist,p.UU.fn);
		p.UU.dd=ie.';
		p.U.fd=p.U.fn;
		p.U.dd=nan(size(p.U.fd));
	if	par.nfun
	if	p.M.nx
		ix=strncmp(p.M.fn{1},p.U.fn,numel(p.M.fn{1}));
		ix=ix&(p.U.lx==p.M.lx);
	if	any(ix)
		ie(ix)=[];
		ia=find(strncmp(par.ltok(:,2),p.M.fn{1},numel(p.M.fn{1})));
		ia=ia(par.lex(ia,3)==p.M.lx);
		ia=ia(3:end);
	if	~isempty(ia)
		na=numel(ia);
		p.U.fn=[p.U.fn;repmat(p.U.fn(ix),na,1)];
		p.U.fd=[p.U.fd;repmat(p.U.fd(ix),na,1)];
		p.U.dd=[p.U.dd;repmat(p.U.dd(ix),na,1)];
		p.U.ex=[p.U.ex,par.lex(ia,1:2).'];
		p.U.bx=[p.U.bx,par.lex(ia,1:2).'];
		p.U.nx=p.U.nx+na;
		ix=[ix;true(na,1)];
	end
		[p,par]=FARG_upd_entries(p,par,'R',ix,~ix);
	end
	end
		ix=~cellfun(@isempty,regexp(p.U.fn,par.rexeva));
	if	any(ix)
		ie(ix)=[];
		ia=regexp(par.ltok(:,2),par.rexeva);
		ia=find(~cellfun(@isempty,ia));
		it=~ismember(par.lex(ia,1:2),p.U.bx(:,ix).','rows');
		ia=ia(it);
	if	~isempty(ia)
		na=numel(ia);
		tok=par.ltok(ia,2);
		p.U.fn=[p.U.fn;tok];
		p.U.fd=[p.U.fd;tok];
		p.U.dd=[p.U.dd;nan(na,1)];
		p.U.ex=[p.U.ex,par.lex(ia,1:2).'];
		p.U.bx=[p.U.bx,par.lex(ia,1:2).'];
		p.U.nx=p.U.nx+na;
		ix=[ix;true(na,1)];
	end
		[p,par]=FARG_upd_entries(p,par,'E',ix,~ix);
	end
	end
		af=[p.S.fn;p.N.fn];
		im=ismember(p.U.fn,af);
		id=cellfun(@which,p.U.fn,'uni',false);
		iw=cellfun(@isempty,id);
		p.U.fd(~iw)=id(~iw);
		p.U.dd=ie(:).';
	if	~isempty(im)
		us=~im&iw&ie;				% unknown source
		p.U.fd(us)=cellfun(@(x) sprintf('%s [source?]',x),p.U.fn(us),'uni',false);
		ur=~im&iw;
		uk=~(ur|im);
		[p,par]=FARG_upd_entries(p,par,'X',ur,uk);
	end
end
function	[p,par]=FARG_upd_entries(p,par,fe,ur,uk)
	for	i=1:size(par.stmplf)
		nr=par.stmplf{i,3};
	if	nr
		fn=par.stmplf{i,1};
	switch	nr
	case	1
		p.(fe).(fn)=p.U.(fn)(ur);
		p.U.(fn)=p.U.(fn)(uk);
	case	2
		p.(fe).(fn)=p.U.(fn)(:,ur);
		p.U.(fn)=p.U.(fn)(:,uk);
	end
	end
	end
		p.(fe).nx=sum(ur);
		p.U.nx=sum(uk);
end
function	[p,par,sr,ixb]=FARG_add_entries(p,par,sr,fe,ixb)
		sub=p.(fe);
	if	sub.nx
		par.nfun=par.nfun+sub.nx;
		ci=numel(ixb);
		ixb=[ixb;sub.bx(1,:).'];
		p.ixm=[p.ixm;[par.senum.(fe)*ones(sub.nx,2),sub.bx(2,:).']];
		p.ixm(:,1)=ixb;
		sr(ci+1:ci+sub.nx)=sub.fd;
		[ix,ix]=sortrows(p.ixm,[1,3,2]);	%#ok
		sr=sr(ix);
		p.ixm=p.ixm(ix,:);
		ixb=p.ixm(:,1);
	end
		p.def=sr;
end
function	[p,par]=FARG_set_entries(p,par,s,sr,ixb)
	if	par.nfun
		nfmt=repmat({''},par.nfun,1);
		ix=p.ixm(:,2)<4;			% cyc M S N
	if	any(ix)					% FUNCTION
		nfmt(ix)=par.lint.cyc(:,2);
	else						% SCRIPT
		par.fmtcmp='%1s';
	end
		fmt=strrep('%s%6d|%s: %c  X %s','X',par.fmtcmp);
		omax=0;
	for	i=1:par.nfun
		cn=i+par.shdr;
		s{cn}=sprintf(fmt,...
			par.bol,...
			i,...
			par.fmtmark,...
			par.ftok{p.ixm(i,2),1},...
			nfmt{i},...
			par.ftok{p.ixm(i,2),2});
		s{cn}=deblank(sprintf('%s%s',s{cn},sr{i}));
	if	par.opt.line
		of=sprintf(par.fmtopen,par.wnam,ixb(i),ixb(i));
	else
		of=sprintf(par.fmtnoop,ixb(i));
	end
		omax=max([omax,numel(of)]);
		s{cn}=strrep(s{cn},par.fmtmark,of);
	end
	if	par.opt.line
		s{par.shdr}=[par.bol,' ',sprintf(repmat('-',1,size(char(s),2)-omax+par.ooff))];
	else
		cmax=max(cellfun(@numel,s(par.shdr+1:end)));
		s{par.shdr}=[par.bol,' ',sprintf(repmat('-',1,cmax-3))];
	end
		ix=(p.ixm(:,2)==1) | (p.ixm(:,2)==2);
	if	any(ix)
		sf=[p.M.fn;p.S.fn];
		sf=sf(~cellfun(@isempty,sf));
		sd=sr(ix);
		ns=max(cellfun(@numel,sf));
		fmt=sprintf('%%-%ds   >   %%s',ns);
		sd=cellfun(@(a,b) sprintf(fmt,a,b),sf,sd,'uni',false);
		p.sub=sd;
	end
		ix=strfind(par.deflin,'syntax');
		im=cellfun(@numel,par.ftok(:,2));
		s{par.shdr}(ix+im-1)='|';
	else
		s=s(1);
	end
		p.def=sr;
		par.res=s;
end
function	p=FARG_get_context(p,par,fe,isclosed)
	if	isclosed
		lexstp=par.lexstp;
		par.lexstp{3}=''')''';
	end
		sub=p.(fe);
		[ib,ib]=ismember(sub.bx.',par.lex(:,1:2),'rows');	%#ok
		[ie,ie]=ismember(sub.ex.',par.lex(:,1:2),'rows');	%#ok
	for	ibx=1:numel(ib)
		nb=0;
	for	ix=ib(ibx):-1:1
	if	isclosed
	if	any(ismember(par.ltok{ix,2},lexstp))
		ib(ibx)=ix+1;
		break;
	end
	else
		nb=nb+any(ismember(par.ltok{ix,2},par.lexbre));
	if	nb>0
		nb=nb-any(ismember(par.ltok{ix,2},par.lexbrb));
	elseif	~nb
		im=any(ismember(par.ltok{ix,2},par.lexstp));
	if	im
		ib(ibx)=ix+1;
		break;
	end
	end
	end
	end
	end
	for	ibx=1:numel(ie)
	for	ix=ie(ibx):par.nlex
		im=any(ismember(par.ltok{ix,2},par.lexstp));
	if	im
		ie(ibx)=ix-1;
		break;
	end
	end
	end
		sub.lx=[ib(:).';ie(:).'];
	if	isclosed
		[sub.lx,ix]=sortrows(sub.lx.');
		sub.fn=sub.fn(ix);
		sub.fd=sub.fd(ix);
		sub.lx=sub.lx.';
		sub.bx=sub.bx(:,ix);
		sub.ex=sub.ex(:,ix);
	end
		p.(fe)=sub;
end
function	ss=FARG_set_context(p,par,fe)
		ss=cell(p.(fe).nx,1);
	for	i=1:p.(fe).nx
		dtok=par.ltok(p.(fe).lx(1,i):p.(fe).lx(2,i),:);
		ix=~strncmp('<STRING>',dtok(:,1),8);
		ie= strncmp('<EOL>',dtok(:,1),5);
		iz=cellfun(@numel,dtok(:,1))==1;
		ix=xor(ix,iz);
		a=par.ltok(p.(fe).lx(1,i):p.(fe).lx(2,i),2);
		a(ix)=regexprep(a(ix),'^['']','');
		a(ix)=regexprep(a(ix),'['']$','');
		a(ie)={';'};
		a=sprintf('%s',a{:});
		a=strrep(a,'...','');
		a=strrep(a,''':'':''',':');
		ix=ismember(a,par.wspace);
		a(ix)='';
		ix=find(a=='@',1,'first');
	if	~isempty(ix)
		ix=find(a(ix:end)==')')+ix-1;
		a=[a(1:ix),' ',a(ix+1:end)];
	end
		ss{i}=FARG_set_bracket(a);
	end
end
function	s=FARG_set_bracket(s)
		br={
			'[]'	1
			'()'	2
			'{}'	3
		};
		ba=cell(size(br,1),1);
	for	i=1:size(br,1)
		bb=strfind(s,br{i,1}(1));
		be=strfind(s,br{i,1}(2));
		k=zeros(size(s));
		k(bb)=ones(size(bb));
		k(be)=-ones(size(be));
		k=cumsum(k);
		k=[k(end:-1:1),0];
	if	k(1) > 0
		bc=br{i,2}*ones(2,k(1));
	for	j=1:k(2)
		bc(1,j)=find(k(1:end-1)==j&k(2:end)==j-1,1,'first');
	end
		ba{i}=bc;
	end
	end
		ba=cat(2,ba{:});
	if	~isempty(ba)
		ba(1,:)=numel(s)-ba(1,:)+1;
		bc=sortrows(ba.',-1).';
		bc=bc(2,:);
		r=char(1:numel(bc)-1);
	for	i=1:size(br,1)
		r(bc==br{i,2})=br{i,1}(2);
	end
		s=[s,r];
	end
end
function	[p,par,s]=FARG_set_text(p,par,mode)
	if	par.opt.Sflg
		return;
	end
	switch	mode
	case	1
		par.txt(1,1)={
			sprintf('%s parsing...          %s',par.bol,par.wnam)
		};
		FARG_sdisp(par,char(par.txt));
		par.rt=clock;
		return;
	case	2
		par.rt=etime(clock,par.rt);
		par.txt(2,1)={
			sprintf('%s done                %.4f sec',par.bol,par.rt)
		};
	if	~par.lint.ferr				&&...
		par.opt.wflg				&&...
		par.lint.nerr
		nl=max(cellfun(@numel,par.lint.err));
		par.res=[
			par.res
			{
				sprintf('\n%s WARNINGS',par.bol)
				repmat('-',1,nl)
			}
			par.lint.err
		];
	end
		par.res=char(par.res);
	if	~par.flg
		FARG_sdisp(par,char(par.txt(2:end,1)));
		FARG_sdisp(par,char(par.res));
	else
		par.res=char(par.txt);
		FARG_sdisp(par,par.res(1+p.par.opt.sflg:end,:));
	end
		return;
	case	3
		par.txt=[
			par.txt
			{
			'DONE'
			sprintf('');
			}
		];
	if	~isempty(par.pnam)
		pc=par.pnam;
	else
		pc='';
	end
		nu=numel(unique(p.U.fd));
		s=cell(par.nfun+par.shdr,1);
	if	par.mp(3)
		ftype=par.ftyp{3};
	else
		ftype=par.ftyp{sign(par.mfun)+1};
	end
		s{1}={
			sprintf('%s MATLAB version  :   %s',par.bol,par.MLver)
			sprintf('%s %.4s   version  :   %s',par.bol,par.magic,par.fver)
			sprintf('%s run    date     :   %s',par.bol,par.rundate)
			sprintf('%s',par.bol);
			sprintf('%s FILE            :   %s',par.bol,par.wnam)
			sprintf('%s - Pcode         :   %s',par.bol,pc)
			sprintf('%s - type          :   %s',par.bol,ftype)
			sprintf('%s - date          :   %s',par.bol,par.dnam.ds{1})
			sprintf('%s - time          :      %s',par.bol,par.dnam.ds{2})
			sprintf('%s - size          :   %11d   bytes',par.bol,par.dnam.bytes)
			sprintf('%s - LEX tokens    :   %11d',par.bol,par.nlex)
			sprintf('%s   - lines       :   %11d',par.bol,par.nlen)
			sprintf('%s   - comments    :   %11d /           %.2f %%',par.bol,par.ncom,100*par.ncom/par.nlen)
			sprintf('%s   - empty       :   %11d /           %.2f %%',par.bol,par.nemp,100*par.nemp/par.nlen)
			sprintf('%s   - warnings    :   %11d',par.bol,par.lint.nerr)
			sprintf('%s   - complexity  :   %11d   max',par.bol,par.lint.mcyc);
			sprintf('%s - calls         :   %11d',par.bol,sum(p.n))
			sprintf('%s   - stock/user  :   %11d / unique    %-1d',par.bol,p.U.nx,nu)
			sprintf('%s - functions     :   %11d',par.bol,par.nfun)
			sprintf('%s   - main        : %c %11d / recursion %-1d',par.bol,par.ftok{1,1},p.M.nx,p.R.nx)
			sprintf('%s   - subroutines : %c %11d',par.bol,par.ftok{2,1},p.S.nx)
			sprintf('%s   - nested      : %c %11d',par.bol,par.ftok{3,1},p.N.nx)
			sprintf('%s   - anonymous   : %c %11d',par.bol,par.ftok{4,1},p.A.nx)
			sprintf('%s   - eval        : %c %11d',par.bol,par.ftok{7,1},p.E.nx)
			sprintf('%s   - unresolved  : %c %11d',par.bol,par.ftok{5,1},p.X.nx)
		};
		s{1}=char(s{1});
	if	par.nfun
			ctok=strrep(par.fmtcmp,'d','s');
			ctok=sprintf(ctok,'C');
			par.deflin=sprintf('%s     #|line      : T  %s  syntax',...
				par.bol,ctok);
		s{2}={
			sprintf('%s',par.bol)
			sprintf('%s FUNCTIONS',par.bol)
			par.deflin
		};
		s{2}=char(s{2});
		s{par.shdr}='x';
	end
	end
end
function	FARG_sdisp(par,txt)
	if	par.opt.sflg
		disp(txt);
	end
end
function	s=FARG_show_entries(p,varargin)
		ades=p.des(1:end-1);
	if	nargin > 1
		ix=ismember(lower(ades),lower(varargin));
	else
		ix=true(1,numel(ades));
	end
		ades=p.des(ix);
	if	isempty(ades)
		return;
	end
		s=cell(sum(p.n(ix))+numel(ades),1);
		p.A.fd=repmat({''},p.A.nx,1);
		oa=p.A;
		p.A.fn=p.A.fd;
		sm=-inf;
	for	i=ades(:).'
		sm=max([sm;max(cellfun(@numel,p.(i{:}).fn))]);
	end
		p.A=oa;
		ffmt=sprintf('%%%%%%%% -   %%-%d.%ds > %%s',sm,sm);
		afmt=sprintf('%%%%%%%% -   %%s%%s');
		ix=0;
	for	i=1:numel(ades)
		ix=ix+1;
		cd=ades{i};
		s{ix}=sprintf('%%%% %s %d',cd,p.(cd).nx);
	if	cd == 'A'
		fmt=afmt;
	else
		fmt=ffmt;
	end
	for	j=1:p.(cd).nx
		ix=ix+1;
		s{ix}=sprintf(fmt,p.(cd).fn{j},p.(cd).fd{j});
	end
	end
	if	~nargout
		disp(char(s));
		clear	s;
	end
end
%-------------------------------------------------------------------------------
%$SSC_INSERT_END   21-Jun-2010/02:16:53   F:/usr/matlab/tmp/fex/afarg/ver2010/farg.m
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%
% DETAB		a FEX file
% created:
%	us	21-Apr-1992
%
% download the latest standalone including help/comments from
% http://www.mathworks.com/matlabcentral/fileexchange/10536
%
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%$SSC_INSERT_BEG   21-Jun-2010/02:16:53   F:/usr/matlab/unix/detab.m
%-------------------------------------------------------------------------------
% SSC automatic file insertion utility
%     - us@neurol.unizh.ch [ver 26-Apr-2010/00:48:30]
%     - all empty spaces and comments are stripped for brevity
%     - original code available upon request
%-------------------------------------------------------------------------------
function	[ss,p]=detab(cstr,varargin)
		magic='DETAB';
		pver='04-Jul-2008 20:35:47';
		ss=[];
		p=[];
		fnam='CELL';
		deftlen=8;
		deftchar=' ';
		otmpl={
		'-t'	true	1	deftlen		'tab length in char'
		'-c'	true	1	deftchar	'tab end marker'
		'-l'	false	0	[]		'show listbox'
		'-lp'	false	1	{}		'listbox parameters'
		};
	if	nargin < 1
		help(mfilename);
		return;
	end
		[opt,par]=DETAB_get_par(otmpl,varargin{:});
	if	ischar(cstr)
		fnam=which(cstr);
	if	~exist(cstr,'file')
		disp(sprintf('DETAB> file not found <%s>',fnam));
		return;
	end
		[fp,msg]=fopen(fnam,'rb');
	if	fp < 0
		disp(sprintf('DETAB> cannot open file <%s>',fnam));
		disp(sprintf('       %s',msg));
		return;
	end
		cstr=textscan(fp,'%s',...
			'delimiter','\n',...
			'whitespace','');
		fclose(fp);
		cstr=cstr{:};
	elseif	~iscell(cstr)
		disp('DETAB> input must be a file name or a cell');
		return;
	end
		tab=sprintf('\t');
		p.magic=magic;
		p.([magic,'ver'])=pver;
		p.MLver=version;
		p.rundate=datestr(clock);
		p.runtime=clock;
		p.par=par;
		p.opt=opt;
		p.input=fnam;
		p.cs=size(cstr);
		p.ns=numel(cstr);
		p.nc=0;
		p.nl=0;
		p.nt=0;
		cstr=cstr(:);
		ix=cellfun('isclass',cstr,'char');
		p.nc=sum(ix);
	if	~p.nc
		ss=cstr;
		return;
	end
		ss=cstr(ix);
		tmax=max(cellfun('length',ss));
		tlen=p.opt.t.val;
		tt=tlen:tlen:tmax*tlen;
		p.par.tab=repmat(['.......',p.par.tc],1,ceil(tmax/tlen));
		ttb=sprintf('TAB=%-1d',tlen);
		p.par.tab(1:length(ttb))=ttb;
		p.runtime=clock;
	for	i=1:p.nc
		s=ss{i};
		tp=strfind(s,tab);
	if	~isempty(tp)
		nt=numel(tp);
		p.nl=p.nl+1;
		p.nt=p.nt+nt;
		tn=1:nt;
		tm=tt(tn);
		tx=tm-tp+tn;
		tx(end)=[];
		tx=[0,tx]+tp-tn;
		tx=tm-tx;
		tx=mod(tx-1,tlen)+1;
		tx=p.par.t(tx);
		ss{i,1}=regexprep(s,'\t',tx,'once');
	end
	end
		p.runtime=etime(clock,p.runtime);
		cstr(ix)=ss;
		ss=reshape(cstr,p.cs);
		
	if	p.opt.l.flg
		blim=.005;
		clf;
		shg;
		p.par.uh=uicontrol('units','norm',...
			'position',[blim,blim,1-2*blim,1-2*blim],...
			'style','listbox',...
			'max',2,...
			'fontname','courier new',...
			'backgroundcolor',1*[.75 1 1],...
			'foregroundcolor',[0 0 1],...
			'tag',p.magic,...
			p.opt.lp.val{:});
		sh=char([{p.par.tab};ss(ix)]);
		set(p.par.uh,'string',sh);
	end
end
function	[opt,par]=DETAB_get_par(otmpl,varargin)
		par.t=[];
		par.tab=[];
		narg=nargin-1;
	for	i=1:size(otmpl,1)
		[oflg,val,arg,dval]=otmpl{i,1:4};
		flg=oflg(2:end);
		opt.(flg).flg=val;
		opt.(flg).val=dval;
		ix=strcmp(oflg,varargin);
		ix=find(ix,1,'last');
	if	ix
		opt.(flg).flg=true;
	if	arg
	if	narg >= ix+arg
		opt.(flg).val=varargin{ix+1:ix+arg};
	else
		opt.(flg).flg=val;
	end
	end
	end
	end
		tlen=opt.t.val;
		par.t=cell(tlen,1);
	for	i=1:tlen
		par.t{i,1}=sprintf('%*s',i,opt.c.val);
	end
	if	~isempty(opt.c.val)	&&...
		~isspace(opt.c.val)
		par.tc=opt.c.val;
	else
		par.tc=char(166);	% <¦>
	end
		par.uh=[];
end
%-------------------------------------------------------------------------------
%$SSC_INSERT_END   21-Jun-2010/02:16:53   F:/usr/matlab/unix/detab.m
%--------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%
% FDEP
% additional help sections
%
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%@LISTHELP_BEG
% FDEP	version 21-Jun-2010 02:16:53
%
% the ML-file under investigation is the
%	root function = MAIN module
% a module is a user-defined ML-file living outside the root function
%	in a folder, which is part of ML's search path
% a module may be a ML-function (M- or P-file), a ML-script (M-file), or
%	a MEX/DLL-file (listed as P-file with correct extension)
% functions, which are called by an individual module, are grouped into
%	- main function
%	- subfunctions
%	- nested functions
%	- anonymous functions
%	- eval class calls
%	- unresolved calls
%	- ML stock functions
%	- ML built-in functions
%	- ML classes
%	- ML toolboxes
% most panels have tooltips
%
% all windows have a floating list with buttons for
%	- quit			closes the current window
%	- font -		makes the fontsize smaller by 1 point
%	- font +		makes the fontsize larger  by 1 point
%	- help			shows this help in a window
%	- manager		shows the window manager if there is more than
%				  one FDEP associated window open
%				- contains a list of all open FDEP windows
%				- clicking on an entry will bring its window
%				  to the top
%	- list			shows the modules listing window
%	- matrix		shows the dependency matrix window
%	- tree			shows the runtime and modules tree
%	- home			jumps to the top of a single module window
%
%	changing the window size may cause the button list to disappear until
%	it is resized again
%
% modules
%-------------------------------------------------------------------------------
%	a list of all modules, which are called by the MAIN module
%	the MAIN module is always on top of the list, all other modules are
%	   sorted in alphabetical order and show information in 3 columns
%		1	# of the module
%			- this number must be used for command line access of
%			  numeric module information by the macros
%				p.find(M#,...);
%				p.get(M#,...);
%				p.FDEP_mlist(M#);
%				p.list(M#,...);
%				p.plot([Mx/My],...);
%		2	name of the module
%		3	special attributes of the module
%				R: module calls itself (recursive)
%				E: module uses an EVAL/EVALIN/EVALC/FEVAL construct
%				S: module is a SCRIPT
%				P: module is or has a P-file
%	CLICKING on a name activates the module
%
% main function
%-------------------------------------------------------------------------------
%	shows a synopsis of the MAIN module including a summary of the calls of
%	   all its modules for each group of ML functions, version information,
%	   and the runtime
%	CLICKING in this box will activate the MAIN module
%
% toolboxes
%-------------------------------------------------------------------------------
%	shows a list of all toolboxes that are used by the modules
%	those that are used by the currently selected module are highlighted
%	toolboxes are shown with their official name, version, and folder name
%	CLICKING on a toolbox name highlights in the modules list
%		those modules, which use the toolbox
%
% module summary
%-------------------------------------------------------------------------------
%	shows the summary of the current module including its attributes and
%	   the exact number of calls for each group of functions
%	all function group entries are sorted
%	all calls found in the function are shown in sequence and may be
%	   repeated (same call in different subfunctions)
%	if both M- and P-FILE names are shown, the M-file is used
%	   to extract all data, but the P-FILE will be called during runtime
%	if only a P-FILE name is shown (standalone), only ML entities
%	   can be extracted due to the limitations of MLINT
%	to retrieve this information from the command window, use macro
%		p.find(M1,...);
%	CLICKING on the first line will show the full synopsis in a window
%	to show the full synopsis from the command window, use macro
%		p.mhelp(M1,...);
%
% calls  TO
%-------------------------------------------------------------------------------
%	shows all modules that the current module calls
%	CLICKING on a name activates the module in <modules> and shows its
%	   content
%
% called FROM
%-------------------------------------------------------------------------------
%	shows all modules that call the current module
%	CLICKING on a name activates the module in <modules> and shows its
%	   content
%
% subfunctions
%-------------------------------------------------------------------------------
%	shows subfunctions of the current module in the format
%		M(line#): function name > definition of MAIN/first function
%		S(line#): function name > definition of subfunction
%	this box is only filled, if the module is a ML function
%	CLICKING on a name opens the module in the editor at its line
%
% nested / anonymous functions
%-------------------------------------------------------------------------------
%	shows function definitions of the current module in the format
%		A(line#): definition of anonymous function
%		N(line#): definition of nested    function
%	CLICKING on a name opens the module in the editor at its line
%
% font - / font +
%-------------------------------------------------------------------------------
%	utility in honor of John D'errico, a senior and most respected
%	   FEX and CSSM contributor, with very poor eyesight
%	CLICKING on the button will change the fontsize by -1/1 point
%
% EDIT
%-------------------------------------------------------------------------------
%	opens the current module in the editor
%
% DEPENDENCY MATRIX
%-------------------------------------------------------------------------------
%	displays the dependency matrix of the MAIN module
%
% HELP
%-------------------------------------------------------------------------------
%	shows this help in a window
%	to show this help from the command window, use macro
%		p.help();	displays content in a window
%		p.help(1);	displays content in the command window
%
%@LISTHELP_END
%-------------------------------------------------------------------------------