clear all; close all; clc

%%
path(pathdef)
addpath(fullfile('../shapefunctions'));

%% Definitions
float = double(0);
integer = int32(0);
mexcfg = coder.config('mex');
mexcfg.DynamicMemoryAllocation='AllVariableSizeArrays';
mexcfg.IntegrityChecks = false;
mexcfg.ResponsivenessChecks = false;

%%
ned = 3;
nen = 9;
nee = ned*nen;

X   = coder.typeof(float, [nee 1]);
qe  = coder.typeof(float,[nee 1]);
E   = float;
nu  = float;
rho = float;
quad_nt   = integer;
quad_xi   = coder.typeof(float,[ Inf 1]);
quad_eta  = coder.typeof(float,[ Inf 1]);
quad_zeta = coder.typeof(float,[ Inf 1]);
quad_w    = coder.typeof(float,[ Inf 1]);
xe = coder.typeof(float, [nen, 1]);
ye = coder.typeof(float, [nen, 1]);
ze = coder.typeof(float, [nen, 1]);
ue = coder.typeof(float, [nen, 1]);
ve = coder.typeof(float, [nen, 1]);
we = coder.typeof(float, [nen, 1]);
ref_pt = coder.typeof(float, [ned, 1]);

nel=float;
eltype = coder.typeof(float, [Inf, 1]);
IEN = coder.typeof(float, [27, Inf]);
ID = coder.typeof(float, [3, Inf]);
x = coder.typeof(float, [Inf, 1]);
y = coder.typeof(float, [Inf, 1]);
z = coder.typeof(float, [Inf, 1]);
qi = coder.typeof(float, [Inf, 1]);
%%
r=coder.typeof(float, [Inf, 1]);
s=coder.typeof(float, [Inf, 1]);
codegen -config mexcfg el10_ShapeFunctions -args {r,s}
%%
codegen -config mexcfg el10_lengths -args {xe, ye, ze, ue, ve, we,quad_nt, quad_xi, quad_w}
%%
codegen -config mexcfg el12_ke_biot -args {X, qe, E, nu, quad_nt, quad_xi, quad_eta, quad_zeta, quad_w}
codegen -config mexcfg el12_ke_kirch -args {X, qe, E, nu, quad_nt, quad_xi, quad_eta, quad_zeta, quad_w}

codegen -config mexcfg el12_inertia -args {xe, ye, ze, ue, ve, we, rho, ref_pt, quad_nt, quad_xi, quad_eta, quad_zeta, quad_w}

codegen -config mexcfg el12_compute_Volume -args {X, qe, quad_nt, quad_xi, quad_eta, quad_zeta, quad_w}

%%
fprintf(1,'Complete.\n');
