# Voice Activity Detection

## How to run the script
In order to execute the script, open vad.m file with Matlab and run it (if 
necessary change Matlab path to the current folder). The script will 
automatically load sound tracks from every file in the "data/" subfolder whose 
name is in the format "inputaudio*.data". Then, the corresponding results will 
be saved in the "output/" subfolder in a file named "outputVAD*.txt", where * 
is the corresponding substring of the input file name.

To apply the VAD to a single audio track, just copy the track in the "data/" 
folder and remove all the other tracks in the same folder. Its corresponding 
output will be generated in the "output/" folder.

!!! ATTENTION !!!
Signal Processing Toolbox is needed (pspectrum() function for signal frequency 
analysis is used within the script)

## Linux command to run the script
matlab -batch "vad"

## Results for 5 audio test file
Results for the 5 audio test files given are directly included in this folder.
However, the zip packet is provided with the five inputs already present in the
"data/" folder. Therefore, they can be computed again just by running the 
script.
