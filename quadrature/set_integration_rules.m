function quad_rules = set_integration_rules(eltype,varargin)
%%
p = inputParser;
addRequired(p, 'eltype', @isnumeric);

%% define the defaults
% 2 node lines
addParameter(p,  'el1', struct('method', 'prod', 'points', 5) );

% 3 node triangle
addParameter(p,  'el2', struct('method', 'prod', 'points', 3) );

% 4 node quadrilateral
addParameter(p,  'el3', struct('method', 'prod', 'points', 3) );

% 4 node tetrahedron
addParameter(p,  'el4', struct('method', 'prod', 'points', 3) );

% 8 node hexahedron
addParameter(p,  'el5', struct('method', 'prod', 'points', 3) );

% 6 node wedge
addParameter(p,  'el6', struct('method', 'prod', 'points', 3) );

% 5 node pyramid
addParameter(p,  'el7', NaN);

% 3 node line
addParameter(p,  'el8', struct('method', 'prod', 'points', 6) );

% 6 node triangle
addParameter(p,  'el9', struct('method', 'prod', 'points', 5) );

% 9 node quadrilateral
addParameter(p, 'el10', struct('method', 'prod', 'points', 5) );

% 10 node tetrahedron
addParameter(p, 'el11', struct('method', 'prod', 'points', 5) );

% 27 node hexahedron
addParameter(p, 'el12', struct('method', 'prod', 'points', 5) );

% 18 node wedge
addParameter(p, 'el13', struct('method', 'prod', 'points', 5) );

% 14 node pyramid
addParameter(p, 'el14', NaN);

% 1 node point
addParameter(p, 'el15', NaN);

% 8 node quad
addParameter(p, 'el16', struct('method', 'prod', 'points', 5) );

% 20 node hexahedron
addParameter(p, 'el17', struct('method', 'prod', 'points', 5) );

% 15 node wedge
addParameter(p, 'el18', struct('method', 'prod', 'points', 5) );

% 13 node pyramid
addParameter(p, 'el19', NaN);

%% For refereence
% element types defined in GMSH
% Types = { ...
%     {  2,  1, 'LINES',      'nbLines'},      ... % 1
%     {  3,  2, 'TRIANGLES',  'nbTriangles'},  ... % 2
%     {  4,  2, 'QUADS',      'nbQuads'},      ... % 3
%     {  4,  3, 'TETS',       'nbTets'},       ... % 4
%     {  8,  3, 'HEXAS',      'nbHexas'},      ... % 5
%     {  6,  3, 'PRISMS',     'nbPrisms'},     ... % 6
%     {  5,  3, 'PYRAMIDS',   'nbPyramids'},   ... % 7
%     {  3,  1, 'LINES3',     'nbLines3'},     ... % 8
%     {  6,  2, 'TRIANGLES6', 'nbTriangles6'}, ... % 9
%     {  9,  2, 'QUADS9',     'nbQuads9'},     ... % 10
%     { 10,  3, 'TETS10',     'nbTets10'},     ... % 11
%     { 27,  3, 'HEXAS27',    'nbHexas27'},    ... % 12
%     { 18,  3, 'PRISMS18',   'nbPrisms18'},   ... % 13
%     { 14,  3, 'PYRAMIDS14', 'nbPyramids14'}, ... % 14
%     {  1,  0, 'POINTS',     'nbPoints'},     ... % 15
%     {  8,  3, 'QUADS8',     'nbQuads8'},     ... % 16
%     { 20,  3, 'HEXAS20',    'nbHexas20'},    ... % 17
%     { 15,  3, 'PRISMS15',   'nbPrisms15'},   ... % 18
%     { 13,  3, 'PYRAMIDS13', 'nbPyramids13'}, ... % 19
%     };

%% parse inputs
parse(p, eltype, varargin{:});
elopt = {...
    p.Results.el1,p.Results.el2,p.Results.el3,p.Results.el4,...
    p.Results.el5,p.Results.el6,p.Results.el7,p.Results.el8,...
    p.Results.el9,p.Results.el10,p.Results.el11,p.Results.el12,...
    p.Results.el13,p.Results.el14,p.Results.el15,p.Results.el16,...
    p.Results.el17,p.Results.el18,p.Results.el19};


%% determine which element types are present
set_eltype = unique( eltype );
nels = length( set_eltype );


%% init the output container (same dim as nen)
%std_element_defs;
% length(nen) = 19
quad_rules = cell(1,19);

%% generate the rules
% populate the output with only the

for i = 1:nels
   j = set_eltype(i);

   if any( j == [1, 8] )
       % line elements
       quad_rules{j} = quad_rules_line(elopt{j});

   elseif any( j == [2, 9] )
       % triangle elements
       quad_rules{j} = quad_rules_triangle(elopt{j});

   elseif any( j == [3, 10, 16] )
       % quadrilateral elements
       quad_rules{j} = quad_rules_quadrilateral(elopt{j});

   elseif any( j == [5, 12, 17] )
       % hexahedron elements
       quad_rules{j} = quad_rules_hexahedron(elopt{j});

   elseif any( j == [4, 11] )
       % tetrahedron elements
       quad_rules{j} = quad_rules_tetrahedron(elopt{j});

   else
      error('Integration rule for eltype=%d is not defined.', j);
   end

end
