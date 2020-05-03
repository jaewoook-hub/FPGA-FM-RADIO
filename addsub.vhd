library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is
    port 
    (
	-- top is the add, bottom is the subtraction --
        signal clock 		: in std_logic;
        signal reset 		: in std_logic;
        signal top_din 		: in std_logic_vector (31 downto 0);
        signal bottom_din 	: in std_logic_vector (31 downto 0);
        signal top_in_empty 	: in std_logic;
        signal bottom_in_empty  : in std_logic;
        signal top_out_full 	: in std_logic;
        signal bottom_out_full  : in std_logic;
        signal top_in_rd_en 	: out std_logic;
        signal bottom_in_rd_en  : out std_logic;
        signal top_dout 	: out std_logic_vector (31 downto 0);
        signal bottom_dout 	: out std_logic_vector (31 downto 0);
        signal top_out_wr_en 	: out std_logic;
        signal bottom_out_wr_en : out std_logic
    );
end entity;

architecture behavioral of add_sub is
	type state_types is (s0, s1);
    	signal state : state_types;
	signal next_state : state_types;
begin
    add_sub_process : process (state, top_din, bottom_din, top_in_empty, bottom_in_empty, top_out_full, bottom_out_full)
    begin
        next_state <= state;
        top_in_rd_en <= '0';
        top_out_wr_en <= '0';
        top_dout <= (others => '0');
	bottom_in_rd_en <= '0';
        bottom_out_wr_en <= '0';
        bottom_dout <= (others => '0');

        case (state) is
            when s0 =>
                if (top_in_empty = '0' and bottom_in_empty = '0') then
                    next_state <= s1;
                end if;

            when s1 =>
                if (top_in_empty = '0' and top_out_full = '0' and bottom_in_empty = '0' and bottom_out_full = '0') then
                    top_in_rd_en <= '1';
                    top_out_wr_en <= '1';
                    bottom_in_rd_en <= '1';
                    bottom_out_wr_en <= '1';
		    -- top takes care of the addition block, while bottom takes care of the subtraction block -- 
                    top_dout <= std_logic_vector(signed(bottom_din) + signed(top_din));
                    bottom_dout <= std_logic_vector(signed(bottom_din) - signed(top_din));
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