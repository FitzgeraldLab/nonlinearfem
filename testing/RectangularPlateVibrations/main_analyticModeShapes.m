%% Plate mode shapes
%%
clear all;
close all;
clc;

gmsh_exe = 'c:\Users\tim\Downloads\gmsh-2.8.5-Windows\gmsh.exe';

%%
% Lx = 2;
% Ly = 3;
% Lz = 0.05;
% 
% 
% Nmodes = 3;
% 
% 
% tempfile = 'temp';
% nel_x  = 2;
% nel_y = 3;
% nel_z = 1;
% 
% %% Make a new FEM mesh
% 
% if( gen_plate_geo( Lx, Ly, Lz, nel_x, nel_y, nel_z, [tempfile,'.geo']) ~= 0 )
%     error('Cannot make geo file...');
% end
% 
% cmd = sprintf('%s -3 %s', gmsh_exe, [tempfile,'.geo']);
% if( system(cmd) ~= 0 )
%     error('Cannot GMSH the geo file');
% end

%%
a = 1.5;
b = 1;
nu = 0.3;
BC_x = 'SS';
BC_y = 'CC';

m_list = [2,3,4];
n_list = [2,3,4];
lambda = zeros(length(m_list), length(n_list));
for i = 1:length(m_list)
    for j = 1:length(n_list)
        lambda(i,j) = plate_naturalfreq( a, m_list(i), b, n_list(j), BC_x, BC_y, nu);
    end
end
lambda*(b/a)^2

% pretty much matches Meirovitch 

