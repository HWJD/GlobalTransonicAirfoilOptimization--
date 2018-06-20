function [ D ] = DVDX( X,Z )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
D=zeros(size(X,1),size(X,2));
for j=1:size(X,2)
    for i=2:size(X,1)-1
        D(i,j)=0.5*(Z(i+1,j)+Z(i,j))/(X(i+1,j)-X(i,j))+0.5*(Z(i,j)+Z(i-1,j))/(X(i,j)-X(i-1,j));
    end
end

end

