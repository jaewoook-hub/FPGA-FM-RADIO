vlib work
vcom -work work constants.vhd
vcom -work work components.vhd
vcom -work work fifo.vhd
vcom -work work square.vhd
vcom -work work multiply.vhd
vcom -work work addsub.vhd
vcom -work work read_iq.vhd
vcom -work work gain.vhd
vcom -work work fir.vhd
vcom -work work fir_decimated.vhd
vcom -work work fir_complex.vhd
vcom -work work iir.vhd
vcom -work work demodulate.vhd
vcom -work work radio.vhd
vcom -work work radio_tb.vhd

vsim +notimingchecks -L work work.radio_tb -wlf vsim.wlf

add wave -noupdate -group TEST_BENCH -radix hexadecimal /radio_tb/*
add wave -noupdate -expand -group TOP_LEVEL -radix hexadecimal /radio_tb/top_inst/*
add wave -noupdate -group INPUT_BUFFER -radix hexadecimal /radio_tb/top_inst/input_buffer/*
add wave -noupdate -group INPUT_READ -radix hexadecimal /radio_tb/top_inst/input_read/*
add wave -noupdate -group I_BUFFER -radix hexadecimal /radio_tb/top_inst/i_buffer/*
add wave -noupdate -group Q_BUFFER -radix hexadecimal /radio_tb/top_inst/q_buffer/*
add wave -noupdate -group CHANNEL_FILTER -radix hexadecimal /radio_tb/top_inst/channel_filter/*
add wave -noupdate -group I_FILTERED_BUFFER -radix hexadecimal /radio_tb/top_inst/i_filtered_buffer/*
add wave -noupdate -group Q_FILTERED_BUFFER -radix hexadecimal /radio_tb/top_inst/q_filtered_buffer/*
add wave -noupdate -group DEMODULATOR -radix hexadecimal /radio_tb/top_inst/demodulator/*
add wave -noupdate -group DEMODULATOR -radix hexadecimal /radio_tb/top_inst/demodulator/demod_process/*
add wave -noupdate -group RIGHT_CHANNEL_BUFFER -radix hexadecimal /radio_tb/top_inst/right_channel_buffer/*
add wave -noupdate -group RIGHT_LOW_FILTER -radix hexadecimal /radio_tb/top_inst/right_low_filter/*
add wave -noupdate -group RIGHT_LOW_BUFFER -radix hexadecimal /radio_tb/top_inst/right_low_buffer/*
add wave -noupdate -group LEFT_CHANNEL_BUFFER -radix hexadecimal /radio_tb/top_inst/left_channel_buffer/*
add wave -noupdate -group LEFT_BAND_FILTER -radix hexadecimal /radio_tb/top_inst/left_band_filter/*
add wave -noupdate -group LEFT_BAND_BUFFER -radix hexadecimal /radio_tb/top_inst/left_band_buffer/*
add wave -noupdate -group PRE_PILOT_BUFFER -radix hexadecimal /radio_tb/top_inst/pre_pilot_buffer/*
add wave -noupdate -group PILOT_FILTER -radix hexadecimal /radio_tb/top_inst/pilot_filter/*
add wave -noupdate -group PILOT_FILTERED_BUFFER -radix hexadecimal /radio_tb/top_inst/pilot_filtered_buffer/*
add wave -noupdate -group SQUARER -radix hexadecimal /radio_tb/top_inst/squarer/*
add wave -noupdate -group PILOT_SQUARED_BUFFER -radix hexadecimal /radio_tb/top_inst/pilot_squared_buffer/*
add wave -noupdate -group PILOT_SQUARED_FILTER -radix hexadecimal /radio_tb/top_inst/pilot_squared_filter/*
add wave -noupdate -group PILOT_BUFFER -radix hexadecimal /radio_tb/top_inst/pilot_buffer/*
add wave -noupdate -group MULTIPLIER -radix hexadecimal /radio_tb/top_inst/multiplier/*
add wave -noupdate -group LEFT_MULTIPLIED_BUFFER -radix hexadecimal /radio_tb/top_inst/left_multiplied_buffer/*
add wave -noupdate -group LEFT_LOW_FILTER -radix hexadecimal /radio_tb/top_inst/left_low_filter/*
add wave -noupdate -group LEFT_LOW_BUFFER -radix hexadecimal /radio_tb/top_inst/left_low_buffer/*
add wave -noupdate -group ADDER_SUBTRACTOR -radix hexadecimal /radio_tb/top_inst/adder_subtractor/*
add wave -noupdate -group LEFT_EMPH_BUFFER -radix hexadecimal /radio_tb/top_inst/left_emph_buffer/*
add wave -noupdate -group RIGHT_EMPH_BUFFER -radix hexadecimal /radio_tb/top_inst/right_emph_buffer/*
add wave -noupdate -group DEEMPHASIZE_LEFT -radix hexadecimal /radio_tb/top_inst/deemphasize_left/*
add wave -noupdate -group LEFT_DEEMPH_BUFFER -radix hexadecimal /radio_tb/top_inst/left_deemph_buffer/*
add wave -noupdate -group DEEMPHASIZE_RIGHT -radix hexadecimal /radio_tb/top_inst/deemphasize_right/*
add wave -noupdate -group RIGHT_DEEMPH_BUFFER -radix hexadecimal /radio_tb/top_inst/right_deemph_buffer/*
add wave -noupdate -group GAIN_LEFT -radix hexadecimal /radio_tb/top_inst/gain_left/*
add wave -noupdate -group LEFT_GAIN_BUFFER -radix hexadecimal /radio_tb/top_inst/left_gain_buffer/*
add wave -noupdate -group GAIN_RIGHT -radix hexadecimal /radio_tb/top_inst/gain_right/*
add wave -noupdate -group RIGHT_GAIN_BUFFER -radix hexadecimal /radio_tb/top_inst/right_gain_buffer/*
run -all
#run 500 ns
configure wave -namecolwidth 325
configure wave -valuecolwidth 100
configure wave -timelineunits ns
WaveRestoreZoom {0 ns} {80 ns}