library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity fir_complex is
    generic
    (
        TAPS : natural := 20
    );
    port 
    (
        signal clock : in std_logic;
        signal reset : in std_logic;
        signal real_din : in std_logic_vector (31 downto 0);
        signal imag_din : in std_logic_vector (31 downto 0);
        signal real_in_empty : in std_logic;
        signal imag_in_empty : in std_logic;
        signal real_out_full : in std_logic;
        signal imag_out_full : in std_logic;
        signal real_in_rd_en : out std_logic;
        signal imag_in_rd_en : out std_logic;
        signal real_dout : out std_logic_vector (31 downto 0);
        signal imag_dout : out std_logic_vector (31 downto 0);
        signal real_out_wr_en : out std_logic;
        signal imag_out_wr_en : out std_logic
    );
end entity;

architecture behavioral of fir_complex is

    function DEQUANTIZE (n : signed) return signed is
    begin
        return resize(shift_right(n, 10), 32);
    end function;
	
    type state_types is (s0, s1);
    signal state : state_types;
    signal next_state : state_types;
	
    signal real_buffer, real_buffer_c : quant_array (0 to TAPS - 1) := (others => (others => '0'));
    signal imag_buffer, imag_buffer_c : quant_array (0 to TAPS - 1) := (others => (others => '0'));
	
begin

    filter_process : process (state, real_buffer, imag_buffer, real_din, imag_din, real_in_empty, imag_in_empty, real_out_full, imag_out_full)
        variable sum_real, sum_imag : signed (31 downto 0) := (others => '0');
        variable real_buffer_v, imag_buffer_v : quant_array (0 to TAPS - 1) := (others => (others => '0'));
    begin
        next_state <= state;
        real_buffer_c <= real_buffer;
        imag_buffer_c <= imag_buffer;
        real_in_rd_en <= '0';
        imag_in_rd_en <= '0';
        real_out_wr_en <= '0';
        imag_out_wr_en <= '0';
        real_dout <= (others => '0');
        imag_dout <= (others => '0');
        sum_real := (others => '0');
        sum_imag := (others => '0');
        real_buffer_v := (others => (others => '0'));
        imag_buffer_v := (others => (others => '0'));

        case (state) is
            when s0 =>
                if (real_in_empty = '0' and imag_in_empty = '0') then
                    next_state <= s1;
                end if;

            when s1 =>
                if (real_in_empty = '0' and imag_in_empty = '0' and real_out_full = '0' and imag_out_full = '0') then
                    real_in_rd_en <= '1';
                    imag_in_rd_en <= '1';
                    -- shift buffers					
                    for i in TAPS - 1 downto 1 loop
                        real_buffer_v(i) := real_buffer(i - 1);
                        imag_buffer_v(i) := imag_buffer(i - 1);
                    end loop;
                    real_buffer_v(0) := real_din;
                    imag_buffer_v(0) := imag_din;
                    real_buffer_c <= real_buffer_v;
                    imag_buffer_c <= imag_buffer_v;
                    for i in 0 to TAPS - 1 loop
                        sum_real := sum_real + signed(DEQUANTIZE(signed(CHANNEL_COEFFS_REAL(i)) * signed(real_buffer_v(i)) - signed(CHANNEL_COEFFS_IMAG(i)) * signed(imag_buffer_v(i))));
                        sum_imag := sum_imag + signed(DEQUANTIZE(signed(CHANNEL_COEFFS_REAL(i)) * signed(imag_buffer_v(i)) - signed(CHANNEL_COEFFS_IMAG(i)) * signed(real_buffer_v(i))));
                    end loop;
                    real_dout <= std_logic_vector(sum_real);
                    imag_dout <= std_logic_vector(sum_imag);
                    real_out_wr_en <= '1';
                    imag_out_wr_en <= '1';
                    next_state <= s1;
                end if;

            when others =>
                next_state <= state;

        end case;
    end process;

    clock_process : process (clock, reset)
    begin 
        if (reset = '1') then
            state <= s0;
            real_buffer <= (others => (others => '0'));
            imag_buffer <= (others => (others => '0'));
        elsif (rising_edge(clock)) then
            state <= next_state;
            real_buffer <= real_buffer_c;
            imag_buffer <= imag_buffer_c;
        end if;
    end process;

end architecture;