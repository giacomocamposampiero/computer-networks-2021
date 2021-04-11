% read input from file as binary uint
input_name = 'UTF8.data';
inid = fopen(input_name, 'r');
input = fread(inid, Inf, 'uint8');

% create output file
output_name = 'output.data';
outid = fopen(output_name,'w+');

% declare the codepoint container variable and initialize maxpower
codepoint = 0;
maxpower = -1;

% for each byte of the input file
for i = 1 : size(input)
    
    % get decimal value of the current byte
    dec = input(i);
    
    % check the byte MSB; if it's a 0, the byte is an ASCII code, whereas a 
    % more deep analysis is needed
    if(bitget(dec, 8) == 0)
        % ASCII code
        % directly write the number in output as a 32 bit integer
        fwrite(outid, dec, 'uint32');
        
    else
        if(bitand(dec, uint8(192)) == 128)  % case 10xxxxxx
            % payload byte, read the content and sum it to the current
            % codepoint
            % index for the bits starting from the MSB of the byte content
            bit = 6;
            while(bit > 0)
                codepoint = codepoint + bitget(dec,bit)*2^maxpower;
                maxpower = maxpower - 1;
                bit = bit - 1;
            end
            % if it's the last payload byte
            if(maxpower == -1)
                % save the codepoint and restart it
                fwrite(outid, codepoint, 'uint32');
                codepoint = 0;
            end
        else
            % header byte
            % if maxpower is not 0, the script had not completed yet the
            % parsing of a previous codepoint --> bad file formatting
            if(maxpower ~= -1)
                error('Bad input format!');
            end
            
            % depending on the prefix, set the maximum exponent and the
            % number of content bit in the header
            if(bitand(dec, uint8(224)) == 192)  % case 110xxxxx
                maxpower = 10;
                remaining = 5;
            elseif(bitand(dec, uint8(240)) == 224) % case 1110xxxx
                maxpower = 15;
                remaining = 4;
            elseif(bitand(dec, uint8(248)) == 240) % case 11110xxx
                maxpower = 20;
                remaining = 3;
            elseif(bitand(dec, uint8(252)) == 248) % case 111110xx
                maxpower = 25;
                remaining = 2;
            elseif(bitand(dec, uint8(254)) == 252) % case 1111110x
                maxpower = 30;
                remaining = 1;
            elseif(bitand(dec, uint8(255)) == 254) % case 11111110
                maxpower = 35;
                remaining = 0;
            else 
                error('Bad input format');
            end
            
            % add the content bit contained in the header to the codepoint
            while(remaining > 0)
                codepoint = codepoint + bitget(dec,remaining) * 2^maxpower;
                maxpower = maxpower - 1;
                remaining = remaining - 1;
            end
        end
    end
end

% close files
fclose(inid);
fclose(outid);