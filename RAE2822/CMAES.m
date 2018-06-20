function [ BestSol,Logbook,xb] = CMAES(nVar)
bu=0.01*ones(1,nVar);
bd=0-bu;
Logbook=[];
%% Problem Settings
VarSize=[1 nVar];       % Decision Variables Matrix Size
VarMin=0;             % Lower Bound of Decision Variables
VarMax=1;             % Upper Bound of Decision Variables
Gtype='HenneHicksCamber';
ObjFormulation='CDW+DD+CM';
%% CMA-ES Settings

% Maximum Number of Iterations
MaxIt=5;

% Population Size (and Number of Offsprings)
lambda=(4+round(3*log(nVar)));

% Number of Parents
mu=round(lambda/2);

% Parent Weights
w=log(mu+0.5)-log(1:mu);
w=w/sum(w);

% Number of Effective Solutions
mu_eff=1/sum(w.^2);

% Step Size Control Parameters (c_sigma and d_sigma);
sigma0=0.3*(VarMax-VarMin);
cs=(mu_eff+2)/(nVar+mu_eff+5);
ds=1+cs+2*max(sqrt((mu_eff-1)/(nVar+1))-1,0);
ENN=sqrt(nVar)*(1-1/(4*nVar)+1/(21*nVar^2));

% Covariance Update Parameters
cc=(4+mu_eff/nVar)/(4+nVar+2*mu_eff/nVar);
c1=2/((nVar+1.3)^2+mu_eff);
alpha_mu=2;
cmu=min(1-c1,alpha_mu*(mu_eff-2+1/mu_eff)/((nVar+2)^2+alpha_mu*mu_eff/2));
hth=(1.4+2/(nVar+1))*ENN;

%% Initialization

ps=cell(MaxIt,1);
pc=cell(MaxIt,1);
C=cell(MaxIt,1);
sigma=cell(MaxIt,1);

ps{1}=zeros(VarSize);
pc{1}=zeros(VarSize);
C{1}=eye(nVar);
sigma{1}=sigma0;

empty_individual.Position=[];
empty_individual.Step=[];
empty_individual.Cost=[];

M=repmat(empty_individual,MaxIt,1);
M(1).Position=unifrnd(VarMin,VarMax,VarSize);
M(1).Step=zeros(VarSize);
x=M(1).Position.*(bu-bd)+bd;
M(1).Cost=CalculateFitness(x,1,Gtype,nVar,ObjFormulation);
TT=[x,M(1).Cost];
Logbook=[Logbook;TT];
BestSol=M(1);

BestCost=zeros(MaxIt,1);

%% CMA-ES Main Loop

