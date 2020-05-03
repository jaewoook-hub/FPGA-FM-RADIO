library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.constants.all;
use work.components.all;

entity radio_tb is
    generic
    (
    constant DATA_IN : string (7 downto 1) := "din.dat";
    constant DATA_OUT : string (8 downto 1) := "dout.dat";
    constant DATA_COMP : string (7 downto 1) := "cmp.dat";
    constant CLOCK_PERIOD : time := 2 ns
);
end entity;

architecture behavior of radio_tb is

    type raw_file is file of character;
    constant BYTE : natural := 8;

    function to_char (std : std_logic_vector)
    return character is
    begin
        return character'val(to_integer(unsigned(std)));
    end function;

    function to_slv (char : character)
    return std_logic_vector is
    begin
        return std_logic_vector(to_unsigned(character'pos(char), 8));
    end function;

    function to_slv (int : integer; size: natural)
    return std_logic_vector is
    begin
        return std_logic_vector(to_unsigned(int, size));
    end function;

    procedure read_word (file read_file : raw_file; data : out std_logic_vector) is
        variable char : character;
    begin
        read(read_file, char);
        data(BYTE*3 - 1 downto BYTE*2) := to_slv(char);
        read(read_file, char);
        data(BYTE*4 - 1 downto BYTE*3) := to_slv(char);
        read(read_file, char);
        data(BYTE - 1 downto 0) := to_slv(char);
        read(read_file, char);
        data(BYTE*2 - 1 downto BYTE) := to_slv(char);
    end procedure;

    procedure write_word (file write_file : raw_file; left : in std_logic_vector; right : in std_logic_vector) is
    begin
        write(write_file, to_char(left(BYTE*2 - 1 downto BYTE)));
        write(write_file, to_char(left(BYTE - 1 downto 0)));
        write(write_file, to_char(right(BYTE*2 - 1 downto BYTE)));
        write(write_file, to_char(right(BYTE - 1 downto 0)));
    end procedure;

    signal clock : std_logic := '0';
    signal reset : std_logic := '0';
    signal volume : integer := 0;
    signal din : std_logic_vector (31 downto 0) := (others => '0');
    signal input_wr_en : std_logic := '0';
    signal left_rd_en : std_logic := '0';
    signal right_rd_en : std_logic := '0';
    signal input_full : std_logic := '0';
    signal left : std_logic_vector (31 downto 0) := (others => '0');
    signal right : std_logic_vector (31 downto 0) := (others => '0');
    signal left_empty : std_logic := '0';
    signal right_empty : std_logic := '0';

    -- sync signals --
    signal hold_clock : std_logic := '0';
    signal start : std_logic := '0';
    signal done : std_logic := '0';
    signal errors : natural := 0;
    signal samples : natural := 0;
    signal in_count : natural := 0;
    signal out_count : natural := 0;

begin

    volume <= VOLUME_LEVEL;

    top_inst : component radio
    port map
    (
        clock => clock, 
        reset => reset,
        volume => volume,
        din => din,
        input_wr_en => input_wr_en,
        left_rd_en => left_rd_en,
        right_rd_en => right_rd_en,  
        input_full => input_full,
        left => left,  
        right => right,  
        left_empty => left_empty,  
        right_empty => right_empty
    );

    clock_process : process 
    begin 
        clock <= '1';
        wait for CLOCK_PERIOD / 2; 
        clock <= '0';
        wait for CLOCK_PERIOD / 2; 
        if (hold_clock = '1') then
            wait; 
        end if; 
    end process;

    reset_process: process 
    begin reset <= '0'; 
        wait until clock = '0'; 
        wait until clock = '1'; 
        reset <= '1'; 
        wait until clock = '0'; 
        wait until clock = '1'; 
        reset <= '0'; 
        wait; 
    end process;

    input_process : process
        file input_file : raw_file;
        variable console : line;
        variable data : std_logic_vector (31 downto 0);
    begin
        wait until (reset = '1');
        wait until (reset = '0');
        file_open(input_file, DATA_IN, read_mode);
        wait until (clock = '1');
        start <= '1';
        wait until (clock = '0');
        wait until (clock = '1');
        start <= '0';
        while (not ENDFILE(input_file)) loop
            wait until (clock = '0');
            input_wr_en <= '0';
            if (input_full = '0') then
                read_word(input_file, data);
                din <= data;
                input_wr_en <= '1';
            end if;
            wait until (clock = '1');
        end loop;
        wait until (clock = '0');
        input_wr_en <= '0';
        file_close(input_file);
        write(console, string'("Finished reading input."));
        writeline(output, console);
        wait;
    end process; 

    output_process : process
        file output_file : raw_file;
        file compare_file : raw_file;
        variable out_line : line;
        variable console : line;
        variable res : std_logic_vector (31 downto 0);
        variable cmp : std_logic_vector (31 downto 0);
        variable count : natural := 0;
    begin
        wait until (start = '1');
        wait until (clock = '1');
        file_open(output_file, DATA_OUT, write_mode);
        file_open(compare_file, DATA_COMP, read_mode);
        while (not ENDFILE(compare_file)) loop
            wait until (clock = '0');
            left_rd_en <= '0';
            right_rd_en <= '0';
            if (left_empty = '0' and right_empty = '0') then
                left_rd_en <= '1';
                right_rd_en <= '1';
                wait until (clock = '1');
                -- write out result
                write_word(output_file, left, right);
                res(BYTE*4 - 1 downto BYTE*2) := left(BYTE*2 - 1 downto 0);
                res(BYTE*2 - 1 downto 0) := right(BYTE*2 - 1 downto 0);
                -- read to compare
                read_word(compare_file, cmp);
                if (res /= cmp) then
                    write(console, string'("Error at sample "));
                    write(console, count);
                    write(console, string'(": "));
                    hwrite(console, res);
                    write(console, string'(", "));
                    hwrite(console, cmp);
                    writeline(output, console);
                    errors <= errors + 1;
                end if;
                count := count + 1;
            end if;
        end loop;
        file_close(output_file);
        file_close(compare_file);
        samples <= count;
        done <= '1';
        wait;
    end process;

    sync_process : process 
        variable warnings : integer := 0; 
        variable start_time : time; 
        variable end_time : time; 
        variable ln : line; 
    begin 
        wait until (start = '1');
        start_time := NOW; 
        write (ln, string'("@ "));
        write (ln, start_time);
        write (ln, string'(": Beginnging simultation ..."));
        writeline (output, ln);
        wait until (done = '1');
        end_time := NOW;
        write (ln, string'("@ "));
        write (ln, end_time);
        write (ln, string'(": Simulation completed."));
        writeline (output, ln);
        write (ln, string'("Total simulation cycle count: ")); 
        write (ln, (end_time - start_time) / CLOCK_PERIOD);
        writeline (output, ln);
        write (ln, string'("Total sample count: "));
        write (ln, samples);
        writeline (output, ln);
        write (ln, string'("Total error count: "));
        write (ln, errors);
        writeline (output, ln);
        hold_clock <= '1';
        wait; 
    end process;

end architecture;