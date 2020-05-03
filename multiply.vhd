library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiply is
    port 
    (
        signal clock   : in std_logic;
        signal reset   : in std_logic;
        signal x_din   : in std_logic_vector (31 downto 0);
        signal y_din   : in std_logic_vector (31 downto 0);
        signal x_empty : in std_logic;
        signal y_empty : in std_logic;
        signal z_full  : in std_logic;
        signal x_rd_en : out std_logic;
        signal y_rd_en : out std_logic;
        signal z_dout  : out std_logic_vector (31 downto 0);
        signal z_wr_en : out std_logic
    );
end entity;

architecture behavioral of multiply is

    function DEQUANTIZE (n : signed) return signed is
    begin
        return resize(shift_right(n, 10), 32);
    end function;

	 type state_types is (s0, s1);
    	 signal state : state_types;
	 signal next_state : state_types;
begin

    multiply_process : process (state, x_din, y_din, x_empty, y_empty, z_full)
    begin
        next_state <= state;
        x_rd_en <= '0';
        y_rd_en <= '0';
        z_wr_en <= '0';
        z_dout <= (others => '0');

        case (state) is
            when s0 =>
                if (x_empty = '0' and y_empty = '0') then
                    next_state <= s1;
                end if;

            when s1 =>
                if (x_empty = '0' and y_empty = '0' and z_full = '0') then
                    x_rd_en <= '1';
                    y_rd_en <= '1';
		    z_wr_en <= '1';
		    z_dout <= std_logic_vector(resize(shift_right(signed(x_din) * signed(y_din), 10), 32));
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