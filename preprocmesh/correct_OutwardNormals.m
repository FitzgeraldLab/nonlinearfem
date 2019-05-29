function ws_IEN_corrected = correct_OutwardNormals(...
                                x, y, z, IEN, eltype,...
                                ws_IEN, ws_nel, ws_eltype, ...
                                varargin )

%% Mesh Quality: check outward facing normals
% by: Timothy Fitzgerald
% For a given mesh compute if the normals face outward
% *** This is for surface meshes of el10 that match to a surface of an el12

%% parse input
p = inputParser;
addRequired(p,         'x', @isnumeric);
addRequired(p,         'y', @isnumeric);
addRequired(p,         'z', @isnumeric);
addRequired(p,       'IEN', @isnumeric);
addRequired(p,    'eltype', @isnumeric);
addRequired(p,    'ws_IEN', @isnumeric);
addRequired(p,    'ws_nel', @isnumeric);
addRequired(p, 'ws_eltype', @isnumeric);

addParameter(p, 'printoutput', 'none', @ischar);

% Parse the inputs
parse(p, x, y, z, IEN, eltype, ws_IEN, ws_nel, ws_eltype, varargin{:});
flag_printoutput = p.Results.printoutput;

%% Look at each -normal and see if it projects into any elements

ws_IEN_corrected = ws_IEN;

for es = 1:ws_nel
    
    if( ws_eltype(es) ~= 10 )
        error('Surface Element %d is not type 10.  stopping.',es);
        %ws_IEN_corrected = NaN;
        %return
    end
    
    % determine which elements of the volume are involved with that surface
    % element es, local node 9 is at the center of el10
    As  = ws_IEN(9,es);
    [at,ev] = find(IEN==As);
    
    % Get the position of of the center point of the face
    elem_face = [x(As) y(As) z(As)]';
    
    % Compute the center location of the element (27 is locally the center)
    if( eltype(ev) ~= 12 )
        error('Volume Element %d is not type 12.  stopping.',ev);
        %ws_IEN_corrected = NaN;
        %return
    end
    idx = IEN(27,ev);
    elem_center = [x(idx) y(idx) z(idx)]';
    
    % distance from element center to element face point
    de = norm(elem_face - elem_center,2);
    
    % Compute normal for the surface element
    r = 0;
    s = 0;
    [nhat,~,~,R] = get_SurfaceTriad_el10_ref(r,s,es,x,y,z,ws_IEN);
    
    % Compute position that should be slightly inside the element
    p = R-nhat*de/50;
    
    % compute distance from center to point p
    dp = norm(p - elem_center,2);
    
    % compare the distances, if dp < de, then we are inside element and n
    % is outward facing
    if( dp < de )
        fprintf_flag(flag_printoutput, 'iter','     Surface Element %d passed\n',es);
    else
        fprintf_flag(flag_printoutput, 'iter','     Surface Element %d FIXED\n',es);
        
        % flip the local element numbering
        %      1 2 3 4 5 6 7 8 9
        idx = [2 1 4 3 5 8 7 6 9];
        ws_IEN_corrected(:,es) = ws_IEN(idx,es);
    end
        
end

fprintf_flag(flag_printoutput, 'final', 'Surface Elements corrected.\n');

%%
function fprintf_flag(flag, flag0, varargin)
if( strcmpi( flag, flag0) )
    fprintf(varargin{:});
end

