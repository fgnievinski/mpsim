site = struct();
site.lat = 10.0;  % in decimal degrees
site.lon = -15.0;  % in decimal degrees
site.h = 0;  % in meters
site.code = 'abcd';  % DEM filename needs to be code.zip, e.g., abcd.zip

crop_width = [500, 200, 100];  % in meters

cmap = {'dkbluered', 'jet'};  % (colormaps)

dem_dir = 'c:\work\data\dem'  % change as appropriate

dem = do_dem_aux (site, crop_width, cmap, [], [], [], dem_dir);

