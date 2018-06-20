function [I] = NewSample( obj,DATA,x )
[A,B]=sort(obj);
n=size(DATA,2)-1;


for i=1:size(obj,1)
    d=CalDis(x,DATA(B(i),1:2));
    if d~=0
        I=B(i);
        break;
    end
end


end

function [DIS]=CalDis(x,xx)

d=sum((x-ones(size(x,1),1)*xx).^2,2);
DIS=min(d);
end


function [mDIS]=CalDisMin(x)
d=zeros(size(x,1),1);
for i=1:size(x,1)
    T=x;
    T(i,:)=[];
    d(i)=CalDis(T,x(i,:));
end
mDIS=mean(d);
end