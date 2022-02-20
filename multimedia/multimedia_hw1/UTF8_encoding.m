% UCS-4 (UTF-32) ---> UTF-8 script
% This script reads a file 'input.data' where each codepoint is encoded as 
% a 32 bit UTF-32 word. The content of the file is decoded and encoded 
% again in a variable-length format, UTF-8. The output is then written in 
% an output file, named 'UTF8.data'.

% read the input from file as binary uint32
input_name = 'input.data';
inid = fopen(input_name, 'r');
input = fread(inid, Inf, 'uint32');

% create the output file
output_name = 'UTF8.data';
outid = fopen(output_name,'w+');

% iterate over each UCS-4 codepoint
for i = 1 : size(input)
    
    % get the decimal representation of the word and the number of
    % significant bits
    dec = input(i);
    significant_bits = strlength(dec2bin(input(i)));
    
    % allocate an index to iterate over each codepoint bits
    pos = 1;
    
    if(dec <= 127) % 7 bit content
        % the codepoint has less than 7 significant bits, write it as a  
        % single byte in the output file (ASCII codepoint)
        fwrite(outid, dec, 'uint8');
    else
        % the codepoint has more than 7 significant bit               
        % get the number of bytes necessary to represent the codepoint
        if(dec <= 2047) % 11 bit content
            num_bytes = 2;
        elseif(dec <= 65535) % 16 bit content
            num_bytes = 3;
        elseif(dec <= 2097151) % 21 bit content
            num_bytes = 4;
        elseif(dec <= 67108863) % 26 bit content
            num_bytes = 5;
        elseif(dec <= 2147483647) % 31 bit content
            num_bytes = 6;
        elseif(dec <= 68719476735) % 36 bit content
            num_bytes = 7;
        end
        
        % allocate the codepoint vector, where every cell correspond to a
        % codepoint byte
        codepoint = zeros(num_bytes, 1, 'uint8');    
        % build every payload byte, starting from the LSB
        for j = 1 : num_bytes
            if(j ~= num_bytes)
                % default 10xxxxxx offset for payload
                byte = 128;
            else 
                % header byte, no 10xxxxxx needed
                byte = 0;
            end
            % add for each bit the corresponding 2^bit value to the decimal
            % representation of the byte (if the bit is 1)
            bit = 0;
            while(bit < 6 && pos <= significant_bits)
                % get the bit in position pos, multiply it to the
                % corresponding power of two of the actual position in the
                % payload byte and add it to the partial byte total
                byte = byte + bitget(dec,pos)*(2^bit);
                pos = pos + 1;
                bit = bit + 1;
            end  
            % write the byte into the corresponding codepoint position
            codepoint(num_bytes+1-j) = byte;
        end
        
        % header byte
        % add the minimum header bits to the header byte 
        codepoint(1) = codepoint(1) + 192; % 192 = 11xxxxxx
        % add the remaining 1 of the header (one for each exceeding byte
        % after the first two)
        for j = 3 : num_bytes
            codepoint(1) = codepoint(1) + 2^(8-j);
        end
        % write the codepoint in the output file
        for j = 1 : num_bytes
            fwrite(outid, codepoint(j), 'uint8');
        end
    end
end

% close files
fclose(inid);
fclose(outid);