function fid = gen_plate_geo( L_x, L_y, L_z, nel_x, nel_y, nel_z, filename)

%% Gen the file text
str = [...
'// Flexible Plate', '\n', ...
'', '\n', ...
'//-----------------------------------------', '\n', ...
'// Define Parameters', '\n', ...
sprintf('L_x = %f; // X direction', L_x), '\n', ...
sprintf('L_y = %f; // Y direction', L_y), '\n', ...
sprintf('L_z = %f; // Z direction', L_z), '\n', ...
'', '\n', ...
'', '\n', ...
'// Number of elements in each direction', '\n', ...
sprintf('Nx = %d;', round(nel_x) ), '\n', ...
sprintf('Ny = %d;', round(nel_y) ), '\n', ...
sprintf('Nz = %d;', round(nel_z) ), '\n', ...
'', '\n', ...
'//-----------------------------------------', '\n', ...
'// GMSH Options', '\n', ...
'Geometry.PointNumbers = 1;', '\n', ...
'Geometry.LineNumbers = 1;', '\n', ...
'Geometry.SurfaceNumbers = 1;', '\n', ...
'', '\n', ...
'Mesh.ElementOrder = 2;', '\n', ...
'Mesh.Algorithm = 6;', '\n', ...
'Mesh.Algorithm3D = 4;', '\n', ...
'Mesh.Smoothing = 2;', '\n', ...
'Mesh.SecondOrderLinear = 0;', '\n', ...
'Mesh.PointNumbers = 1;', '\n', ...
'', '\n', ...
'//-----------------------------------------', '\n', ...
'// Geometry', '\n', ...
'//', '\n', ...
'// Define base points, lines and surface', '\n', ...
'Point(1) = {    0,  -L_y/2, -L_z/2};', '\n', ...
'Point(2) = {  L_x,  -L_y/2, -L_z/2};', '\n', ...
'Point(3) = {  L_x,   L_y/2, -L_z/2};', '\n', ...
'Point(4) = {    0,   L_y/2, -L_z/2};', '\n', ...
'Line(1) = {1, 2};', '\n', ...
'Transfinite Line{1} = Nx+1;', '\n', ...
'Line(2) = {2, 3};', '\n', ...
'Transfinite Line{2} = Ny+1;', '\n', ...
'Line(3) = {3, 4};', '\n', ...
'Transfinite Line{3} = Nx+1;', '\n', ...
'Line(4) = {4, 1};', '\n', ...
'Transfinite Line{4} = Ny+1;', '\n', ...
'Line Loop(1) = {1, 2, 3, 4};', '\n', ...
'Plane Surface(1) = {1};', '\n', ...
'Transfinite Surface{1} = {1,2,3,4};', '\n', ...
'Recombine Surface {1};', '\n', ...
'', '\n', ...
'// Extrude in z-dir', '\n', ...
'out[] = Extrude {0,0,L_z}', '\n', ...
'            { ', '\n', ...
'                Surface{1};', '\n', ...
'                Layers{Nz};', '\n', ...
'                Recombine;', '\n', ...
'            };', '\n', ...
'', '\n', ...
'//-----------------------------------------', '\n', ...
'// Generate Physical Outputs', '\n', ...
'//Physical Surface("BC_Fixed") = {25};', '\n', ...
'Physical Surface("BC_Fixed") = {13,17,21,25};', '\n', ...
'Physical Volume("body") = out[1];', '\n', ...
'Physical Surface("plot_surface") = {1,-13,-17,-21,-25,-26}; ', '\n', ...
'Physical Surface("face1") = {13};', '\n', ...
'Physical Surface("face2") = {17};', '\n', ...
'Physical Surface("face3") = {21};', '\n', ...
'Physical Surface("face4") = {25};', '\n' ...
];


%% Open the file
fid = fopen(filename, 'w');
if( fid < 2 )
    error('Problem opening the file %s', filename);
end

%% Write the file
fprintf(fid,str);

%% close the file
fid = fclose(fid);


