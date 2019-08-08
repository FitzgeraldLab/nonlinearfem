function killflag = checkKillFile(varargin)

%% Parse input
p = inputParser;
addParameter(p,    'check',          1, @isnumeric);
addParameter(p, 'filename', 'killfile', @ischar);
addParameter(p,   'remove',          0, @isnumeric);

% Parse the inputs
parse(p, varargin{:});

check     = p.Results.check;
filename  = p.Results.filename;
removeFile= p.Results.remove;


%% Does killfile exist?
% if Yes, skip this, if no make the file and leave function
if exist(filename, 'file') ~= 2
    % make a file
    fid = fopen(filename,'w');
    fprintf(fid,'0');
    fclose(fid);
    killflag = 0;
    return
end

%% read killfile

if check
    
    fid = fopen(filename, 'r');
    killflag = fscanf(fid,'%d');
    fclose(fid);
    
end


%% remove file
if removeFile
    delete(filename)
end

end