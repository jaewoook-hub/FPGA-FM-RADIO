library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;
use work.components.all;

entity radio is
    port 
    (
        signal clock : in std_logic;
        signal reset : in std_logic;
        signal volume : in integer;
        signal din : in std_logic_vector (31 downto 0);
        signal input_wr_en : in std_logic;
        signal left_rd_en : in std_logic;
        signal right_rd_en : in std_logic;
        signal input_full : out std_logic;
        signal left : out std_logic_vector (31 downto 0);
        signal right : out std_logic_vector (31 downto 0);
        signal left_empty : out std_logic;
        signal right_empty : out std_logic
    );
end entity;

architecture structural of radio is

	-- IQ SIGNALS --
    signal input_rd_en : std_logic := '0';
    signal input_empty : std_logic := '0';
    signal i_din, i : std_logic_vector (31 downto 0) := (others => '0');
    signal i_rd_en, i_wr_en : std_logic := '0';
    signal i_empty, i_full : std_logic := '0';
    signal i_filtered_din, i_filtered : std_logic_vector (31 downto 0) := (others => '0');
    signal i_filtered_rd_en, i_filtered_wr_en : std_logic := '0';
    signal i_filtered_empty, i_filtered_full : std_logic := '0';	
    signal q_din, q : std_logic_vector (31 downto 0) := (others => '0');
    signal q_rd_en, q_wr_en : std_logic := '0';
    signal q_empty, q_full : std_logic := '0';
    signal iq : std_logic_vector (31 downto 0) := (others => '0');
    signal q_filtered_din, q_filtered : std_logic_vector (31 downto 0) := (others => '0');
    signal q_filtered_rd_en, q_filtered_wr_en : std_logic := '0';
    signal q_filtered_empty, q_filtered_full : std_logic := '0';
	
	-- DEMODULATOR SIGNALS --
    signal demodulated : std_logic_vector (31 downto 0) := (others => '0');
    signal demod_wr_en : std_logic := '0';
    signal demod_full : std_logic := '0';
	
	-- RIGHT PATH SIGNALS -- 
    signal right_channel : std_logic_vector (31 downto 0) := (others => '0');
    signal right_channel_rd_en : std_logic := '0';
    signal right_channel_empty, right_channel_full : std_logic := '0';
    signal right_low_din, right_low : std_logic_vector (31 downto 0) := (others => '0');
    signal right_low_rd_en, right_low_wr_en : std_logic := '0';
    signal right_low_empty, right_low_full : std_logic := '0';
    signal right_emph_din, right_emph : std_logic_vector (31 downto 0) := (others => '0');
    signal right_emph_rd_en, right_emph_wr_en : std_logic := '0';
    signal right_emph_empty, right_emph_full : std_logic := '0';	
    signal right_deemph_din, right_deemph : std_logic_vector (31 downto 0) := (others => '0');
    signal right_deemph_rd_en, right_deemph_wr_en : std_logic := '0';
    signal right_deemph_empty, right_deemph_full : std_logic := '0';	
    signal right_gain_din : std_logic_vector (31 downto 0) := (others => '0');
    signal right_gain_wr_en : std_logic := '0';
    signal right_gain_full : std_logic := '0';
	
	-- LEFT PATH SIGNALS --
    signal left_channel : std_logic_vector (31 downto 0) := (others => '0');
    signal left_channel_rd_en : std_logic := '0';
    signal left_channel_empty, left_channel_full : std_logic := '0';
    signal left_band_din, left_band : std_logic_vector (31 downto 0) := (others => '0');
    signal left_band_rd_en, left_band_wr_en : std_logic := '0';
    signal left_band_empty, left_band_full : std_logic := '0';
    signal left_multiplied_din, left_multiplied : std_logic_vector (31 downto 0) := (others => '0');
    signal left_multiplied_rd_en, left_multiplied_wr_en : std_logic := '0';
    signal left_multiplied_empty, left_multiplied_full : std_logic := '0';
    signal left_low_din, left_low : std_logic_vector (31 downto 0) := (others => '0');
    signal left_low_rd_en, left_low_wr_en : std_logic := '0';
    signal left_low_empty, left_low_full : std_logic := '0';
    signal left_emph_din, left_emph : std_logic_vector (31 downto 0) := (others => '0');
    signal left_emph_rd_en, left_emph_wr_en : std_logic := '0';
    signal left_emph_empty, left_emph_full : std_logic := '0';
    signal left_deemph_din, left_deemph : std_logic_vector (31 downto 0) := (others => '0');
    signal left_deemph_rd_en, left_deemph_wr_en : std_logic := '0';
    signal left_deemph_empty, left_deemph_full : std_logic := '0';
    signal left_gain_din : std_logic_vector (31 downto 0) := (others => '0');
    signal left_gain_wr_en : std_logic := '0';
    signal left_gain_full : std_logic := '0';
	
	-- PILOT SIGNALS --
    signal pre_pilot : std_logic_vector (31 downto 0) := (others => '0');
    signal pre_pilot_rd_en : std_logic := '0';
    signal pre_pilot_empty, pre_pilot_full : std_logic := '0';
    signal pilot_filtered_din, pilot_filtered : std_logic_vector (31 downto 0) := (others => '0');
    signal pilot_filtered_rd_en, pilot_filtered_wr_en : std_logic := '0';
    signal pilot_filtered_empty, pilot_filtered_full : std_logic := '0';
    signal pilot_squared_din, pilot_squared : std_logic_vector (31 downto 0) := (others => '0');
    signal pilot_squared_rd_en, pilot_squared_wr_en : std_logic := '0';
    signal pilot_squared_empty, pilot_squared_full : std_logic := '0';
    signal pilot_din, pilot : std_logic_vector (31 downto 0) := (others => '0');
    signal pilot_rd_en, pilot_wr_en : std_logic := '0';
    signal pilot_empty, pilot_full : std_logic := '0';
	
