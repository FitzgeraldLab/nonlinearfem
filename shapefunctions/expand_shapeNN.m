function N = expand_shapeNN(NN, nen, ned)

%% expand [NN] -> [N]
% N = zeros(ned,nen*ned);
% I3 = eye(3);
% for i = 1:nen
%     N(1:ned,(1:3)+ned*(i-1)) = NN(i)*I3;
% end

N = zeros(ned, nen*ned);
N(1,1:nen) = NN;
N(2,(nen+1):2*nen) = NN;
N(3,(2*nen+1):3*nen) = NN;

%% More Fortran-ish Method:
% N = zeros(ned,nen*ned);
% 
% for i = 1:nen
%     for j = 1:ned
%         i1 = j;
%         i2 = (i-1)*ned + j;
%         N(i1,i2) = NN(i);
%     end
% end
