% Voice Activity Detection Algorithm

% read the name of files contained in data/ folder which respect the 
% defined syntax 'inputaudioN.data'
files = struct2cell(dir('data/inputaudio*.data'));

% for each file contained in the directory
for i = 1:size(files,2)

    % get file name
    name = files{1,i};
    % load track data
    fileID = fopen(strcat('data/',name), 'r'); 
    data = uint8(fread(fileID));
    
    % DEBUG
    % save input track as .wav file that can be listened
    audiowrite(strcat('output', name(11:11), '.wav'), data, 8000);
    
    % number of packet of the track, floor of the division data/packet size
    pck_num = fix(size(data, 1)/180)-1;
    
    output = energy_vad(data);
    
    % DEBUG
    % apply the filter to the original track and save it as a .wav file, to
    % make possible a comparison between the two tracks
    for k = 0:pck_num-1
        data(1+180*k : 180*(k+1)) = data(1+180*k : 180*(k+1)).*output(1,k+1);
    end
    audiowrite(strcat('outputmod', name(11:11), '.wav'), data, 8000);
end

function [output] = energy_vad(data, pck_num)
    % output classification for each input packet 
    % 0 --> speech packet, 1 --> non-speech packet
    output = zeros(1,pck_num);
    % mean non-speech energy
    ns_energy = 0;
    
    % working on the assumption that the first 200ms of the track does not
    % contain human voice samples, compute the mean non-speech frame energy
    % as mean of the first 10 packets
    for k = 0:9
        pc = double(data(1+180*k : 180*(k+1)));
        ns_energy = ns_energy + sum(pc.^2) / 180;
    end
    ns_energy = ns_energy / 10;
    
    % classify each other packet of the stream
    for packet = 10:pck_num
        bytes = double(data(1+packet*180:(packet+1)*180));
        pck_energy = sum(bytes.^2)/180;
        if(pck_energy > 1.3*ns_energy)
            % packet energy is bigger than two times the mean non-speech
            % energy, classify it as a speech packet
            output(1, packet) = 1;
        else
            % non-speech packet, update mean ns energy
            ns_energy = 0.8*ns_energy + 0.2*pck_energy;
        end
    end
end