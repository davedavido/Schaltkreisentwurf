
function res = parse_mif_file(f_name)
%%%%%%%%%%
%%%%%%% 
% B_Integer ... Number of bits for the integer part of the FP numbers
%%%%%%%%%%%%%%

%% open file
fid = fopen(f_name);

A = fscanf(fid,'%s');

%%%% Extract WIDTH of Memory Elements

temps = 'WIDTH';

for it = 1:length(A);

    if strcmp([A(it) A(it + 1) A(it + 2) A(it +3) A(it + 4)],temps)
        itW = it + 6;
        tempW = [A(itW)];
        for itf = itW+1:itW + 10
            if strcmp(A(itf),';') == 0
                tempW = [tempW A(itf)];
            else
                break;
            end
        end
        W = str2double(tempW)
        break;
    end
end

temps = 'DEPTH';

for it = 1:length(A);

    if strcmp([A(it) A(it + 1) A(it + 2) A(it +3) A(it + 4)],temps)
        itD = it + 6;
        tempD = [A(itD)];
        for itf = itD+1:itD + 10
            if strcmp(A(itf),';') == 0
                tempD = [tempD A(itf)];
            else
                break;
            end
        end
        D = str2double(tempD)
        break;
    end
end

%%%% Init res output vector

res = zeros(D,1);

%%%%%%%%%%%%%% Start Reading %%%%%%%%%%%%%%%%%%%
%%% Find start %%%%%%
temps = 'CONTENTBEGIN';

for it = itD:length(A);
    if strcmp([A(it) A(it + 1) A(it + 2) A(it +3) A(it + 4) A(it + 5) A(it + 6) A(it +7) A(it + 8) A(it + 9) A(it +10) A(it + 11)],temps)
        itStart = it + 12
        break;
    end
end

%%%%%%%%%%%%%% Extract numbers %%%%%%%%%%%%%%%%
itD = 0;
for itDD = 1:D
    itD = itD + 1;
    %%% check for End of file
    tempEND = 'END;';
    if strcmp([A(itStart) A(itStart + 1) A(itStart + 2) A(itStart + 3)],tempEND) == 1
       break 
    end
    
    %%%%%%%%%%%%%% Start
    for itc = itStart:length(A)
       if strcmp(A(itc),';')
          itEnd = itc; 
          break; 
       end
    end
    
    temps = A(itStart:itEnd-1);
    
    %%%% Extract Value %%%%%%%%%%%%%
    for ittemp = 1:length(temps)
       if strcmp(temps(ittemp),':')
           tempmem = temps(1:ittemp-1);
           tempvalue = temps(ittemp+1:end);
           break; 
       end
    end
    
%     valueInt = bin2dec(tempvalue([2:B_Integer]));
%     valueFrac = 2^-(W - B_Integer)*bin2dec(tempvalue([B_Integer+1:end]));
%     %value = ((-1)^(tempvalue(1))).*(valueInt + valueFrac);
%     if bin2dec(tempvalue(1)) == 0
%         value = (valueInt + valueFrac);
%     elseif bin2dec(tempvalue(1)) == 1
%         value = valueInt - (2^(B_Integer-1)) + valueFrac;
%     end   
      
    valueInt = bin2dec(tempvalue([2:end]));
   
%     if bin2dec(tempvalue(1)) == 0
        value = valueInt;
%         value = value*(2^(-(W-B_Integer-1)));
%     elseif bin2dec(tempvalue(1)) == 1
%         value = valueInt - (2^((W-1)));
%         value = value*(2^(-(W-B_Integer-1)));
%     end   
    
    
    %%%%%%% Memory Allocation %%%%%%
    if strcmp(tempmem(1),'[')  %% multiple value [09..FF]:110001010
        
        for ittemp = 2:length(tempmem)-1
           if strcmp([tempmem(ittemp) tempmem(ittemp+1)],'..') == 1
              upper = tempmem(ittemp + 2:length(tempmem)-1);     
              lower = tempmem(2:ittemp-1);
              numel = hex2dec(upper) - hex2dec(lower) + 1;
              break;
           end
        end
        res([itD:itD+numel-1]) = value;
        itD = itD+numel-1;
        itStart = itEnd + 1;
    else %% only one value
        res(itD) = value;
        itStart = itEnd + 1;
    end
  
    
end



fclose(fid);

end
