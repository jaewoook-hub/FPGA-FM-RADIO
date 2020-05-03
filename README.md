# FPGA-FM-RADIO

Builds an FM Radio written in VHDL and tested in ModelSim.
An audio file from an input file of radio data is created by running.
Audio file contains real and imaginary components of signal.
To run: Build C++ Source Code for audio player -> Run exec.

Quickbuild:
g++ src/fm_radio.cpp src/audio.cpp src/main.cpp -o fm_radio
./fm_radio test/usrp.dat
