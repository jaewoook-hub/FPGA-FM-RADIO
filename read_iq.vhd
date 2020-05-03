library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iq_reader is
    port 
    (
        signal clock 	: in std_logic;
        signal reset 	: in std_logic;
        signal iq_din 	: in std_logic_vector (31 downto 0);
        signal iq_empty : in std_logic;
        signal i_full 	: in std_logic;
        signal q_full 	: in std_logic;
        signal iq_rd_en : out std_logic;
        signal i_wr_en 	: out std_logic;
        signal q_wr_en 	: out std_logic;
        signal i_dout 	: out std_logic_vector (31 downto 0);
        signal q_dout   : out std_logic_vector (31 downto 0)
    );
end entity;

architecture behavioral of iq_reader is
	 type state_types is (s0, s1);
	 signal state : state_types;
	 signal next_state : state_types;
begin

    read_process : process (state, iq_din, iq_empty, i_full, q_full)
        variable i, q  : std_logic_vector (31 downto 0);
    begin
        next_state <= state;
        iq_rd_en <= '0';
        i_wr_en <= '0';
        q_wr_en <= '0';
        i_dout <= (others => '0');
        q_dout <= (others => '0');
        i := (others => '0');
        q := (others => '0');

        case (state) is
            when s0 => 
                if (iq_empty = '0') then
                    next_state <= s1;
                end if;

            when s1 =>
                if (iq_empty = '0' and i_full = '0' and q_full = '0') then
                    iq_rd_en <= '1';
                    i(15 downto 0) := iq_din(31 downto 16);
                    i(31 downto 16) := (others => i(15)); 
                    i_dout <= std_logic_vector(resize(shift_left(signed(i), 10), 32));
                    i_wr_en <= '1';
						  
                    q(15 downto 0) := iq_din(15 downto 0);
                    q(31 downto 16) := (others => q(15)); 
                    q_dout <= std_logic_vector(resize(shift_left(signed(q), 10), 32));
                    q_wr_en <= '1';
                end if;

            when others =>
                next_state <= s0;

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