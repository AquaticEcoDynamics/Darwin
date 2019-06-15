% /////// myimage ///////
% Read in georeferenced raster image and plot onto specified axes
% Raster image can be of many formats
% Georeferencing information must exist in form .wld, .jpw, .KML or .tab (Map Info)
%
% inputs
%   ax = axes to plot georeferenced image onto
%   imgfil = .tab (.'raster' must exist in same diectory) or .jpg (.jpw / .wld / .KML) must exist in same directory
%
% outputs
%   h = handle to image object
%
% Clara Boutin & Jesper Nielsen (last updated to handle rotated images 08/04/2014)

function h = myimage(ax,imgfil)

% warnings
cmod = get(ax,'CLimMode');
switch cmod
    case 'manual'
        display('WARNING CLim will be reset')
    case 'auto'
        % No problemo
end

% .tab or .jpg
tabme = false;
jpgme = false;
[~,~,ext]=fileparts(imgfil);
switch lower(ext)
    case '.tab'
        tabme = true;
    case {'.jpg'}
        jpgme = true;
    otherwise
        error('imgfil must be either .tab or .jpg format')
end
        
% read in the image
if tabme
    [img, xlim, ylim] = read_raster_tab(imgfil);
elseif jpgme
    [img, xlim, ylim] = read_raster_jpg(imgfil);
end

% plot the image
h = imagesc('Cdata',img,'XData',xlim,'YData',ylim,'Parent',ax,'Tag','image');


% ======== nested functions ===============================================
%
% /////// read_raster_jpg ///////
% reads in .jpg file, finds the .jpw or .wld and outputs the info for imagesc.m
% 
% inputs
%   imgfil = .jpg file
%
% outputs
%   IMG = array of image data
%   xlim = limits of image on x-axis
%   ylim = limits of image on y-axis

function [img, xlim, ylim] = read_raster_jpg(imgfil)

display('this part of the code needs to be updated to handle rotated images')
display('georeferencing your image with a .tab file will work')

% -- track down georeferencing
fid = fopen(strrep(lower(imgfil),'.jpg','.jgw'));
if fid == -1
    fid = fopen(strrep(lower(imgfil),'.jpg','.wld'));
end
if fid == -1
        fid = fopen(strrep(lower(imgfil),'.jpg','.KML'));
        C = textscan(fid,'%s','HeaderLines',9);
        fclose(fid);
        C{1}=strrep(C{1},'<north>','');
        C{1}=strrep(C{1},'</north>','');
        C{1}=strrep(C{1},'<south>','');
        C{1}=strrep(C{1},'</south>','');
        C{1}=strrep(C{1},'<east>','');
        C{1}=strrep(C{1},'</east>','');
        C{1}=strrep(C{1},'<west>','');
        C{1}=strrep(C{1},'</west>','');
        
        ylim(2) = str2double(C{1}(1));    %C
        ylim(1) = str2double(C{1}(2));    %F
        xlim(2) = str2double(C{1}(3));    %C
        xlim(1) = str2double(C{1}(4));    %F
        
        [xlim(1),ylim(1),grid] = ll2utm(xlim(1),ylim(1));
        [xlim(2),ylim(2),grid] = ll2utm(xlim(2),ylim(2));
                
        img = imread(imgfil);
        img = flipdim(img,1);
else
C = textscan(fid,'%f','HeaderLines',0);
fclose(fid);

pixel_x = C{1}(1);    %A see wikipedia
rot_y = C{1}(2);      %D
rot_x = C{1}(3);      %B
pixel_y = C{1}(4);    %E
xlim(1) = C{1}(5);    %C
ylim(2) = C{1}(6);    %F

% -- read in image
img = imread(imgfil);
pix = size(img);
xlim(2) = xlim(1) + pixel_x * pix(2) + rot_x * pix(1);
ylim(1) = ylim(2) + pixel_y * pix(1) + rot_y * pix(2);

img = flipdim(img,1);
end

% /////// read_raster_tab ///////
% analogus to read_raster_jpg
function [imagerot, xlim, ylim] = read_raster_tab(imgfil)

