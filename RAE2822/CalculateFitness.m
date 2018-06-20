function [ obj ] = CalculateFitness(x,No,Gtype,nVar,ObjFormulation)
% Mmax=0.76;
% Mmin=0.5;
% CLmax=0.75;
% CLmin=0.2;
% NM=53;
% NCL=23;

Mmax=0.76;
Mmin=0.6;
CLmax=0.85;
CLmin=0.5;
NM=35;
NCL=15;
TCM=-0.093;
r=[Mmax,CLmax];
filename='geometry.dat';
eval(['WriteGeometry',Gtype,num2str(nVar),'(filename,x)']);
 [ KD1,KD2,CM,srgtSRGTKRG] = KrigingApproximationDPNLPCA2b1c( Mmax,Mmin,CLmax,CLmin,NM,NCL );

if ~isempty(KD2)&size(KD2,1)>1
    X=[KD2(:,1),ones(size(KD2,1),1)];
    Y=KD2(:,2);
    [b,bint,er] = regress(Y,X);
    er=mean(abs(er));
    b(2)=b(2)-er;
    
    x=[Mmin:0.01:Mmax];
    y=b(1)*x+b(2);
    plot(x,y,'r--','LineWidth',2);
    
    
    CL=b(1)*Mmax+b(2);
    M=(CLmax-b(2))/b(1);

    if M>Mmax|CL>CLmax
        objDD=0;
    else
        objDD=1-0.5*(r(1)-M)*(r(2)-CL)/(CLmax-CLmin)/(Mmax-Mmin);
    end
    
    
else
    objDD=0;
end
r=[Mmin,CLmin];

objCDW=0;
if ~isempty(KD1)
    objCDW=objCDW+(KD1(1,1)-r(1))*(KD1(1,2)-r(2))/(CLmax-CLmin)/(Mmax-Mmin);
    for i=2:size(KD1,1)
        objCDW=objCDW+(KD1(i,1)-KD1(i-1,1))*(KD1(i,2)-r(2))/(CLmax-CLmin)/(Mmax-Mmin);
    end
end

objCM=0;
if  CM<TCM
    objCM=objCM+100*(CM-TCM);
end

switch ObjFormulation
    case 'DD'
        obj=objDD;
    case 'CDW'
        obj=objCDW;
    case 'CDW+DD'
        obj=objDD+objCDW;
    case 'CDW+DD+CM'
        obj=objDD+objCDW+objCM;
end

xlabel('M');
ylabel('CL');
% legend({'Zero C_{Dw} prediceted by KNN','C_{Dw} contour','C_{Dw} contour','Sampling points with VGK calculation','Detected points for DD','Detected points CDW','Approximated boundary'},'Location','SouthOutside')
title(sprintf('obj=%f,CM=%f',obj,CM));
hold off;
f=sprintf('ID%d',No);
saveas(1,f);
end

