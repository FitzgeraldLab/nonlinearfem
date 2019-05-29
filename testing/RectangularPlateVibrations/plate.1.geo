// Flexible Plate

//-----------------------------------------
// Define Parameters
L_x = 3;    // Span
L_y = 1;    // chord
L_z = 0.05; // thickness

// Number of elements in each direction
Nx = 8;
Ny = 3;
Nz = 1;

//-----------------------------------------
// GMSH Options
Geometry.PointNumbers = 1;
Geometry.LineNumbers = 1;
Geometry.SurfaceNumbers = 1;

Mesh.ElementOrder = 2;
Mesh.Algorithm = 6;
Mesh.Algorithm3D = 4;
Mesh.Smoothing = 2;
Mesh.SecondOrderLinear = 0;
Mesh.PointNumbers = 1;

//-----------------------------------------
// Geometry
//
// Define base points, lines and surface
Point(1) = {    0,    0, -L_z/2};
Point(2) = {  L_x,    0, -L_z/2};
Point(3) = {  L_x,  L_y, -L_z/2};
Point(4) = {    0,  L_y, -L_z/2};
Line(1) = {1, 2};
Transfinite Line{1} = Nx+1;
Line(2) = {2, 3};
Transfinite Line{2} = Ny+1;
Line(3) = {3, 4};
Transfinite Line{3} = Nx+1;
Line(4) = {4, 1};
Transfinite Line{4} = Ny+1;
Line Loop(1) = {1, 2, 3, 4};
Plane Surface(1) = {1};
Transfinite Surface{1} = {1,2,3,4};
Recombine Surface {1};

// Extrude in y-dir
out[] = Extrude {0,0,L_z}
            { 
                Surface{1};
                Layers{Nz};
                Recombine;
            };

//-----------------------------------------
// Generate Physical Outputs
//Physical Surface("BC_Fixed") = {25};
Physical Surface("BC_Fixed") = {13,17,21,25};
Physical Volume("body") = out[1];
Physical Surface("plot_surface") = {1,-13,-17,-21,-25,-26}; 
Physical Surface("face1") = {13};
Physical Surface("face2") = {17};
Physical Surface("face3") = {21};
Physical Surface("face4") = {25};
