library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity iir is
	-- deemphasis/iir stage --
    generic
    (
        TAPS : natural := 20
    );
    port 
    (
        clock : in std_logic;
        reset : in std_logic;
        din : in std_logic_vector (31 downto 0);
        x_coeffs : in quant_array (0 to TAPS - 1);
        y_coeffs : in quant_array (0 to TAPS - 1);
        in_empty : in std_logic;
        out_full : in std_logic;
        in_rd_en : out std_logic;
        dout : out std_logic_vector (31 downto 0);
        out_wr_en : out std_logic
    );
end entity;

architecture behavioral of iir is

    function DEQUANTIZE (n : signed) return signed is
    begin
        return resize(shift_right(n, 10), 32);
    end function;
	
    type state_types is (s0, s1);
    signal state : state_types;
	signal next_state : state_types;
    signal x_buffer, x_buffer_c : quant_array (0 to TAPS - 1);
    signal y_buffer, y_buffer_c : quant_array (0 to TAPS - 1);
	
begin

    filter_process : process (state, x_buffer, y_buffer, din, in_empty, out_full, x_coeffs, y_coeffs)
        variable sum_x, sum_y : signed (31 downto 0) := (others => '0');
        variable x_buffer_v, y_buffer_v : quant_array (0 to TAPS - 1);
    begin
        next_state <= state;
        x_buffer_c <= x_buffer;
        y_buffer_c <= y_buffer;
        in_rd_en <= '0';
        out_wr_en <= '0';
        dout <= (others => '0');
        sum_x := (others => '0');
        sum_y := (others => '0');

        case (state) is
            when s0 =>
                if (in_empty = '0') then
                    next_state <= s1;
                end if;

            when s1 =>
                if (in_empty = '0' and out_full = '0') then
                    in_rd_en <= '1';
				    -- this is the shift x buffer	
                    for i in TAPS - 1 downto 1 loop
                        x_buffer_v(i) := x_buffer(i - 1);
                    end loop;
                    x_buffer_v(0) := din; 
                    x_buffer_c <= x_buffer_v;

                    for i in 0 to TAPS - 1 loop
                        sum_x := sum_x + DEQUANTIZE(signed(x_coeffs(i)) * signed(x_buffer_v(i)));
                        sum_y := sum_y + DEQUANTIZE(signed(y_coeffs(i)) * signed(y_buffer(i)));
                    end loop;

				    -- this is the shift y buffer
                    for i in TAPS - 1 downto 1 loop
                        y_buffer_v(i) := y_buffer(i - 1);
                    end loop;
                    y_buffer_v(0) := std_logic_vector(signed(sum_x) + signed(sum_y)); 
                    y_buffer_c <= y_buffer_v;

                    dout <= y_buffer_v(TAPS - 1);
                    out_wr_en <= '1';
                end if;

            when others =>
                next_state <= state;

        end case;
    end process;

    clock_process : process (clock, reset)
    begin 
        if (reset = '1') then
            state <= s0;
            x_buffer <= (others => (others => '0'));
            y_buffer <= (others => (others => '0'));
        elsif (rising_edge(clock)) then
            state <= next_state;
            x_buffer <= x_buffer_c;
            y_buffer <= y_buffer_c;
        end if;
    end process;

end architecture;