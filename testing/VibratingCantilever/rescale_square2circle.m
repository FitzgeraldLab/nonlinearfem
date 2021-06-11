function [yp,zp] = rescale_square2circle(y,z,Ly, Lz)

%%
r = y/Ly*2;
s = z/Lz*2;


%% 
% From https://www.xarg.org/2017/07/how-to-map-a-square-to-a-circle/
R = r .* sqrt( 1 - s.^2/2 );
S = s .* sqrt( 1 - r.^2/2 );

yp = Ly*R;
zp = Lz*S;
