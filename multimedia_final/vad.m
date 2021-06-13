% Voice Activity Detection Algorithm

% uncomment next line to enter debug mode
 debug=1;

% read the name of files contained in data/ folder which respect the 
% defined syntax 'inputaudioN.data'
files = struct2cell(dir('data/inputaudio*.data'));

% for each audio data file contained in the directory
for i = 1:size(files,2)

    % get file name
    name = files{1,i};
    % get input number
    number = extractBetween(name, "inputaudio", ".data");
    % load track data
    inid = fopen(strcat('data/',name), 'r'); 
    data = fread(inid, 'int8');
    fclose(inid);  
    
    % number of packet of the track, floor of the division data/packet_size
    pck_num = fix(size(data, 1)/160);
    pck_dim = 160;
    % classification values for each packet (0:INACTIVE, 1:ACTIVE)
    output = 48.*ones(pck_num, 1);
    % learning rate for adapting thresholds
    p = 0.15;
    
    % classifiers output
    class = zeros(3,1);
    
    % simulate the flow of sound data; packets are considered in fixed size
    % windows of 3 packets; since every packet contains 20ms of sound
    % information, this will generate a total delay of 40ms, not
    % comprehensive of computation and network time
    
    % working on the assumption that the first 200ms of the track do not
    % contain human voice samples, compute thresholds and other parameters
    % used by some of the methods implemented for INACTIVE frames
    ns_energy = 0;
    f_thr = 200;
    for ii = 1:9
        wd = data(1+(ii-1)*pck_dim:(ii+2)*pck_dim);
        ns_energy = ns_energy + 0.1*sum(wd.^2)/(pck_dim*3);
    end
    
    % flow of sound data, from packet 10 to the end of the flow
    % packets are analyzed in groups of 3 with step of 1 packet; with this
    % method, packets are never considered as single unit and this may help
    % classification
    for ii = 10:(pck_num-2)
        % get the corresponding window frames
        wd = data(1+(ii-1)*pck_dim:(ii+2)*pck_dim);
        % FREQUENCY CLASSIFICATION
        [class(3), f_thr] = frame_freq_vad(wd, f_thr, 3, p);
        if(class(3) ~= 1)
            % ENERGY CLASSIFICATION
            [class(1), ns_energy] = frame_energy_vad(wd, ns_energy, 2, p);
            if(class(2) ~= 1)
                % ZERO CROSSINGS CLASSIFICATION
                class(2) = frame_zc_vad(wd);
            end
        end
          
        if(any(class))
            % at least one classificator classificated the frame as ACTIVE
            % set an ACTIVE classification for the frame
            output(ii) = 49;
        end
    end
  
    % open output file 
    outname = ['output/outputVAD' number{1} '.txt'];
    outid = fopen(outname, 'w+');
    % write results to the output text file, as ASCII characters
    fwrite(outid, output, 'uint8');
    fclose(outid);
        
  	%%% START DEBUG
    if(debug == 1)
        % get output signal
        dec = zeros(size(data, 1),1);
        for ii = 0:pck_num-1
            for iii = 1:160
                dec(1+160*ii+iii) = data(1+160*ii+iii).*(output(ii+1, 1)-48);
            end
         end  
%         % plot data
%         fig = figure();
%         plot(data, 'r');
%         hold on
%         plot(dec, 'k');
%         saveas(fig, strcat("images/res", number), 'epsc');
%         % listen to original and modified tracks
        player = audioplayer(data, 8000);
        play(player);
        pause(8);
        player = audioplayer(dec, 8000);
        play(player);
        pause(8);
%         % write resulting track as wav file
        audiowrite(strcat('outputaudio', int2str(i), '.wav'), dec, 8000);
    %%% END DEBUG
    end

end

% close all files and clear the environment
fclose('all');
clear;

function [classification, updtd] = frame_energy_vad(frame, ns_energy, k, p)
    % compute frame energy
    energy = sum(frame.^2)/size(frame,1);
    if(energy > k*ns_energy)
        % if energy is higher than INACTIVE threshold energy
        % classify the frame as an ACTIVE frame
        classification = 1;
        % set delta INACTIVE frame energy to zero
        updtd = ns_energy;
    else
        % if energy is lower than INACTIVE threshold energy
        % classify the frame as an INACTIVE frame
        classification = 0;
        % compute delta INACTIVE frame energy that has to be added to
        % initial ns_energy
        updtd = ns_energy*(1-p) + energy*p;
    end
end

function classification = frame_zc_vad(frame)
    classification = 0;
    crosses = 0;
    % compute the number of zero crossings in the frame
    for i = 2:size(frame)
        crosses = crosses + abs(sign(frame(i))-sign(frame(i-1))); 
    end
    % the number of zero crossings usually lies in a fixed range, 
    % between 15 and 50 for a 30ms sound frame, when the frame
    % correspond to a voice frame; on the other hand, the number is
    % randomic when the frame is a noise frame
    % we decided to expand a little bit the limits of the range as missing
    % a voice frame is considered generally more dangerous than including a
    % false ACTIVE classification
    if(crosses >= 10 && crosses <= 70)
        classification = 1;
    end  
end

function [classification, updtd] = frame_freq_vad(frame, threshold, k, p)
    % default classification value to 0
    classification = 0;
    % get power for the frame frequency spectrum
    pw = pspectrum(frame);
    % compute the integral of power for frequencies in the range 1-1kHz
    intg = sum(pw(1:1500));
    if(intg > k*threshold)
        % ACTIVE frame, set corresponding output
        classification = 1;
        updtd = threshold;
    else
        % INACTIVE frame, update value of threshold for classification 
        updtd = threshold*(1-p) + intg*p;
    end
end