function [Nodes,msh,PhysicalNames] = load_gmsh(infile, varargin)
%#ok<*PRTCAL>

%%
p = inputParser;
addRequired(p, 'infile', @ischar);
addParameter(p, 'printoutput', 'none', @ischar);

% Parse the inputs
parse(p, infile, varargin{:});
flag_printoutput = p.Results.printoutput;

%% open file
fid = fopen(infile,'r');

%% index file
fprintf_iter(flag_printoutput,'----------------------------------------------\n')
fprintf_iter(flag_printoutput,'Indexing file ... ')

fidx.PhysicalNames = -1;
fidx.MeshFormat = -1;
fidx.Nodes = -1;
fidx.Elements = -1;

flag = 0;
while (flag == 0)
    tline = fgetl(fid);
    
    if( ischar(tline) ~= 1 )
        flag = -1;
    elseif( strcmpi(tline,'$MeshFormat') == 1 )
        fidx.MeshFormat = ftell(fid);
    elseif( strcmpi(tline,'$PhysicalNames') == 1 )
        fidx.PhysicalNames = ftell(fid);
    elseif( strcmpi(tline,'$Nodes') == 1 )
        fidx.Nodes = ftell(fid);
    elseif( strcmpi(tline,'$Elements') == 1 )
        fidx.Elements = ftell(fid);
    end
end
fseek(fid,0,'bof');
fprintf_iter(flag_printoutput,'complete.\n')

%% read in header
fseek(fid,fidx.MeshFormat,'bof');
MeshFormat = fgetl(fid);
fprintf_iter(flag_printoutput,'----------------------------------------------\n')
fprintf_iter(flag_printoutput,['MeshFormat: ', MeshFormat,'\n'])
fseek(fid,0,'bof');

%% read in Physical Names
fprintf_iter(flag_printoutput,'----------------------------------------------\n')
fprintf_iter(flag_printoutput,'Searching for PhysicalNames ... ')

if( fidx.PhysicalNames >=0 )
    fseek(fid,fidx.PhysicalNames,'bof');
    
    fprintf_iter(flag_printoutput,'found\n')
    PhysicalNames.num = str2double( fgetl(fid) );
    PhysicalNames.label = cell([PhysicalNames.num,1]);
    
    for i = 1:PhysicalNames.num
        temp = fgetl(fid);
        fprintf_iter(flag_printoutput,['     ',temp,'\n'])
        temp2 = strfind(temp,'"');
        nums = sscanf(temp,'%d');
        PhysicalNames.label{nums(2)} = temp(temp2(1)+1:temp2(2)-1);
    end
    clear temp2 nums
else
    fprintf_iter(flag_printoutput,'none found\n')
end
fseek(fid,0,'bof');

%% read in Nodal information
fprintf_iter(flag_printoutput,'----------------------------------------------\n')
fprintf_iter(flag_printoutput,'Loading Nodal locations\n')

fseek(fid,fidx.Nodes,'bof');

Nodes.nnp = str2double( fgetl(fid) );
fprintf_iter(flag_printoutput,'     nnp = %d\n',Nodes.nnp)

locations = fscanf(fid,'%d %f %f %f',[4 Nodes.nnp])';
Nodes.x = locations(:,2);
Nodes.y = locations(:,3);
Nodes.z = locations(:,4);

fprintf_iter(flag_printoutput,'     complete\n')
fseek(fid,0,'bof');

%% Read in element information
fprintf_iter(flag_printoutput,'----------------------------------------------\n')
fprintf_iter(flag_printoutput,'Loading Element connectivity\n')

fseek(fid,fidx.Elements,'bof');

total_ele_num = str2double( fgetl(fid) );
fprintf_iter(flag_printoutput,'     total elements = %d\n',total_ele_num)

