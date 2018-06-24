function [ y ] = HenneHicksCamber8( baselineCamber,a)
functions = {@f1,...
    @f2,...
    @f3,...
    @f4,...
    @f5,...
    @f6,...
    @f7,...
    @f8};
y=baselineCamber;
n=size(baselineCamber,1);
for i=1:size(functions,2)
    f = feval(functions{i},y(1:n,1));
    y(1:n,2)=y(1:n,2)+a(i)*f;
end
end

function [f]=f1(x)
f=x.^0.5.*(1-x)./(exp(20*x));
end
function [f]=f2(x)
f=x.^0.6.*(1-x)./(exp(12*x));
end


function [f]=f3(x)
f=sin(pi*(x.^0.32)).^3;
end

function [f]=f4(x)
f=sin(pi*(x.^0.5)).^3;
end

function [f]=f5(x)
f=sin(pi*(x.^0.8)).^3;
end

function [f]=f6(x)
f=sin(pi*(x.^1.4)).^3;
end

function [f]=f7(x)
f=sin(pi*(x.^2.8)).^3;
end

function [f]=f8(x)
f=sin(pi*(x.^7.4)).^2;
end
