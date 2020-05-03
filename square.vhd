library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity square is
    port 
    (
        signal clock 		: in std_logic;
        signal reset 		: in std_logic;
        signal in_din 		: in std_logic_vector (31 downto 0);
        signal in_empty 	: in std_logic;
        signal out_full 	: in std_logic;
        signal in_rd_en 	: out std_logic;
        signal out_dout 	: out std_logic_vector (31 downto 0);
        signal out_wr_en 	: out std_logic
    );
end entity;

architecture behavioral of square is
	 type state_types is (s0, s1);
    	 signal state	   : state_types;
	 signal next_state : state_types;
begin

    square_process : process (state, in_din, in_empty, out_full)
    begin
        next_state <= state;
        in_rd_en <= '0';
        out_wr_en <= '0';
        out_dout <= (others => '0');

        case (state) is
            when s0 =>
                if (in_empty = '0') then
                    next_state <= s1;
                end if;

            when s1 =>
                if (in_empty = '0' and out_full = '0') then
                    in_rd_en <= '1';
                    out_dout <= std_logic_vector(resize(shift_right(signed(in_din) * signed(in_din), 10), 32));
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