Types = { ...
    {  2,  1, 'LINES',      'nbLines'},      ... % 1
    {  3,  2, 'TRIANGLES',  'nbTriangles'},  ...
    {  4,  2, 'QUADS',      'nbQuads'},      ...
    {  4,  3, 'TETS',       'nbTets'},       ...
    {  8,  3, 'HEXAS',      'nbHexas'},      ... %5
    {  6,  3, 'PRISMS',     'nbPrisms'},     ...
    {  5,  3, 'PYRAMIDS',   'nbPyramids'},   ...
    {  3,  1, 'LINES3',     'nbLines3'},     ...
    {  6,  2, 'TRIANGLES6', 'nbTriangles6'}, ...
    {  9,  2, 'QUADS9',     'nbQuads9'},     ... % 10
    { 10,  3, 'TETS10',     'nbTets10'},     ...
    { 27,  3, 'HEXAS27',    'nbHexas27'},    ...
    { 18,  3, 'PRISMS18',   'nbPrisms18'},   ...
    { 14,  3, 'PYRAMIDS14', 'nbPyramids14'}, ...
    {  1,  0, 'POINTS',     'nbPoints'},     ... % 15
    {  8,  3, 'QUADS8',     'nbQuads8'},     ...
    { 20,  3, 'HEXAS20',    'nbHexas20'},    ...
    { 15,  3, 'PRISMS15',   'nbPrisms15'},   ...
    { 13,  3, 'PYRAMIDS13', 'nbPyramids13'}, ...
    };

% save position info of start of $Element
file_pos = ftell(fid);

if( fidx.PhysicalNames >= 0 )
    % initalize the msh variable
    msh = cell([PhysicalNames.num,1]);
    workingmsh = cell([PhysicalNames.num,1]);
    for i = 1:PhysicalNames.num
        msh{i}.num = 0;
        msh{i}.max_dof_element_type = 0;
        msh{i}.label = PhysicalNames.label{i};
        
        workingmsh{i}.i = 0;
    end
    
    % count number of elements in each group, and track max 
    % dofs/element type
    for i = 1:total_ele_num
        temp = fgetl(fid);
        temp2 = sscanf(temp,'%*d %d %*d %d',2);
        
        etype = temp2(1);
        egroup = temp2(2);
        
        msh{egroup}.num = msh{egroup}.num + 1;
        msh{egroup}.max_dof_element_type = ...
            gmsh_max_dof_element(msh{egroup}.max_dof_element_type , etype);
        
    end
    clear temp2
    
    % initialize IEN and type matricies
    for i = 1:PhysicalNames.num
        if( msh{i}.num > 0 )
        msh{i}.IEN = zeros([Types{msh{i}.max_dof_element_type}{1},...
            msh{i}.num]) -1;
        msh{i}.etype = zeros([msh{i}.num,1]);
        else
            msh{i}.etype = NaN;
            msh{i}.IEN = NaN;
            fprintf(2,'     Error: <%s> has no elements in it.\n', PhysicalNames.label{i});
        end
    end
    
    % move back to start of element info
    fseek(fid,file_pos,'bof');
    
    % read in each element to it's respective PhysicalGroup
    for i = 1:total_ele_num
        temp = fgetl(fid);
        nums = sscanf(temp,'%d');
        etype = nums(2);
        egroup = nums(4);
        skip = 4+nums(3);
                
        workingmsh{egroup}.i = workingmsh{egroup}.i+1;
        j = workingmsh{egroup}.i;
        range = 1:length(nums(skip:end));
        msh{egroup}.IEN(range,j) = nums(skip:end);
        msh{egroup}.etype(j) = etype;
    end
    clear skip egroup etype workingmsh temp nums
    
    % Compute some more derivative information
    for i = 1:PhysicalNames.num
        msh{i}.elements_contained = unique( msh{i}.etype );
    end
    
    fprintf_iter(flag_printoutput,'     complete\n')
    
else
    fprintf(2,['***********************************************\n',...
               '* Error: method not yet implemented\n',...
               '*        define physical groups, and try again\n',...
               '***********************************************\n'])
end
fseek(fid,0,'bof');

%% close file
fclose(fid);
fprintf_iter(flag_printoutput,'----------------------------------------------\n');

fprintf_final(flag_printoutput, 'msh file <%s> loaded\n', infile);

%%
function fprintf_iter(flag, varargin)
if( strcmpi( flag, 'iter') )
    fprintf(varargin{:});
end

function fprintf_final(flag, varargin)
if( strcmpi( flag, 'final') )
    fprintf(varargin{:});
end
