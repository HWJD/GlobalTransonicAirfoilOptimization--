clear all
clc
close all

Ivisc = 1;              % 0 - inviscid ; 1 - viscous
Re = 20;                % Reynolds No for viscous cases
Xtrans = 0.05;          % Transition location on upper/lower surface
CL_req = 1;             % 0 - specify incidence ; 1 - specify target CL

n_mach = 1;            % number of Mach cases
mach_lo = 0.73;         % lower value for range of Mach
mach_hi = 0.0;         % upper value for range of Mach

n_alpCL = 1;           % number of incidence or CL cases
alpCL_lo = 0.60;       % lower value for range of incidence or CL
alpCL_hi = 0.0;       % upper value for range of incidence or CL

AlpCLval = 0.0;         % value of initial incidence for target CL runs

ordsfile = 'rae5225.dat';

if(n_mach > 1)
    mach_step = (mach_hi - mach_lo)/(n_mach - 1);
    Mach = mach_lo: mach_step : mach_hi;
else
    mach_hi = mach_lo;
    Mach(1) = mach_lo;
end

if(n_alpCL > 1)
    alpCL_step = (alpCL_hi - alpCL_lo)/(n_alpCL - 1);
    AlpCL = alpCL_lo: alpCL_step : alpCL_hi;
else
    alpCL_hi = alpCL_lo;
    AlpCL(1) = alpCL_lo;
end

% Setting working directory and input name
if ispc
   classpath = fileparts(which(mfilename));
elseif isunix
   classpath = pwd;
end

% Copy ordsfile to default vgk.dat
if exist([classpath filesep ordsfile], 'file') == 2
    if ispc
        cmd = sprintf('cd %s && copy %s VGK.DAT',classpath,ordsfile);
    elseif isunix
        cmd = sprintf('cd %s && cp %s vgk.dat',classpath,ordsfile);
    end
    system(cmd);
else
    error([Run_Polar ':'],'input aerofoil does not exist');
end

for idp=n_mach:-1:1
    
    for jdp=n_alpCL:-1:1
        
        var(1)= Ivisc;
        var(2)= CL_req;
        var(3)= Mach(idp);
        var(4)= Re;
        var(5)= AlpCL(jdp);
        var(6)= AlpCLval;
        var(7)= Xtrans;
        
        istat1 = Run_vgkcon(var);
        
        if (istat1==0)
            
           istat2 = Run_vgk;
           
        end
        
        if (istat2==0)
            
           data(idp,jdp) = Read_data(n_mach,n_alpCL);
           save('Polar_data','data')
           
        end
        
    end
    
end

save('Polar_data','data')

% Write design point output file
fid = fopen([classpath filesep 'data.out'],'w');
fprintf(fid,'  M   Alpha   CL      CDV      CDW     CD        CM    MLD\n');

for jdp=1:n_alpCL
    for idp=1:n_mach
        CDTOT=data(idp,jdp).CDV + data(idp,jdp).CD2;
        MLD=data(idp,jdp).EM*data(idp,jdp).CL/CDTOT;
        fprintf(fid,'%1.3f %1.3f %1.4f %1.6f %1.6f %1.6f %1.4f %2.3f\n',...
            data(idp,jdp).EM,data(idp,jdp).ALP,data(idp,jdp).CL,...
            data(idp,jdp).CDV,data(idp,jdp).CD2,CDTOT,...
            data(idp,jdp).CM,MLD);
    end
end
fclose(fid);