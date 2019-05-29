function [neighbor, n_neighbor, el_list_by_neighbor] = find_neighboring_elements(IEN, varargin)

%% Parse input
p = inputParser;
addRequired( p,              'IEN', @isnumeric);
addParameter(p,             'e_in', 1:size(IEN,2), @isnumeric);
addParameter(p,    'max_neighbors', 10, @isnumeric);
addParameter(p, 'min_shared_nodes', 1, @isnumeric);

%% Parse the inputs
parse(p, IEN, varargin{:});

e_in           = p.Results.e_in;
nel            = max(e_in);
nmax_neighbors = p.Results.max_neighbors;
min_shared_nodes = p.Results.min_shared_nodes;

%%
neighbor       = nan(nel, nmax_neighbors);
n_neighbor     = zeros(1,nel);

%%
for e = e_in
    
    A = unique( IEN(:,e) );
    temp = zeros(size(IEN));
    
    % sum the number of times these nodes appear in other elements
    for a = 1:length(A)
        temp = temp + (IEN == A(a));
    end
    counts = sum(temp);
    
    % locate which elements these are
    el = find( counts >= min_shared_nodes );
    
    % remove the self element
    el = setdiff(el, e);
    
    % append the lists, keeping only up to the nmax
    if( length(el) <= nmax_neighbors )
        n_neighbor(e) = length(el);
    else
        n_neighbor(e) = nmax_neighbors;
    end
    r1 = 1:n_neighbor(e);
    neighbor(e,r1) = el(r1);
    
end

%% generate the ordered list of elements, by each
if( nargout > 2 )
    el_list_by_neighbor = nan(nel, nel);
    for e0 = e_in
        e0neighbor = neighbor(e0,1:n_neighbor(e0));
        el_list_by_neighbor(e0,:) = [e0, e0neighbor, setdiff( 1:nel, union(e0, e0neighbor) )];
        
    end
    
end