for g=1:MaxIt
    
    % Generate Samples
    pop=repmat(empty_individual,lambda,1);
    for i=1:lambda
        pop(i).Step=mvnrnd(zeros(VarSize),C{g});
        pop(i).Position=M(g).Position+sigma{g}*pop(i).Step;
        T=pop(i).Position>VarMax*ones(VarSize);
        if sum(T)~=0
            pop(i).Position(pop(i).Position>VarMax)=VarMax-(pop(i).Position(pop(i).Position>VarMax)-VarMax);
        end
        T=pop(i).Position<VarMin*ones(VarSize);
        if sum(T)~=0
            pop(i).Position(pop(i).Position<VarMin)=VarMin+(VarMin-pop(i).Position(pop(i).Position<VarMin));
        end
        x=pop(i).Position.*(bu-bd)+bd;
        pop(i).Cost=CalculateFitness(x,size(Logbook,1)+1,Gtype,nVar,ObjFormulation);
        TT=[x,pop(i).Cost];
        Logbook=[Logbook;TT];
        
        % Update Best Solution Ever Found
        if pop(i).Cost>BestSol.Cost
            TT=CalculateFitness(x,size(Logbook,1)+1,Gtype,nVar,ObjFormulation);
        
            if TT>pop(i).Cost
                BestSol=pop(i);
            elseif TT>BestSol.Cost
                pop(i).Cost=TT;
                BestSol=pop(i);
            end
        end
    end
    
    % Sort Population
    Costs=[pop.Cost];
    [Costs, SortOrder]=sort(Costs,'descend');
    pop=pop(SortOrder);
  
    % Save Results
    BestCost(g)=BestSol.Cost;
    xb=BestSol.Position.*(bu-bd)+bd;
    
    % Display Results
    disp(['Iteration ' num2str(g) ': Best Cost = ' num2str(BestCost(g))]);
    
    % Exit At Last Iteration
    if g==MaxIt
        break;
    end
        
    % Update Mean
    M(g+1).Step=0;
    for j=1:mu
        M(g+1).Step=M(g+1).Step+w(j)*pop(j).Step;
    end
    M(g+1).Position=M(g).Position+sigma{g}*M(g+1).Step;
    T=M(g+1).Position>VarMax*ones(VarSize);
    if sum(T)~=0
        M(g+1).Position(M(g+1).Position>VarMax)=VarMax-(M(g+1).Position(M(g+1).Position>VarMax)-VarMax);
    end
    T=M(g+1).Position<VarMin*ones(VarSize);
    if sum(T)~=0
        M(g+1).Position(M(g+1).Position<VarMin)=VarMin+(VarMin-M(g+1).Position(M(g+1).Position<VarMin));
    end
    x=M(g+1).Position.*(bu-bd)+bd;
    M(g+1).Cost=CalculateFitness(x,size(Logbook,1)+1,Gtype,nVar,ObjFormulation);
    TT=[x,M(g+1).Cost];
    Logbook=[Logbook;TT];
    if M(g+1).Cost>BestSol.Cost
        TT=CalculateFitness(x,size(Logbook,1)+1,Gtype,nVar,ObjFormulation);
        
        if TT>M(g+1).Cost
            BestSol=M(g+1);
        elseif TT>BestSol.Cost
            M(g+1).Cost=TT;
            BestSol=M(g+1);
        end
    end
    
    % Update Step Size
    ps{g+1}=(1-cs)*ps{g}+sqrt(cs*(2-cs)*mu_eff)*M(g+1).Step/chol(C{g})';
    sigma{g+1}=sigma{g}*exp(cs/ds*(norm(ps{g+1})/ENN-1))^0.3;
    
    % Update Covariance Matrix
    if norm(ps{g+1})/sqrt(1-(1-cs)^(2*(g+1)))<hth
        hs=1;
    else
        hs=0;
    end
    delta=(1-hs)*cc*(2-cc);
    pc{g+1}=(1-cc)*pc{g}+hs*sqrt(cc*(2-cc)*mu_eff)*M(g+1).Step;
    C{g+1}=(1-c1-cmu)*C{g}+c1*(pc{g+1}'*pc{g+1}+delta*C{g});
    for j=1:mu
        C{g+1}=C{g+1}+cmu*w(j)*pop(j).Step'*pop(j).Step;
    end
    
    % If Covariance Matrix is not Positive Defenite or Near Singular
    [V, E]=eig(C{g+1});
    if any(diag(E)<0)
        E=max(E,0);
        C{g+1}=V*E/V;
    end
    
end

%% Display Results

figure;
plot(BestCost, 'LineWidth', 2);
xlabel('Iteration');
ylabel('Best Cost');
grid on;
xb=BestSol.Position.*(bu-bd)+bd;
filename='bestgeometry.dat';
eval(['WriteGeometry',Gtype,num2str(nVar),'(filename,xb)']);
file1=sprintf('geometry-G%d-VGK%d-%s%d-%s.dat',MaxIt,size(Logbook,1),Gtype,nVar,ObjFormulation);
copyfile('geometry.dat', file1);
filenamelog=sprintf('Logbook-G%d-VGK%d-%s%d-%s.mat',MaxIt,size(Logbook,1),Gtype,nVar,ObjFormulation);
save(filenamelog,'Logbook');

end

