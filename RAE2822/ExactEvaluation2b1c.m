function [ KD1,KD2,CM] = ExactEvaluation2b1c( Mmax,Mmin,CLmax,CLmin,NM,NCL )
T=1/10000;
TD=0.1;
MCM=0.734;
CLCM=0.824;
N=NM*NCL;

[Y2,X2] = meshgrid(CLmin:(CLmax-CLmin)/(NCL-1):CLmax,Mmin:(Mmax-Mmin)/(NM-1):Mmax);
DATA2=[X2(:),Y2(:)];
f1=[];
ymld=[];
ycm=[];
for i=1:size(DATA2,1)
     [ data ] = SingleVGK( DATA2(i,1),DATA2(i,2) );
     if isempty(data)
         t=0;
         ymld=0;
         t1=0;
     else
         t=data.CD2;
         CDTOT=data.CDV + data.CD2;
         MLD=data.EM*data.CL/CDTOT;
         t1=data.CM;
     end
     
    ymld=[ymld;MLD];
    ycm=[ycm;t1];
     
    f1=[f1;t];
end

zf1=reshape(f1,NM,NCL);
[ Df1 ] = DZDX( X2,zf1 );

KD2=Findk( X2,Y2,Df1,TD );
KD1=Findk( X2,Y2,zf1,T );

[ data ] = SingleVGK( MCM,CLCM );
if isempty(data)
    CM=-0.2;
else
    CM=data.CM;
end

v = [1 2 3 5];
[C,Hcdw] = contour(X2,Y2,10000*zf1,v,'-k','LineWidth',0.5);
clabel(C,Hcdw);
hold on;
v = 10:10:200;
[C,Hcdw] = contour(X2,Y2,10000*zf1,v,'-k','LineWidth',0.5);
clabel(C,Hcdw);

if ~isempty(KD2)
    KD2=sortrows(KD2,2);
    plot(KD2(:,1),KD2(:,2),'b*');
    plot(KD2(:,1),KD2(:,2),'m-','LineWidth',2);
end

if ~isempty(KD1)
    plot(KD1(:,1),KD1(:,2),'b^');
end

axis([ Mmin Mmax,CLmin,CLmax]);


end