begin

    input_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => INPUT_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => input_rd_en,
        wr_en => input_wr_en,
        din => din,
        dout => iq,
        full => input_full,
        empty => input_empty
    );

    input_read : iq_reader
    port map
    (
        clock => clock,
        reset => reset,
        iq_din => iq,
        iq_empty => input_empty,
        i_full => i_full,
        q_full => q_full,
        iq_rd_en => input_rd_en,
        i_wr_en => i_wr_en,
        q_wr_en => q_wr_en,
        i_dout => i_din,
        q_dout => q_din
    );

    i_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => I_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => i_rd_en,
        wr_en => i_wr_en,
        din => i_din,
        dout => i,
        full => i_full,
        empty => i_empty
    );

    q_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => Q_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => q_rd_en,
        wr_en => q_wr_en,
        din => q_din,
        dout => q,
        full => q_full,
        empty => q_empty
    );

    channel_filter : fir_complex
    generic map
    (
        TAPS => CHANNEL_COEFF_TAPS
    )
    port map
    (
        clock => clock,
        reset => reset,
        real_din => i,
        imag_din => q,
        real_in_empty => i_empty,
        imag_in_empty => q_empty,
        real_out_full => i_filtered_full,
        imag_out_full => q_filtered_full,
        real_in_rd_en => i_rd_en,
        imag_in_rd_en => q_rd_en,
        real_dout => i_filtered_din,
        imag_dout => q_filtered_din,
        real_out_wr_en => i_filtered_wr_en,
        imag_out_wr_en => q_filtered_wr_en
    );

    i_filtered_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => I_FILTERED_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => i_filtered_rd_en,
        wr_en => i_filtered_wr_en,
        din => i_filtered_din,
        dout => i_filtered,
        full => i_filtered_full,
        empty => i_filtered_empty
    );

    q_filtered_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => Q_FILTERED_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => q_filtered_rd_en,
        wr_en => q_filtered_wr_en,
        din => q_filtered_din,
        dout => q_filtered,
        full => q_filtered_full,
        empty => q_filtered_empty
    );

    demodulator : demodulate
    port map
    (
        clock => clock,
        reset => reset,
        real_din => i_filtered,
        imag_din => q_filtered,
        real_empty => i_filtered_empty,
        imag_empty => q_filtered_empty,
        demod_full => demod_full,
        real_rd_en => i_filtered_rd_en,
        imag_rd_en => q_filtered_rd_en,
        demod_dout => demodulated,
        demod_wr_en => demod_wr_en
    );

    demod_full <= pre_pilot_full or left_channel_full or right_channel_full;

    right_channel_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => RIGHT_CHANNEL_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => right_channel_rd_en,
        wr_en => demod_wr_en,
        din => demodulated,
        dout => right_channel,
        full => right_channel_full,
        empty => right_channel_empty
    );

    right_low_filter : fir_decimated
    generic map
    (
        TAPS => AUDIO_LPR_COEFF_TAPS,
        DECS => AUDIO_DECIM
    )
    port map
    (
        clock => clock,
        reset => reset,
        din => right_channel,
        coeffs => AUDIO_LPR_COEFFS,
        in_empty => right_channel_empty,
        out_full => right_low_full,
        in_rd_en => right_channel_rd_en,
        dout => right_low_din,
        out_wr_en => right_low_wr_en
    );

    right_low_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => RIGHT_LOW_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => right_low_rd_en,
        wr_en => right_low_wr_en,
        din => right_low_din,
        dout => right_low,
        full => right_low_full,
        empty => right_low_empty
    );

    left_channel_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => LEFT_CHANNEL_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => left_channel_rd_en,
        wr_en => demod_wr_en,
        din => demodulated,
        dout => left_channel,
        full => left_channel_full,
        empty => left_channel_empty
    );

    left_band_filter : fir
    generic map
    (
        TAPS => BP_LMR_COEFF_TAPS
    )
    port map
    (
        clock => clock,
        reset => reset,
        din => left_channel,
        coeffs => BP_LMR_COEFFS,
        in_empty => left_channel_empty,
        out_full => left_band_full,
        in_rd_en => left_channel_rd_en,
        dout => left_band_din,
        out_wr_en => left_band_wr_en 
    );

    left_band_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => LEFT_BAND_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => left_band_rd_en,
        wr_en => left_band_wr_en,
        din => left_band_din,
        dout => left_band,
        full => left_band_full,
        empty => left_band_empty
    );

    pre_pilot_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => PRE_PILOT_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => pre_pilot_rd_en,
        wr_en => demod_wr_en,
        din => demodulated,
        dout => pre_pilot,
        full => pre_pilot_full,
        empty => pre_pilot_empty
    );

    pilot_filter : fir
    generic map
    (
        TAPS => BP_PILOT_COEFF_TAPS
    )
    port map
    (
        clock => clock,
        reset => reset,
        din => pre_pilot,
        coeffs => BP_PILOT_COEFFS,
        in_empty => pre_pilot_empty,
        out_full => pilot_filtered_full,
        in_rd_en => pre_pilot_rd_en,
        dout => pilot_filtered_din,
        out_wr_en => pilot_filtered_wr_en
    );

    pilot_filtered_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => PILOT_FILTERED_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => pilot_filtered_rd_en,
        wr_en => pilot_filtered_wr_en,
        din => pilot_filtered_din,
        dout => pilot_filtered,
        full => pilot_filtered_full,
        empty => pilot_filtered_empty
    );

    squarer : square 
    port map
    (
        clock => clock,
        reset => reset,
        in_din => pilot_filtered,
        in_empty => pilot_filtered_empty,
        out_full => pilot_squared_full,
        in_rd_en => pilot_filtered_rd_en,
        out_dout => pilot_squared_din,
        out_wr_en => pilot_squared_wr_en
    );

    pilot_squared_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => PILOT_SQUARED_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => pilot_squared_rd_en,
        wr_en => pilot_squared_wr_en,
        din => pilot_squared_din,
        dout => pilot_squared,
        full => pilot_squared_full,
        empty => pilot_squared_empty
    );

    pilot_squared_filter : fir
    generic map
    (
        TAPS => HP_COEFF_TAPS
    )
    port map
    (
        clock => clock,
        reset => reset,
        din => pilot_squared,
        coeffs => HP_COEFFS,
        in_empty => pilot_squared_empty,
        out_full => pilot_full,
        in_rd_en => pilot_squared_rd_en,
        dout => pilot_din,
        out_wr_en => pilot_wr_en
    );

    pilot_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => PILOT_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => pilot_rd_en,
        wr_en => pilot_wr_en,
        din => pilot_din,
        dout => pilot,
        full => pilot_full,
        empty => pilot_empty
    );

    multiplier : multiply 
    port map
    (
        clock => clock,
        reset => reset,
        x_din => left_band,
        y_din => pilot,
        x_empty => left_band_empty,
        y_empty => pilot_empty,
        z_full => left_multiplied_full,
        x_rd_en => left_band_rd_en,
        y_rd_en => pilot_rd_en,
        z_dout => left_multiplied_din,
        z_wr_en => left_multiplied_wr_en
    );

    left_multiplied_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => LEFT_MULTIPLIED_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => left_multiplied_rd_en,
        wr_en => left_multiplied_wr_en,
        din => left_multiplied_din,
        dout => left_multiplied,
        full => left_multiplied_full,
        empty => left_multiplied_empty
    );

    left_low_filter : fir_decimated
    generic map
    (
        TAPS => AUDIO_LMR_COEFF_TAPS,
        DECS => AUDIO_DECIM
    )
    port map
    (
        clock => clock,
        reset => reset,
        din => left_multiplied,
        coeffs => AUDIO_LMR_COEFFS,
        in_empty => left_multiplied_empty,
        out_full => left_low_full,
        in_rd_en => left_multiplied_rd_en,
        dout => left_low_din,
        out_wr_en => left_low_wr_en
    );

    left_low_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => LEFT_LOW_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => left_low_rd_en,
        wr_en => left_low_wr_en,
        din => left_low_din,
        dout => left_low,
        full => left_low_full,
        empty => left_low_empty
    );

    adder_subtractor : add_sub
    port map
    (
        clock => clock,
        reset => reset,
        top_din => left_low,
        bottom_din => right_low,
        top_in_empty => left_low_empty,
        bottom_in_empty => right_low_empty,
        top_out_full => left_emph_full,
        bottom_out_full => right_emph_full,
        top_in_rd_en => left_low_rd_en,
        bottom_in_rd_en => right_low_rd_en,
        top_dout => left_emph_din,
        bottom_dout => right_emph_din,
        top_out_wr_en => left_emph_wr_en,
        bottom_out_wr_en => right_emph_wr_en
    );

    left_emph_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => LEFT_EMPH_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => left_emph_rd_en,
        wr_en => left_emph_wr_en,
        din => left_emph_din,
        dout => left_emph,
        full => left_emph_full,
        empty => left_emph_empty
    );

    right_emph_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => RIGHT_EMPH_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => right_emph_rd_en,
        wr_en => right_emph_wr_en,
        din => right_emph_din,
        dout => right_emph,
        full => right_emph_full,
        empty => right_emph_empty
    );

    deemphasize_left : iir
    generic map
    (
        TAPS => IIR_COEFF_TAPS
    )
    port map
    (
        clock => clock,
        reset => reset,
        din => left_emph, 
        x_coeffs => IIR_X_COEFFS,
        y_coeffs => IIR_Y_COEFFS,
        in_empty => left_emph_empty,
        out_full => left_deemph_full,
        in_rd_en => left_emph_rd_en,
        dout => left_deemph_din,
        out_wr_en => left_deemph_wr_en
    );

    left_deemph_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => LEFT_DEEMPH_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => left_deemph_rd_en,
        wr_en => left_deemph_wr_en,
        din => left_deemph_din,
        dout => left_deemph,
        full => left_deemph_full,
        empty => left_deemph_empty
    );

    deemphasize_right : iir
    generic map
    (
        TAPS => IIR_COEFF_TAPS
    )
    port map
    (
        clock => clock,
        reset => reset,
        din => right_emph, 
        x_coeffs => IIR_X_COEFFS,
        y_coeffs => IIR_Y_COEFFS,
        in_empty => right_emph_empty,
        out_full => right_deemph_full,
        in_rd_en => right_emph_rd_en,
        dout => right_deemph_din,
        out_wr_en => right_deemph_wr_en
    );

    right_deemph_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => RIGHT_DEEMPH_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => right_deemph_rd_en,
        wr_en => right_deemph_wr_en,
        din => right_deemph_din,
        dout => right_deemph,
        full => right_deemph_full,
        empty => right_deemph_empty
    );

    gain_left : gain
    port map
    (
        clock => clock,
        reset => reset,
        volume => volume,
        din => left_deemph,
        in_empty => left_deemph_empty,
        out_full => left_gain_full,
        in_rd_en => left_deemph_rd_en,
        dout => left_gain_din,
        out_wr_en => left_gain_wr_en
    );

    gain_right : gain
    port map
    (
        clock => clock,
        reset => reset,
        volume => volume,
        din => right_deemph,
        in_empty => right_deemph_empty,
        out_full => right_gain_full,
        in_rd_en => right_deemph_rd_en,
        dout => right_gain_din,
        out_wr_en => right_gain_wr_en
    );

    left_gain_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => LEFT_GAIN_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => left_rd_en,
        wr_en => left_gain_wr_en,
        din => left_gain_din,
        dout => left,
        full => left_gain_full,
        empty => left_empty
    );

    right_gain_buffer : fifo
    generic map
    (
        DWIDTH => 32,
        BUFFER_SIZE => RIGHT_GAIN_BUFFER_SIZE
    )
    port map
    (
        rd_clk => clock,
        wr_clk => clock,
        reset => reset,
        rd_en => right_rd_en,
        wr_en => right_gain_wr_en,
        din => right_gain_din,
        dout => right,
        full => right_gain_full,
        empty => right_empty
    );

end architecture;