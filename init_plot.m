% Select the desired type of visualization:
vis_type = 'screen';
%vis_type = 'slides';
%vis_type = 'article';

switch vis_type
case 'screen',   set(0, 'DefaultAxesFontSize',12);  mysaveas_enable();  mysaveas ([], 'png', [], [], img_dir)
case 'article',  set(0, 'DefaultAxesFontSize',16);  mysaveas_enable();  mysaveas ([], 'epsc2', 8.4, 600);
case 'slides',   set(0, 'DefaultAxesFontSize',14);  mysaveas_reset();
end

if is_octave()
  mysaveas (false)
  graphics_toolkit('gnuplot')  % lower quality but more reliable
  %graphics_toolkit('qt')  % better quality but gives errors
end

mysubplot = @(m,n,p) subtightplot(m, n, p, 0.0015, [0.1 0.025], [0.105 0.015]);
myplot = @plotsin;  myxlim = @xlimsin;

%mysubplot = @subplot;  %myplot = @plot;  myxlim = @xlim;
