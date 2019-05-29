function [n,t1,t2, R] = get_SurfaceTriad_el10_ref(r,s,e,x,y,z,ws_IEN)

%%
nen_e = 9;
ned = 3;

%% setup xe ye ze
xe = zeros(nen_e,1);
ye = zeros(nen_e,1);
ze = zeros(nen_e,1);
for a = 1:nen_e;
    idx = ws_IEN(a,e);
    xe(a) = x(idx);
    ye(a) = y(idx);
    ze(a) = z(idx);
end
X = [xe; ye; ze];

%% get shape functions
[NN, NNxi, NNeta] = el10_ShapeFunctions(r,s);
N     = expand_shapeNN(NN    , nen_e, ned);
Nxi   = expand_shapeNN(NNxi  , nen_e, ned);
Neta  = expand_shapeNN(NNeta , nen_e, ned);

%% compute R and it's derivatives
R      = N*(X);
dRdxi  = Nxi*(X);
dRdeta = Neta*(X);

%% compute the normal vector
n = cross(dRdxi,dRdeta); 
n = n/norm(n,2);

%% compute the tangent vectors
t1 = dRdxi/norm(dRdxi,2);
t2 = cross(n,t1);