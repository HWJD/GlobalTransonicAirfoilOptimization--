function data = Read_data(n_mach,n_alpCL)

S = textread('VGK.ful','%s','delimiter','\n'); % Reads the data file

%% Standard Data ( CP, P/P0 & M)

fid = fopen('VGK.ful', 'r');                    % Assigns a file ID to the data file
pos_stand = strmatch('T        X         Z',S); % Locates row number for the standard parameters
if ~isempty(pos_stand)
    stand = textscan(fid,' %f%f%f%f%f%f','Delimiter',' ',...
        'MultipleDelimsAsOne',true,'CollectOutput',1,...
        'HeaderLines',pos_stand); % Scans the parameters into memory
    fclose(fid);                                    % Closes file and removes the file ID
    Stand_Data = cell2mat(stand);                   % converts data in memory to a matrix

    % Storing values in arrays
    data.n_mach = n_mach;
    data.n_alpCL = n_alpCL;
    data.X_stand(1,:) = Stand_Data(:,2);
    data.Z_stand(1,:) = Stand_Data(:,3);
    data.CP_stand(1,:) = Stand_Data(:,4);
    data.EML_stand(1,:) = Stand_Data(:,6);

    %% Boundary Layer Data

    % Determining start and end points for Boundary Layer Data

    BL_UP_start = strmatch('UPPER-SURFACE BOUNDARY-LAYER DATA',S)+5; % Locate starting point of Upper Surface BL Data
    BL_LO_start = strmatch('LOWER-SURFACE BOUNDARY-LAYER DATA',S)+5; % Locate starting point of Lower Surface BL Data

    BL_end= strmatch('100.00000',S);
    BL_UP_end  = BL_end(1)-1; % Locate end point of Upper Surface BL Data
    BL_LO_end = BL_end(2)-1;  % Locate end point of Lower Surface BL Data

    % Reading in upper-surface BL data

    m=1;
    for k=BL_UP_start:BL_UP_end;    % create for loop ranging from start to finish of data
        ful = sscanf(S{k,1},'%f');  % scan each line for a floating point number
        le=size(ful);               % gives size of the scanned values

        if le(1) > 0                % Only read if there is a value of > 0 ( for non-floating i.e. string, the value = 0)
            for t=1:le(1)
                BL_Upper_Surface_Data(m,t)=ful(t);  % store the value in matrix
            end
            m=m+1;
        end
    end

    % Reading in lower-surface BL data

    n=1;
    for k=BL_LO_start:BL_LO_end;
        ful = sscanf(S{k,1},'%f');
        le=size(ful);

        if le(1) > 0
            for t=1:le(1)
                BL_Lower_Surface_Data(n,t)=ful(t);
            end
            n=n+1;
        end
    end

    % Display data in array form

    %BL_Upper_Surface_Data;
    %BL_Lower_Surface_Data;

    % Storing values in arrays, first for upper- then for lower-surface

    data.X_BL_UP(1,:) = BL_Upper_Surface_Data(:,1);
    data.HBAR_BL_UP(1,:) = BL_Upper_Surface_Data(:,2);
    data.DELSTAR_BL_UP(1,:) = BL_Upper_Surface_Data(:,3);
    data.THETA_BL_UP(1,:) = BL_Upper_Surface_Data(:,4);
    data.CFLOC_BL_UP(1,:) = BL_Upper_Surface_Data(:,5);
    data.DELTA_BL_UP(1,:) = BL_Upper_Surface_Data(:,6);

    data.X_BL_LO(1,:) = BL_Lower_Surface_Data(:,1);
    data.HBAR_BL_LO(1,:) = BL_Lower_Surface_Data(:,2);
    data.DELSTAR_BL_LO(1,:) = BL_Lower_Surface_Data(:,3);
    data.THETA_BL_LO(1,:) = BL_Lower_Surface_Data(:,4);
    data.CFLOC_BL_LO(1,:) = BL_Lower_Surface_Data(:,5);
    data.DELTA_BL_LO(1,:) = BL_Lower_Surface_Data(:,6);

    %% Individual parameters (Re, Transition Points, CD1, CD2, M, Incidence, CL, CM, CDP, CDF 7 CDV)

    % Scanning data file for terms and storing in array

    Re = strmatch('R =',S); % Locates rows containing the Reynolds number

    Re_last = Re(end);      % Picks last row
    ful = sscanf(S{Re_last,1},' R = %f TRANSITION PTS XTU = %f XTL = %f '); % Scans row for Re and Transitions points
    data.Re = ful(1);
    data.XTU = ful(2);
    data.XTL = ful(3);

    CD1 = strmatch('CD1=',S); % Locates row containing CD1
    CD1_last = CD1(end);
    ful = sscanf(S{CD1_last,1},' CD1 = %f CD2 = %f'); % Scans row for CD1 and CD2
    if ~isempty(ful)
        data.CD1 = ful(1);
        data.CD2 = ful(2);
        
        EM = strmatch('EM = ', S); % Locate row of Mach number
        EM_last = EM(end);        % Pick last row

        ful = sscanf(S{EM_last,1},' EM = %f ALP = %f');    % Extract Mach number and Incidence
        if ~isempty(ful)
            data.EM = ful(1);
            data.ALP = ful(2);
            ful = sscanf(S{EM_last+1,1},' CL = %f CM = %f');  % Extract CL and CM
            if ~isempty(ful)
                data.CL =ful(1);
                data.CM = ful(2);
                ful = sscanf(S{EM_last+2,1},'  CDP = %f CDF = %f CDP+CDF = %f'); % Extract CDP, CDF and their sum
                if ~isempty(ful)
                    data.CDP = ful(1);
                    data.CDF = ful(2);
                    data.CDP_CDF = ful(3);
                    
                    ful = sscanf(S{EM_last+3,1},'  CDV = %f'); % Extract CDV
                    if ~isempty(ful)
                        data.CDV = ful(1);
                    else
                        data=[];
                    end
                    
                else
                    data=[];
                end
            else
                data=[];
            end           
        else
            data=[];
        end
    else
        data=[];
    end
else
    data=[];
end

end