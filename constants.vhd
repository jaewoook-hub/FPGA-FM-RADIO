library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package constants is

	constant INPUT_BUFFER_SIZE : natural := 64;
    constant I_BUFFER_SIZE : natural := 64;
    constant Q_BUFFER_SIZE : natural := 64;
    constant I_FILTERED_BUFFER_SIZE : natural := 64;
    constant Q_FILTERED_BUFFER_SIZE : natural := 64;
    constant PRE_PILOT_BUFFER_SIZE : natural := 64;
    constant PILOT_FILTERED_BUFFER_SIZE : natural := 64;
    constant PILOT_SQUARED_BUFFER_SIZE : natural := 64;
    constant PILOT_BUFFER_SIZE : natural := 64;
    constant LEFT_CHANNEL_BUFFER_SIZE : natural := 64;
    constant LEFT_BAND_BUFFER_SIZE : natural := 64;
    constant LEFT_MULTIPLIED_BUFFER_SIZE : natural := 64;
    constant LEFT_LOW_BUFFER_SIZE : natural := 64;
    constant RIGHT_CHANNEL_BUFFER_SIZE : natural := 64;
    constant RIGHT_LOW_BUFFER_SIZE : natural := 64;
    constant LEFT_EMPH_BUFFER_SIZE : natural := 64;
    constant RIGHT_EMPH_BUFFER_SIZE : natural := 64;
    constant LEFT_DEEMPH_BUFFER_SIZE : natural := 64;
    constant RIGHT_DEEMPH_BUFFER_SIZE : natural := 64;
    constant LEFT_GAIN_BUFFER_SIZE : natural := 64;
    constant RIGHT_GAIN_BUFFER_SIZE : natural := 64;
    constant ADC_RATE : natural := 64000000;
    constant USRP_DECIM : natural := 250;
    constant AUDIO_DECIM : natural := 8;
    constant MAX_TAPS : natural := 32;
    constant SAMPLES : natural := 65536 * 4;
    constant QUAD_RATE : natural := ADC_RATE / USRP_DECIM;
    constant AUDIO_RATE : natural := QUAD_RATE / AUDIO_DECIM;
    constant AUDIO_SAMPLES : natural := SAMPLES / AUDIO_DECIM;
    constant VOLUME_LEVEL : integer := 16#400#; --to_integer(signed(QUANTIZE_F(1.0)));
    constant FM_DEMOD_GAIN : integer := 758; --to_integer(signed(QUANTIZE_F(real(QUAD_RATE) / (2.0 * PI * MAX_DEV))));

    -- Deemphasis IIR Filter Coefficients: 
    constant IIR_COEFF_TAPS : natural := 2;
    type quant_array is array (natural range <>) of std_logic_vector (31 downto 0); 	
    constant IIR_X_COEFFS : quant_array (0 to IIR_COEFF_TAPS - 1) := (x"000000b2", x"000000b2"); --(QUANTIZE_F(W_PP / (1.0 + W_PP)), QUANTIZE_F(W_PP / (1.0 + W_PP)));
    constant IIR_Y_COEFFS : quant_array (0 to IIR_COEFF_TAPS - 1) := ((others => '0'), x"fffffd66"); --(QUANTIZE_F(0.0), QUANTIZE_F((W_PP - 1.0) / (W_PP + 1.0)));	

    -- Channel low-pass complex filter coefficients @ 0kHz to 80kHz
    constant CHANNEL_COEFF_TAPS : natural := 20;
    constant CHANNEL_COEFFS_REAL : quant_array (0 to CHANNEL_COEFF_TAPS - 1) := (       
    x"00000001", x"00000008", x"fffffff3", x"00000009", x"0000000b", x"ffffffd3", x"00000045", x"ffffffd3",
    x"ffffffb1", x"00000257", x"00000257", x"ffffffb1", x"ffffffd3", x"00000045", x"ffffffd3", x"0000000b",
    x"00000009", x"fffffff3", x"00000008", x"00000001");

    constant CHANNEL_COEFFS_IMAG : quant_array (0 to CHANNEL_COEFF_TAPS - 1) := (       
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000");

    -- L+R low-pass filter coefficients @ 15kHz
    constant AUDIO_LPR_COEFF_TAPS : natural := 32;
    constant AUDIO_LPR_COEFFS : quant_array (0 to AUDIO_LPR_COEFF_TAPS - 1) := (       
    x"fffffffd", x"fffffffa", x"fffffff4", x"ffffffed", x"ffffffe5", x"ffffffdf", x"ffffffe2", x"fffffff3",
    x"00000015", x"0000004e", x"0000009b", x"000000f9", x"0000015d", x"000001be", x"0000020e", x"00000243",
    x"00000243", x"0000020e", x"000001be", x"0000015d", x"000000f9", x"0000009b", x"0000004e", x"00000015",
    x"fffffff3", x"ffffffe2", x"ffffffdf", x"ffffffe5", x"ffffffed", x"fffffff4", x"fffffffa", x"fffffffd");

    -- L-R low-pass filter coefficients @ 15kHz", gain := 60
    constant AUDIO_LMR_COEFF_TAPS : natural := 32;
    constant AUDIO_LMR_COEFFS : quant_array (0 to AUDIO_LMR_COEFF_TAPS - 1) := (
    x"fffffffd", x"fffffffa", x"fffffff4", x"ffffffed", x"ffffffe5", x"ffffffdf", x"ffffffe2", x"fffffff3",
    x"00000015", x"0000004e", x"0000009b", x"000000f9", x"0000015d", x"000001be", x"0000020e", x"00000243",
    x"00000243", x"0000020e", x"000001be", x"0000015d", x"000000f9", x"0000009b", x"0000004e", x"00000015",
    x"fffffff3", x"ffffffe2", x"ffffffdf", x"ffffffe5", x"ffffffed", x"fffffff4", x"fffffffa", x"fffffffd");

    -- Pilot tone band-pass filter @ 19kHz
    constant BP_PILOT_COEFF_TAPS : natural := 32;
    constant BP_PILOT_COEFFS : quant_array (0 to BP_PILOT_COEFF_TAPS - 1) := (
    x"0000000e", x"0000001f", x"00000034", x"00000048", x"0000004e", x"00000036", x"fffffff8", x"ffffff98",
    x"ffffff2d", x"fffffeda", x"fffffec3", x"fffffefe", x"ffffff8a", x"0000004a", x"0000010f", x"000001a1",
    x"000001a1", x"0000010f", x"0000004a", x"ffffff8a", x"fffffefe", x"fffffec3", x"fffffeda", x"ffffff2d",
    x"ffffff98", x"fffffff8", x"00000036", x"0000004e", x"00000048", x"00000034", x"0000001f", x"0000000e");

    -- L-R band-pass filter @ 23kHz to 53kHz
    constant BP_LMR_COEFF_TAPS : natural := 32;
    constant BP_LMR_COEFFS : quant_array (0 to BP_LMR_COEFF_TAPS - 1) := (
    x"00000000", x"00000000", x"fffffffc", x"fffffff9", x"fffffffe", x"00000008", x"0000000c", x"00000002",
    x"00000003", x"0000001e", x"00000030", x"fffffffc", x"ffffff8c", x"ffffff58", x"ffffffc3", x"0000008a",
    x"0000008a", x"ffffffc3", x"ffffff58", x"ffffff8c", x"fffffffc", x"00000030", x"0000001e", x"00000003",
    x"00000002", x"0000000c", x"00000008", x"fffffffe", x"fffffff9", x"fffffffc", x"00000000", x"00000000");

    -- High pass filter @ 0Hz removes noise after pilot tone is squared
    constant HP_COEFF_TAPS : natural := 32;
    constant HP_COEFFS : quant_array (0 to HP_COEFF_TAPS - 1) := (
    x"ffffffff", x"00000000", x"00000000", x"00000002", x"00000004", x"00000008", x"0000000b", x"0000000c",
    x"00000008", x"ffffffff", x"ffffffee", x"ffffffd7", x"ffffffbb", x"ffffff9f", x"ffffff87", x"ffffff76",
    x"ffffff76", x"ffffff87", x"ffffff9f", x"ffffffbb", x"ffffffd7", x"ffffffee", x"ffffffff", x"00000008",
    x"0000000c", x"0000000b", x"00000008", x"00000004", x"00000002", x"00000000", x"00000000", x"ffffffff");

end package;