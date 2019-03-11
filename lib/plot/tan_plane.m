function [tan_p] = tan_plane(f,Xo,type)
% TAN_PLANE Tangent plane of a surface and its graph
%   TAN_PLANE(FUN,XO,TYPE) plots a surface FUN of TYPE:'explicit',
%   'parametric' or 'implicit' and its tangent plane at point XO (which
%    belongs to the surface FUN). FUN is a string (could be symbolic too)
%   , which depends on "x", "y" (and "z", if it is implicit) or parameters
%   "u" and "v" (parametric)
%
%   Example: 
%   tan_plane('3*x^2+3*y^4-15',[3,2],'explicit')
%   tan_plane('[u*v ; u^2-v^2+1; 3+u]',[2,2],'parametric')
%   tan_plane('x^2+y-z^2-4',[2,1,1],'implicit')
%   
%   Note:
%   *Almost there's not error detection at all, so you are expected to give
%   the correct values for input.
%   *Because "tan_plane" use Matlab function "ezsurf", Xo must be in the
%   interval [-2PI, 2PI], to visualize correctly the tangent plane.
%   *You must have the file EZIMPLOT3 in the path, function that plots
%   implicit 3D functions (Download it from MFX). 
%
%   Last Modified: 9/5/2009 
%   By Ing. Gustavo Morales. Physics Department - Engineering Faculty
%   University of Carabobo, Venezuela.
%
switch type
    case 'explicit'
        X = [sym('x','real'); sym('y','real')]; % column vector with the variables
    case 'parametric'
        X = [sym('u','real'); sym('v','real')];
    case 'implicit'
        X = [sym('x','real'); sym('y','real');sym('z','real')];
end
Xo = Xo(:); % ensuring Xo is a column vector
f = sym(f);                         % Converting f to symbolic
try
    %fo = subs(f, X, Xo);                % f evaluated at Xo
    %fo = subs(subs(f, X(1),Xo(1)), X(2),Xo(2));      % f evaluated at Xo
    fo = double(subs(f, {X(1),X(2)},{Xo(1),Xo(2)}));      % f evaluated at Xo
catch ME
    error('Tan_plane:Arguments','Verify correspondence between function type and number of elements of Xo');
end
% If point Xo not belongs to implicit surface:
if strcmp(type,'implicit') &&  fo ~= 0
   error('Tan_plane:Arguments','Xo not belongs to surface %s. Try with another Xo', char(f));
end
%dF = subs(jacobian(f, X), X, Xo);   % Jacobian of f with respect to
%dF = subs(subs(jacobian(f, X), X(1),Xo(1)), X(2),Xo(2));   % Jacobian of f with respect to
dF = double(subs(jacobian(f, X), {X(1),X(2)},{Xo(1),Xo(2)}));      % f evaluated at Xo
                                    % [x, y] evaluated at Xo
tan_p = fo + dF*(X-Xo);            % approximant affine transformation
%Sending symbolic expresions to EZSURF and EZIMPLOT3
if strcmp(type,'explicit')
   h_p = ezsurf(char(tan_p));
   set(h_p,'FaceColor','b','EdgeColor','none'); %Tangent plane is "blue"              
   hold on                         
   h_s = ezsurf(char(f));
   set(h_s,'FaceColor','r','EdgeColor','none'); %Function is "red"
   alpha(0.7), camlight, lighting gouraud %Additional adjustments
   plot3(Xo(1),Xo(2),fo,'o');
elseif strcmp(type,'parametric')
   h_p = ezsurf(char(tan_p(1)),char(tan_p(2)),char(tan_p(3)));
   set(h_p,'FaceColor','b','EdgeColor','none');  %Tangent plane is "blue"   
   hold on
   h_s = ezsurf(char(f(1)),char(f(2)),char(f(3)));  
   set(h_s,'FaceColor','r','EdgeColor','none');  %Function is "red"
   alpha(0.7), camlight, lighting gouraud %Additional adjustments
   plot3(fo(1),fo(2),fo(3),'o');
else
   ezimplot3(tan_p,'b');
   hold on
   ezimplot3(f,'r');
   plot3(Xo(1),Xo(2),Xo(3),'o');
end
axis vis3d
