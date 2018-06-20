function [ KNNStruct] = KNNsparse( x,y )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
Yc=0-ones(size(y,1),1);
I=find(y==0);
Yc(I)=1;
KNNStruct = ClassificationKNN.fit(x,Yc,'NumNeighbors',round(size(I,1)/2),'Distance','mahalanobis');

end

