% read input from file as binary uint
input_name = 'input.data';
inid = fopen(input_name, 'r');
input = fread(inid, Inf, 'uint32');

% create output file
output_name = 'UTF8.data';
outid = fopen(output_name,'w+');

% iterate over each UCS-4 codepoint
for i = 1 : size(input)
    
    % get the decimal representation of the word and its binary size
    dec = input(i);
    dim = strlength(dec2bin(input(i)));
    % allocate a index to iterate over word bits
    pos = 1;
    
    if(dec <= 127) % 7 bit
        % the codepoint has less than 7 figures, directly wrote it as a  
        % single byte in the output file (ASCII codepoint)
        fwrite(outid, dec, 'uint8');
    else
        % the codepoint has more than 7 figures               
        % get the number of bytes necessary to represent the codepoint
        if(dec <= 2047) % 11 bit
            num_bytes = 2;
        elseif(dec <= 65535) % 16 bit
            num_bytes = 3;
        elseif(dec <= 2097151) % 21 bit
            num_bytes = 4;
        elseif(dec <= 67108863) % 26 bit
            num_bytes = 5;
        elseif(dec <= 2147483647) % 31 bit
            num_bytes = 6;
        elseif(dec <= 68719476735) % 36 bit
            num_bytes = 7;
        else 
            error('Invalid input');
        end
        
        % allocate the codepoint vector
        codepoint = zeros(num_bytes, 1, 'uint8');    
        % build every codepoint byte
        for j = 1 : num_bytes
            if(j ~= num_bytes)
                % default 10xxxxxx offset for payload
                byte = 128;
            else 
                % header byte
                byte = 0;
            end
            % add for each bit the corresponding 2^bit value to the byte
            bit = 0;
            while(bit < 6 && pos <= dim)
                byte = byte + bitget(dec,pos)*(2^bit);
                pos = pos + 1;
                bit = bit + 1;
            end     
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
        
        % write the codepoints in the output file
        for j = 1 : num_bytes
            fwrite(outid, codepoint(j), 'uint8');
        end
    end
end

% close files
fclose(inid);
fclose(outid);