% find your image file
[pat, ~, ~] = fileparts(imgfil);

fid = fopen(imgfil);
k = 1;
while ~feof(fid)
    line = fgetl(fid);
    if ~isempty(strfind(line,'File'))
        rasfil = strrep(line,'File','');
        rasfil = strrep(rasfil,'"','');
        rasfil = strtrim(rasfil);
        gid = fopen(fullfile(pat,rasfil));
        if gid == -1
            error('raster file must exist in same directory as .tab file')   % avoid linux / windows path mixup as MI is windows and Matlab could be Linux
        else
            fclose(gid);
        end
    end
    if ~isempty(strfind(line,'('))
        ibl = strfind(line,'(');
        ibr = strfind(line,')');
        str1 = line(ibl(1)+1:ibr(1)-1);
        str2 = line(ibl(2)+1:ibr(2)-1);
        coords(k,:) = str2num(str1);
        pixels(k,:) = str2num(str2);
        k = k+1;
    end
    if ~isempty(strfind(line,'CoordSys'))
        break
    end
end
fclose(fid);

% -- read in image
imagepad = imread(fullfile(pat,rasfil));
imagepad = flipdim(imagepad,1);
[nrows,ncols,~] = size(imagepad);

% determine x & y limits
% -- x coordinate
x = pixels(:,1);
y = pixels(:,2);
z = coords(:,1);
tmp = [x y z]';
out = fitplane(tmp);
a = out(1);
b = out(2);
c = out(3);
d = out(4);

corner(1,1) = -1/c * (a*1 + b*nrows + d);     % top left
corner(2,1) = -1/c * (a*1 + b*1 + d);         % bot left
corner(3,1) = -1/c * (a*ncols + b*0 + d);     % bot right
corner(4,1) = -1/c * (a*ncols + b*nrows + d); % top right

% -- y coordinates
z = coords(:,2);
tmp = [x y z]';
out = fitplane(tmp);
a = out(1);
b = out(2);
c = out(3);
d = out(4);

corner(1,2) = -1/c * (a*1 + b*nrows + d);     % top left
corner(2,2) = -1/c * (a*1 + b*1 + d);         % bot left
corner(3,2) = -1/c * (a*ncols + b*1 + d);     % bot right
corner(4,2) = -1/c * (a*ncols + b*nrows + d); % top right

xlim = [min(corner(:,1)) max(corner(:,1))];
ylim = [min(corner(:,2)) max(corner(:,2))];

% determine the required rotation
dy = corner(3,2) - corner(2,2);
dx = corner(3,1) - corner(2,1);
phi = atan(-dy/dx);


% !!!!!! THIS BIT OF THE CODE HAS BEEN PILFERED FROM THE STACKOVERFLOW
% WEBSITE. THE POST BELONGS TO chappjc Oct 30 2013 (thanks)
midx=ceil((ncols+1)/2);
midy=ceil((nrows+1)/2);

Mr = [cos(phi) sin(phi); -sin(phi) cos(phi)];

% rotate about center
[X,Y] = meshgrid(1:ncols,1:nrows);
XYt = [X(:)-midx Y(:)-midy]*Mr;
XYt = bsxfun(@plus,XYt,[midx midy]);

xout = round(XYt(:,1));
yout = round(XYt(:,2)); % nearest neighbor!
outbound = yout<1 | yout>nrows | xout<1 | xout>ncols;
zout=repmat(cat(3,1,2,3),nrows,ncols);
zout=zout(:);
xout(xout<1) = 1; xout(xout>ncols) = ncols;
yout(yout<1) = 1; yout(yout>nrows) = nrows;
xout = repmat(xout,[3 1]);
yout = repmat(yout,[3 1]);
imagerot = imagepad(sub2ind(size(imagepad),yout,xout,zout(:))); % lookup
imagerot = reshape(imagerot,size(imagepad));
imagerot(repmat(outbound,[1 1 3])) = 1; % set background value to [1 1 1] (white)



