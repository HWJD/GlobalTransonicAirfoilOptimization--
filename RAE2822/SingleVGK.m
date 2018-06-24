function [ data ] = SingleVGK( Mach,AlpCL )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
n_mach=1;
n_alpCL=1;
Ivisc = 1;              % 0 - inviscid ; 1 - viscous
%RAE2822 
Re = 6.5;                % Reynolds No for viscous cases
Xtrans = 0.05;          % Transition location on upper/lower surface
%RAE5225
% Re = 20;                % Reynolds No for viscous cases
% Xtrans = 0.05;          % Transition location on upper/lower surface
% Re = 6.04;                % Reynolds No for viscous cases
% Xtrans = 0.05;          % Transition location on upper/lower surface
% Re = 30;                % Reynolds No for viscous cases
% Xtrans = 0.03;          % Transition location on upper/lower surface
CL_req = 1;             % 0 - specify incidence ; 1 - specify target CL

% AlpCLval = -0.5; 
AlpCLval = 0;         % value of initial incidence for target CL runs

% ordsfile = 'rae5225.dat';
ordsfile = 'geometry.dat';

% ordsfile = 'opt_1pt.dat';


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


        
var(1)= Ivisc;
var(2)= CL_req;
var(3)= Mach;
var(4)= Re;
var(5)= AlpCL;
var(6)= AlpCLval;
var(7)= Xtrans;


istat1 = Run_vgkcon(var);
if (istat1==0)    
   istat2 = Run_vgk;
   if (istat2==0)
        data = Read_data(n_mach,n_alpCL);
       save('Polar_data','data');
    else
        if AlpCL>=0.6
            AlpCLval = 0.5; 
        else
            AlpCLval = -0.5; 
        end
        var(6)= AlpCLval;

        istat1 = Run_vgkcon(var);
        if (istat1==0)

           istat2 = Run_vgk;
           if (istat2==0)
               data = Read_data(n_mach,n_alpCL);
               save('Polar_data','data');
            else
               data=[];
           end
        end
    end
else
    if AlpCL>=0.6
        AlpCLval = 0.5; 
    else
        AlpCLval = -0.5; 
    end
    var(6)= AlpCLval;

    istat1 = Run_vgkcon(var);
    if (istat1==0)   
       istat2 = Run_vgk;
       if (istat2==0)
           data = Read_data(n_mach,n_alpCL);
           save('Polar_data','data');
        else
           data=[];
       end
    end
end


        

end

