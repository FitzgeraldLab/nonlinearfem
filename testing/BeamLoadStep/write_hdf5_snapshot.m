function write_hdf5_snapshot(hfile, n, qn, load, varargin)

%% Parse input
p = inputParser;
addRequired( p,    'n', @isnumeric);
addRequired( p,   'qn', @isnumeric);
addRequired( p, 'load', @isnumeric);

addParameter(p,'subIter', nan);
addParameter(p,'writeDateTime', false);

% Parse the inputs
parse(p, n, qn, load, varargin{:});

subIter = p.Results.subIter;
writeDateTime = p.Results.writeDateTime;

%% write Std Data
dataset_name = sprintf('/%d/qn',n);
h5create(hfile, dataset_name, size(qn));
h5write(hfile, dataset_name, qn);

dataset_name = sprintf('/%d/load',n);
h5create(hfile, dataset_name, size(load));
h5write(hfile, dataset_name, load);


%% write optional data
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