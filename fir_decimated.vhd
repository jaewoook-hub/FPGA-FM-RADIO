library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity fir_decimated is
    generic
    (
        TAPS : natural := 20;
        DECS : natural := 8
    );
    port 
    (
        signal clock : in std_logic;
        signal reset : in std_logic;
        signal din : in std_logic_vector (31 downto 0);
        signal coeffs : in quant_array (0 to TAPS - 1);
        signal in_empty : in std_logic;
        signal out_full : in std_logic;
        signal in_rd_en : out std_logic;
        signal dout : out std_logic_vector (31 downto 0);
        signal out_wr_en : out std_logic
    );
end entity;

architecture behavioral of fir_decimated is

    function DEQUANTIZE (n : signed) return signed is
    begin
        return resize(shift_right(n, 10), 32);
    end function;
	
    type state_types is (s0, s1, s2);
    signal state : state_types;
    signal next_state : state_types;
    signal data_buffer, data_buffer_c : quant_array (0 to TAPS - 1);
    signal dec_count, dec_count_c : natural;
	
begin

    filter_process : process (state, data_buffer, dec_count, din, in_empty, out_full, coeffs)
        variable sum : signed (31 downto 0) := (others => '0');
        variable data_buffer_v : quant_array (0 to TAPS - 1) := (others => (others => '0'));
    begin
        next_state <= state;
        data_buffer_c <= data_buffer;
        dec_count_c <= dec_count;
        in_rd_en <= '0';
        out_wr_en <= '0';
        dout <= (others => '0');
        sum := (others => '0');
        data_buffer_v := (others => (others => '0'));

        case (state) is
            when s0 =>
                if (in_empty = '0') then
                    dec_count_c <= 0;
                    next_state <= s1;
                end if;

            when s1 =>
                if (in_empty = '0') then
                    in_rd_en <= '1';
                    for i in TAPS - 1 downto 1 loop
                        data_buffer_v(i) := data_buffer(i - 1);
                    end loop;
                    data_buffer_v(0) := din;
                    data_buffer_c <= data_buffer_v;
                    dec_count_c <= dec_count + 1;
                    if (dec_count = DECS - 1) then
                        next_state <= s2;
                    end if;
                end if;

            when s2 =>
                if (out_full = '0') then
                    for i in 0 to TAPS - 1 loop
                        sum := sum + signed(DEQUANTIZE(signed(coeffs(TAPS - 1 - i)) * signed(data_buffer(i))));
                    end loop;
                    dout <= std_logic_vector(sum);
                    out_wr_en <= '1';
                    dec_count_c <= 0;
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
            data_buffer <= (others => (others => '0'));
            dec_count <= 0;
        elsif (rising_edge(clock)) then
            state <= next_state;
            data_buffer <= data_buffer_c;
            dec_count <= dec_count_c;
        end if;
    end process;

end architecture;