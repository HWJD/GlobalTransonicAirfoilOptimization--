function istat = Run_vgk

% Setting working directory and input name

    classpath = fileparts(which(mfilename)); % working directory, where vgk.exe needs to be
    vgk_input_name = 'Run_vgk';
 
% Write vgk command file

    fid = fopen([classpath filesep vgk_input_name '.inp'],'w'); 

    fprintf(fid,'VGK\n'); % Name given to output file

    fclose(fid);

% Execute vgk and input the command file

    cmd = sprintf('cd %s && vgk.exe < Run_vgk.inp',...
            classpath); 
        
% Check for errors        

    [status,result] = system(cmd);
    
    if (status~=0),
        disp(result);
%         error('Run_vgk:system','VGK execution failed');
    end;
    
    istat = status;
    
end


