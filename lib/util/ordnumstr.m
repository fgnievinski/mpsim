function ordnum = ordnumstr(number, includenumber)
% ORDNUMSTR(NUMBER) accepts a floating point number and appends a
% suitable suffix to form the ordinal numeral for the input (in English).  
% 
% ORDNUMSTR(NUMBER, 0) simply returns the suffix.
% 
% WARNING: The correct suffix in the case of non-integers is likely to stir
% up as much heated debate as 'what is best: emacs or vi?'.  This function
% takes the last digit as the suffix generator, so that 81.3 becomes
% 81.3rd.  The alternative would be to use the last digit before the
% decimal place to give 81.3st, but in my mind "threest" doesn't sound
% good.  If you prefer the latter, then replace line 42 with line 43 and
% line 62 with line 63.
% 
% Examples: 
% pos = 43;
% ['Jim came ' ordnumstr(pos) ' in the race']
% ans =
% Jim came 2nd in the race
% 
% prc = 81.3;
% ['Harry''s test results were in the ' ordnumstr(prc) ' percentile']
% ans =
% Harry's test results were in the  81.3rd percentile
% 
% sprintf(['Harry''s test results were in the %5.2f' ordnumstr(prc, 0) ' percentile'], prc)
% ans = 
% Harry's test results were in the 81.30rd percentile
% 
% $ Author: Richie Cotton $     $ Date: 2008/07/30 $

if nargin < 1 || isempty(number) || ~isnumeric(number) ...
      || ~isreal(number) || ~isscalar(number)
   error('ordnumstr:badinput', ...
      'ordnumstr requires a real numeric scalar input.');
end

if nargin < 2 || isempty(includenumber)
   includenumber = 1;
end

str = num2str(number);
% str = sprintf('%d', fix(number));

if any(rem(number-[11 12 13], 100)==0)
   ordnum = 'th';
else  
   last = str(end);
   switch(last)
      case '1'
         ordnum = 'st';
      case '2'
         ordnum = 'nd';
      case '3'
         ordnum = 'rd';
      otherwise
         ordnum = 'th';
   end
end

if includenumber
   ordnum = [str ordnum];
%    ordnum = [num2str(number) ordnum];
end