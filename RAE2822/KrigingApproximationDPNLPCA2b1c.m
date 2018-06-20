function [ KD1,KD2,CM,srgtSRGTKRG] = KrigingApproximationDPNLPCA2b1c( Mmax,Mmin,CLmax,CLmin,NM,NCL )
failure=0;
T=1/10000;
TD=0.1;
MCM=0.734;
CLCM=0.824;
d=2;
Neighbor=[1,0;0,1;-1,0;0,-1;1,1;1,-1;-1,1;-1,-1];
derta=[(CLmax-CLmin)/(NCL-1),(Mmax-Mmin)/(NM-1)];
N=NM*NCL;
logbook=[];

[Y2,X2] = meshgrid(CLmin:(CLmax-CLmin)/(NCL-1):CLmax,Mmin:(Mmax-Mmin)/(NM-1):Mmax);
DATA2=[X2(:),Y2(:)];

n=5*d;

I = lhsdesign(n,d);
I(:,1)=ceil(I(:,1)*NM);
I(:,2)=ceil(I(:,2)*NCL);
t=[1,NCL;NM,NCL;NM,1;1,1];
for i=1:size(t,1)
    D=sum(abs(I-ones(size(I,1),1)*t(i,:))./(ones(size(I,1),1)*t(2,:)),2);
    [A,It]=min(D);
    I(It,:)=t(i,:);
end
x0=[];
x=[];
y=[];
zf1=[];
for i=1:n
    t=[X2(I(i,1),I(i,2)),Y2(I(i,1),I(i,2))];
    tt=t;
    j=1;
    x=[x;t];

    [ data ] = SingleVGK( t(1),t(2) );
    while isempty(data)&j<=size(Neighbor,1)
        tt=t+Neighbor(j,:).*derta;
        if tt(1)>=Mmin&tt(1)<=Mmax&tt(2)>=CLmin&tt(2)<=CLmax
            [ data ] = SingleVGK( tt(1),tt(2) );
        end
        j=j+1;
    end
    if isempty(data)
        TT=[tt,0];
        logbook=[logbook;TT];
        failure=failure+1;
        x(end,:)=[];
    else
        TT=[tt,1];
        logbook=[logbook;TT];
        x(end,:)=tt;
        if data.CD2>=0
            y=[y;data.CD2];
        else
            y=[y;0];
        end
    end
end

while size(x,1)<=11*d&failure<11*d
if ~isempty(find(y==0))
    [ KNNStruct] = KNNsparse( x,y );
    Group=predict(KNNStruct, DATA2(:,1:d));

    IS=find(Group==1);
    ISN=find(Group==-1);
    x0=DATA2(IS,1:d);
    y0=zeros(size(x0,1),1);
else
    x0=[];
    y0=[];
    ISN=[1:size(DATA2,1)]';
end

[ train ] = POPcombination( [x,y],[x0,y0],d );
srgtOPTKRG  = srgtsKRGSetOptions(train(:,1:d), train(:,d+1));
srgtSRGTKRG = srgtsKRGFit(srgtOPTKRG);
[f1,PredVar] = srgtsKRGPredictor(DATA2(:,1:d), srgtSRGTKRG);

zf1=reshape(f1,NM,NCL);
zs=reshape(PredVar.^0.5,NM,NCL);

[ Df1 ] = DZDX( X2,zf1 );

w=mean(mean(abs(Df1-TD)))/mean(mean(zs));

obj=abs(Df1-TD)-w*zs;
obj=obj(:);

I1 = NewSample( obj,DATA2,x );
x=[x;DATA2(I1,1:d)];
t=DATA2(I1,1:d);
[ data ] = SingleVGK( DATA2(I1,1),DATA2(I1,2) );
while isempty(data)
    TT=[DATA2(I1,1),DATA2(I1,2),0];
    logbook=[logbook;TT];
    failure=failure+1;
    obj(I1)=max(obj);
    I1 = NewSample( obj,DATA2,x );
    x(end,:)=DATA2(I1,1:d);
    tt=DATA2(I1,1:d);
    [ data ] = SingleVGK( DATA2(I1,1),DATA2(I1,2) );
end
TT=[DATA2(I1,1),DATA2(I1,2),1];
logbook=[logbook;TT];
y=[y;data.CD2];
end

[ data ] = SingleVGK( MCM,CLCM );
if isempty(data)
    CM=-0.2;
else
    CM=data.CM;
end


if failure<11*d
    KD2=FindkModal( X2,Y2,Df1,zs,TD );
    KD1=FindkModal( X2,Y2,zf1,zs,T );
else
    KD2=[];
    KD1=[];
    srgtSRGTKRG=[];
end


if ~isempty(x0)
    plot(x0(:,1),x0(:,2),'c.');
    hold on;
end
if ~isempty(zf1)
    v = [1 2 3 5];
    [C,Hcdw] = contour(X2,Y2,10000*zf1,v,'-k','LineWidth',0.5);
    clabel(C,Hcdw);
    hold on;
    v = 10:10:200;
    [C,Hcdw] = contour(X2,Y2,10000*zf1,v,'-k','LineWidth',0.5);
    clabel(C,Hcdw);
%     plot(x(:,1),x(:,2),'r*',x(1:5*d,1),x(1:5*d,2),'ro');
    plot(x(:,1),x(:,2),'r*');
end
if ~isempty(KD2)
    KD2=sortrows(KD2,2);
    plot(KD2(:,1),KD2(:,2),'b*');
%     plot(KD2(:,1),KD2(:,2),'m-','LineWidth',2);
end

if ~isempty(KD1)
    plot(KD1(:,1),KD1(:,2),'b^');
end

axis([ Mmin Mmax,CLmin,CLmax]);
% hold off;
failure

if failure~=0
IDtime=fix(clock);
file1=sprintf('FailAt%d%d%d%d%d%d.dat',IDtime(1),IDtime(2),IDtime(3),IDtime(4),IDtime(5),IDtime(6));
file2=sprintf('FailAt%d%d%d%d%d%d.mat',IDtime(1),IDtime(2),IDtime(3),IDtime(4),IDtime(5),IDtime(6));
copyfile('geometry.dat', file1);
save(file2,'logbook');
end
end

