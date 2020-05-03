library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gain is
    port 
    (
        clock : in std_logic;
        reset : in std_logic;
        volume : in integer;
        din : in std_logic_vector (31 downto 0);
        in_empty : in std_logic;
        out_full : in std_logic;
        in_rd_en : out std_logic;
        dout : out std_logic_vector (31 downto 0);
        out_wr_en : out std_logic
    );
end entity;

architecture behavioral of gain is

    function DEQUANTIZE (n : signed) return signed is
    begin
        return resize(shift_right(n, 10), 32);
    end function;
	
	type state_types is (s0, s1);
    signal state : state_types;
	signal next_state : state_types;
	
begin

    gain_process : process (state, din, in_empty, out_full, volume)
    begin
        next_state <= state;
        in_rd_en <= '0';
        out_wr_en <= '0';
        dout <= (others => '0');

        case (state) is
            when s0 =>
                if (in_empty = '0') then
                    next_state <= s1;
                end if;
				
			-- for ( int i = 0; i < n_samples; i++ )
			-- {
			-- output[i] = DEQUANTIZE(input[i] * gain) << (14-BITS);
			-- }
			
            when s1 =>
                if (in_empty = '0' and out_full = '0') then
                    in_rd_en <= '1';
                    dout <= std_logic_vector(shift_left(DEQUANTIZE(signed(din) * volume), 4));
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
        elsif (rising_edge(clock)) then
            state <= next_state;
        end if;
    end process;

end architecture;