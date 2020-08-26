function write_hdf5_snapshot(hfile, n, qn, qdn, t, varargin)

%% Parse input
p = inputParser;
addRequired( p,   'n', @isnumeric);
addRequired( p,  'qn', @isnumeric);
addRequired( p, 'qdn', @isnumeric);
addRequired( p,   't', @isnumeric);

addParameter(p,'qddn', nan);
addParameter(p,'subIter', nan);
addParameter(p,'writeDateTime', false);

% Parse the inputs
parse(p, n, qn, qdn, t, varargin{:});

qddn    = p.Results.qddn;
subIter = p.Results.subIter;
writeDateTime = p.Results.writeDateTime;

%% write Std Data
dataset_name = sprintf('/%d/t',n);
h5create(hfile, dataset_name, 1);
h5write(hfile, dataset_name, t);

dataset_name = sprintf('/%d/qn',n);
h5create(hfile, dataset_name, size(qn));
h5write(hfile, dataset_name, qn);

dataset_name = sprintf('/%d/qdn',n);
h5create(hfile, dataset_name, size(qdn));
h5write(hfile, dataset_name, qdn);


%% write optional data
if length(qddn) > 1
    dataset_name = sprintf('/%d/qddn',n);
    h5create(hfile, dataset_name, size(qddn));
    h5write(hfile, dataset_name, qddn);
end

if ~isnan(subIter)
    dataset_name = sprintf('/%d/subIter',n);
    h5create(hfile, dataset_name, size(subIter));
    h5write(hfile, dataset_name, subIter);
end

if writeDateTime
    dateTime = now();
    dataset_name = sprintf('/%d/dateTime',n);
    h5create(hfile, dataset_name, size(dateTime));
    h5write(hfile, dataset_name, dateTime);
end