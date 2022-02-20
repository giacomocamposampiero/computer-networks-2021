# Voice Activity Detection

## How to run the script
In order to execute the script, open vad.m file with Matlab and run it (if necessary change Matlab path to the
current folder). The script will automatically load data from every file in the "data/" folder whose name is in
the format "inputaudio*.data". Then, the corresponding results will be saved in the "output/" folder in a file
named "outputVAD*.txt", where * is the corresponding substring of the input file name.

## Linux command to run the script
```
matlab -nodisplay -r vad.m
```