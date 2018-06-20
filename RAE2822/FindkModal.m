function [ K ] = FindkModal( X,Y,Z,s,T )

K=[];

for j=1:size(X,2)
    for i=3:size(X,1)-2
        if (Z(i,j)-T)*(Z(i+1,j)-T)<0% &min(abs(Z(i,j)-T),abs(Z(i+1,j)-T))<=0.1*T
            if Z(i,j)>Z(i+1,j)
                w=(T-Z(i+1,j))/abs(Z(i,j)-Z(i+1,j));
                t=[X(i+1,j)+w*abs(X(i,j)-X(i+1,j)),Y(i,j),T,s(i+1,j)+w*abs(s(i,j)-s(i+1,j))];
            else
                w=(T-Z(i,j))/abs(Z(i,j)-Z(i+1,j));
                t=[X(i,j)+w*abs(X(i,j)-X(i+1,j)),Y(i,j),T,s(i,j)+w*abs(s(i,j)-s(i+1,j))];
            end
%             if abs(Z(i,j)-T)<=abs(Z(i+1,j)-T)
%                 t=[X(i,j),Y(i,j),Z(i,j)];
%             else
%                 t=[X(i+1,j),Y(i+1,j),Z(i+1,j)];
%             end
            K=[K;t];
            break;
        end
    end
end

K=sortrows(K);
end

