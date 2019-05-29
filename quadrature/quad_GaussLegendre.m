function quad_rule = quad_GaussLegendre(num_GaussPoints, num_Dimensions)

%%
nt = num_GaussPoints;
ned = num_Dimensions;

%% construct the nt roots of the nt order polynomial
p = cell(nt+1,1);

n = 0;
j = n+1;
p{j} = 1;
n = 1;
j = n+1;
p{j} = [1 0];
for n = 1:nt-1
    j = n + 2;
    P1 = conv([1,0],p{n+1});
    P2 = padarray(p{n},[0,length(P1)-length(p{n})],0,'pre');
    p{j} = 1/(n+1)*( (2*n+1)*P1 - n*P2 );
end
P = p{j};
xi = sort(roots(P));

%% Construct the weights
dP = polyder(P);
w = 2./( (1-xi.^2).*polyval(dP,xi).^2);

%% Form output

quad_rule.method = 'GaussLegendre';
quad_rule.order  = 2*nt-1;

switch ned
    case 1
        quad_rule.nt = nt;
        quad_rule.xi = xi;
        quad_rule.w = w;
        quad_rule.domain = 'line [-1,1]';
        
    case 2
        quad_rule.nt = nt^2;
        quad_rule.w = zeros(quad_rule.nt,1);
        quad_rule.xi = zeros(quad_rule.nt,1);
        quad_rule.eta = zeros(quad_rule.nt,1);
        quad_rule.domain = 'square [-1,1]';
        
        q = 0;
        for i = 1:nt
            for j = 1:nt
                q = q+1;
                quad_rule.w(q) = w(i)*w(j);
                quad_rule.xi(q) = xi(i);
                quad_rule.eta(q) = xi(j);
            end
        end
        
    case 3
        quad_rule.nt = nt^3;
        quad_rule.w = zeros(quad_rule.nt,1);
        quad_rule.xi = zeros(quad_rule.nt,1);
        quad_rule.eta = zeros(quad_rule.nt,1);
        quad_rule.zeta = zeros(quad_rule.nt,1);
        quad_rule.domain = 'cube [-1,1]';
        
        q = 0;
        for i = 1:nt
            for j = 1:nt
                for k = 1:nt
                    q = q+1;
                    quad_rule.w(q) = w(i)*w(j)*w(k);
                    quad_rule.xi(q) = xi(i);
                    quad_rule.eta(q) = xi(j);
                    quad_rule.zeta(q) = xi(k);
                end
            end
        end
        
end