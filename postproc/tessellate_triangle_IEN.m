function IEN = tessellate_triangle_IEN(pts_per_edge)

%%
n = pts_per_edge-1;
nel = n^2;


%% odd numbered local elements
nodd = 1/2*n*(n+1);
temp_odd = nan(nodd,3);

% magical pattern, worked out by elves
temp_odd(:,3) = 1:nodd;

temp_odd(1,:) = [2,3,1];
q = 1;
for i = 2:n
   
    k = 1/2*i*(i+1);
    for j = 1:i
      q = q+1;
      
      temp_odd(q,1) = k+j;       
    end  
end

temp_odd(:,2) = temp_odd(:,1)+1;


%% even number (upside down elements)
neven = 1/2*n*(n-1);
temp_even = nan(neven,3);
q = 0;
for i = 1:n-1
    k = 1/2*(4+i+i^2);
    for j = 1:i
        q = q+1;
        temp_even(q,1) = k + j - 1;
    end
end
temp_even(:,2) = temp_even(:,1) - 1;

q = 0;
for i = 1:n-1
    k = 1/2*(5+i+(i+1)^2);
    for j = 1:i
        q = q+1;
        temp_even(q,3) = k + j - 1;
    end
end


%%
IEN = [temp_odd; temp_even];

