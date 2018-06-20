function istat = Run_vgkcon(var)

Ivisc = var(1);
CL_req = var(2);
Mach = var(3);
Re = var(4);
if CL_req == 0
    Alpval = var(5);
    CLval = 0.0;
elseif CL_req == 1
    CLval = var(5);
    Alpval = var(6);
end
Xtrans = var(7);

% Setting working directory and input name

classpath = fileparts(which(mfilename));
vgkcon_input_name = 'Run_vgkcon';

% Write vgkcon command file

fid = fopen([classpath filesep vgkcon_input_name '.inp'],'w'); %filesep separates each file in a path string

fprintf(fid,'VGK\n');   % Name given to all output files
fprintf(fid,'This is a trial run of vgk\n'); % Title in output file

%visc = input('Please enter 1 for Viscous or 0 for Inviscid run: '); % Chose between viscous/inviscid run

if Ivisc == 0
    
    fprintf(fid,'0\n');           % Inviscid run: 0
    fprintf(fid,'1\n');           % Continuation run: 0, New run: 1
    fprintf(fid,'VGK.DAT\n');     % Aerofoil coordinates file
    fprintf(fid,'y\n');           % Output table of aerofoil slopes: y/n
    fprintf(fid,'y\n');           % Output file grid: y/n
    fprintf(fid,'n\n');           % Output binary dump: y/n
    fprintf(fid,'%f\n',Mach);     % Mach number (up to 4 decimale places)
    fprintf(fid,'%f\n',Alpval);   % Incidence in deg.
    fprintf(fid,'n\n');           % Change any default paramteres: y/n
    
elseif Ivisc == 1
    
    fprintf(fid,'1\n');           % Viscous run: 1
    fprintf(fid,'1\n');           % Continuation run: 0, New run: 1
    fprintf(fid,'VGK.DAT\n');     % Aerofoil coordinates file
    fprintf(fid,'y\n');           % Output table of aerofoil slopes: y/n
    fprintf(fid,'y\n');           % Output file grid: y/n
    fprintf(fid,'n\n');           % Output binary dump: y/n
    
    % Choosing Mach number
    
    fprintf(fid,'%f\n',Mach);     % Mach number (up to 4 decimal places)
    
    % Choosing incidence
    
    fprintf(fid,'%f\n',Alpval);    % Incidence in deg.
    
    % Choosing CL
    
    if CL_req == 1
        fprintf(fid,'1\n');        % Is CL required?
        fprintf(fid,'%f\n',CLval); % CL required
    elseif CL_req == 0
        fprintf(fid,'0\n');        % Given incidence is required
    end
    
    % Choosing Reynolds number
    
    fprintf(fid,'%f\n',Re);   % Reynolds number (up to 3 sig figures)
    
    fprintf(fid,'%f\n',Xtrans);    % Fixing XTU
    fprintf(fid,'%f\n',Xtrans);    % Fixing XTL
    
    fprintf(fid,'y\n');       % Change any default paramteres: y/n
    fprintf(fid,'y\n');       % Change default for NSG: 160
    fprintf(fid,'160\n');     % Fine mesh size NSG
    fprintf(fid,'y\n');       % Change default for NSC: 100
    fprintf(fid,'600\n');     % NSC number coarse mesh iterations
    fprintf(fid,'y\n');       % Change default for NSF: 200
    fprintf(fid,'900\n');     % NSF mumber fine grid ietartions
    fprintf(fid,'y\n');       % Change default for XS: 1.9
    fprintf(fid,'1.8\n');     % Over-relaxation parameter XS
    fprintf(fid,'y\n');       % Change default for XM: 1.0
    fprintf(fid,'1.0\n');     % Under-relaxation parameter XM
    
    % For viscous case with separation reduce relaxation factor for robustness
    fprintf(fid,'y\n');       % Change default for GVISCC: 0.15
    fprintf(fid,'0.05\n');    % Coarse BL relaxation factor GVISCC
    fprintf(fid,'y\n');       % Change default for NVISCC: 5
    fprintf(fid,'5\n');       % N invis iter between BL coarse:
    % For viscous case with separation reduce relaxation factor for robustness
    fprintf(fid,'y\n');       % Change default for GVISCF: 0.075
    fprintf(fid,'0.025\n');   % Fine BL relaxation factor GVISCF
    fprintf(fid,'y\n');       % Change default for NVISCF: 5
    fprintf(fid,'5\n');       % N invis iter between BL fine:
    
    fprintf(fid,'y\n');       % Change default for DD21: 0.0
    fprintf(fid,'0.0\n');     % XTU momentun increment
    fprintf(fid,'y\n');       % Change default for DD22: 0.0
    fprintf(fid,'0.0\n');     % XTL momentun increment
    fprintf(fid,'y\n');       % Change default for EP: 0.8
    fprintf(fid,'0.8\n');     % Artificial viscosity
    fprintf(fid,'y\n');       % Change default for QCP: 0.25
    fprintf(fid,'0.25\n');    % Partially conservative
    
end

fclose(fid);

% Execute vgkcon and input the command file

cmd = sprintf('cd %s && vgkcon.exe < Run_vgkcon.inp',...
    classpath);

% Check for errors

[status,result] = system(cmd);

if (status~=0),
    disp(result);
    error('Run_vgkcon:system','VGKCON execution failed');
end;

istat = status;

end




